extends Node2D

@onready var gameplayUI = $CanvasLayer/GameplayUI
@onready var oxygen_bar = $CanvasLayer/GameplayUI/OxygenBar
@onready var container = $SceneContainer
@onready var dungeon_container = $DungeonContainer
@onready var minimap: Node2D = $CanvasLayer/GameplayUI/Minimap
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const MAIN_MENU = preload("res://MainMenu.tscn")
const LEVEL_SELECT = preload("res://LevelSelect.tscn")
const PLAYER_SCENE = preload("res://entities/Player.tscn")
const DEATH_SCENE = preload("res://DeathScreen.tscn")
const DEATH_EFFECT = preload("res://interface/DeathEffect.tscn")

var current_scene = null
var player = null
var dungeon_hotbar_ui: Node2D = null
var death_effect = null

func _ready() -> void:
	gameplayUI.hide()
	
	load_main_menu()

func _on_player_oxygen_changed(curr, max):
	oxygen_bar.set_oxygen(curr, max)

func clear_scene():
	if current_scene:
		current_scene.queue_free()
		current_scene = null

func clear_dungeon():
	for child in dungeon_container.get_children():
		child.queue_free()
	
	clear_pickup_dictionaries()
	clear_room_data()
	
	Globals.boss_spawned = false

# Clear the rooms that had picked up items in them so future dungeons can generate pickups in those rooms
func clear_pickup_dictionaries():
	Globals.opened_chests.clear()
	Globals.opened_bubbles.clear()
	Globals.rewards_spawned.clear()

func clear_room_data():
	Globals.room_pickups.clear()
	Globals.room_enemies.clear()



func load_main_menu():
	audio_stream_player.stop()
	Globals.death_disabled = false
	if dungeon_hotbar_ui:
		dungeon_hotbar_ui.queue_free()
		dungeon_hotbar_ui = null
	if death_effect:
		death_effect.queue_free()
		death_effect = null

	clear_scene()
	
	gameplayUI.hide()
	
	current_scene = MAIN_MENU.instantiate()
	container.add_child(current_scene)

	current_scene.play_pressed.connect(load_level_select)


func load_level_select():
	clear_scene()

	current_scene = LEVEL_SELECT.instantiate()
	container.add_child(current_scene)

	current_scene.level_selected.connect(start_game)
	current_scene.back_pressed.connect(load_main_menu)

func load_death_screen():
	audio_stream_player.stop()
	if dungeon_hotbar_ui:
		dungeon_hotbar_ui.queue_free()
		dungeon_hotbar_ui = null
	if death_effect:
		death_effect.queue_free()
		death_effect = null

	clear_scene()
	clear_dungeon()
	InventoryManager.clear_run_state()
	
	gameplayUI.hide()
	
	current_scene = DEATH_SCENE.instantiate()
	container.add_child(current_scene)

func start_game(level_id):
	clear_scene()
	
	if Globals.music_enabled:
		audio_stream_player.play()
	else:
		audio_stream_player.stop()
	Globals.current_floor = level_id
	Globals.games_entered += 1
	
	gameplayUI.show()
	
	if player == null:
		player = PLAYER_SCENE.instantiate()
		dungeon_container.add_child(player)
		
		player.oxygen_changed.connect(_on_player_oxygen_changed)
		player.died.connect(func():load_death_screen())

		#red death effect on screen
		death_effect = DEATH_EFFECT.instantiate()
		add_child(death_effect)
		player.death_effect = death_effect

		dungeon_hotbar_ui = preload("res://interface/scripts/DungeonHotbarUI.gd").new()
		gameplayUI.add_child(dungeon_hotbar_ui)

		InventoryManager.select_hotbar_slot(0)
		player._on_hotbar_slot_selected(0)
		
		_apply_upgrades_to_player()

	$DungeonManager.generate()
	player.position = Globals.ROOM_CENTER

func _process(delta: float) -> void:
	for slot_num in range (1, 6):
		if Input.is_action_just_pressed("hotbar_slot_%d" % slot_num):
			InventoryManager.select_hotbar_slot(slot_num - 1)

func _apply_upgrades_to_player() -> void:
	for i in range(InventoryManager.get_unlocked_upgrade_slots()):
		var upgrade_item = InventoryManager.upgrades.get_item(i)
		if not upgrade_item.is_empty():
			var upgrade_scene = ItemDb.get_item(upgrade_item.id)
			if upgrade_scene and upgrade_scene.has_method("apply_upgrade"):
				upgrade_scene.apply_upgrade(player)
