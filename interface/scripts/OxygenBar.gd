extends Control

@onready var bar = $Bar

func set_oxygen(current: float, max: float):
	bar.max_value = max
	bar.value = current
