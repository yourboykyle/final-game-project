extends Node2D

func _ready() -> void:
	$DungeonManager.generate()

	$Player.position = Globals.ROOM_CENTER

func _process(delta: float) -> void:
	if Globals.shooting_enabled and Globals.crosshair_instance == null:
		Globals.crosshair_instance = Globals.CROSSHAIR.instantiate()
		add_child(Globals.crosshair_instance)

	if !Globals.shooting_enabled and Globals.crosshair_instance != null:
		Globals.crosshair_instance.queue_free()
		Globals.crosshair_instance = null
