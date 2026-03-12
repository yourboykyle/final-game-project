extends Node2D

@onready var player = $Player
@onready var oxygen_bar = $CanvasLayer/OxygenBar

func _ready() -> void:
	$DungeonManager.generate()
	player.connect("oxygen_changed", _on_player_oxygen_changed)
	$Player.position = Globals.ROOM_CENTER

func _process(delta: float) -> void:
	if Globals.shooting_enabled and Globals.crosshair_instance == null:
		Globals.crosshair_instance = Globals.CROSSHAIR.instantiate()
		add_child(Globals.crosshair_instance)


	if !Globals.shooting_enabled and Globals.crosshair_instance != null:
		Globals.crosshair_instance.queue_free()
		Globals.crosshair_instance = null

func _on_player_oxygen_changed(curr, max):
	oxygen_bar.set_oxygen(curr, max)
