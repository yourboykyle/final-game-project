extends Node2D

@onready var gameplayUI = $CanvasLayer/GameplayUI
@onready var oxygen_bar = $CanvasLayer/GameplayUI/OxygenBar
@onready var container = $SceneContainer

const MAIN_MENU = preload("res://MainMenu.tscn")
const LEVEL_SELECT = preload("res://LevelSelect.tscn")
const PLAYER_SCENE = preload("res://entities/Player.tscn")

var current_scene = null
var player = null

func _ready() -> void:
	gameplayUI.hide()
	
	load_main_menu()

func _on_player_oxygen_changed(curr, max):
	oxygen_bar.set_oxygen(curr, max)

func clear_scene():
	if current_scene:
		current_scene.queue_free()
		current_scene = null


func load_main_menu():
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


func start_game(level_id):
	clear_scene()
	Globals.current_floor = level_id
	
	gameplayUI.show()
	
	if player == null:
		player = PLAYER_SCENE.instantiate()
		$DungeonContainer.add_child(player)
		
		player.oxygen_changed.connect(_on_player_oxygen_changed)

	$DungeonManager.generate()
	player.position = Globals.ROOM_CENTER
