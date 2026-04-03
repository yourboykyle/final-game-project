@abstract class_name Interactable extends Area2D


@export var sfx_stream: AudioStream

# Called when the node enters the scene tree fors the first time.
func _ready() -> void:
	add_to_group(Globals.GROUP_STRINGS[Globals.Groups.INTERACTABLE])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@abstract func interact()
