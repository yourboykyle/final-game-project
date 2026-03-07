extends Node2D

func _ready() -> void:
	$DungeonGenerator.generate()
	$Player.position = Vector2(384,384)

func _process(delta: float) -> void: # once per frame
	pass
