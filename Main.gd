extends Node2D

const CROSSHAIR = preload("res://entities/crosshair.tscn")
var crosshair_instance = null

func _ready() -> void:
	$DungeonGenerator.generate()
	var player_spawn_coords = Globals.room_size / 2
	$Player.position = Vector2(player_spawn_coords, player_spawn_coords)

func _process(delta: float) -> void:
	if Globals.shooting_enabled and crosshair_instance == null:
		crosshair_instance = CROSSHAIR.instantiate()
		add_child(crosshair_instance)

	if !Globals.shooting_enabled and crosshair_instance != null:
		crosshair_instance.queue_free()
		crosshair_instance = null
