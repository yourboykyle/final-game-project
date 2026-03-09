extends Node2D

const CROSSHAIR = preload("res://entities/crosshair.tscn")
var crosshair_instance = null

func _ready() -> void:
	$DungeonGenerator.generate()
	$Player.position = Vector2(384,384)

func _process(delta: float) -> void:
	if Globals.shooting_enabled and crosshair_instance == null:
		crosshair_instance = CROSSHAIR.instantiate()
		add_child(crosshair_instance)

	if !Globals.shooting_enabled and crosshair_instance != null:
		crosshair_instance.queue_free()
		crosshair_instance = null
