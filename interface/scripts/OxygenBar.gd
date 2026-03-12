extends Control

@onready var bar = $Bar

func set_oxygen(current: float, max: float):
	bar.max_value = max
	bar.value = current

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
