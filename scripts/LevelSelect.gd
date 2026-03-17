extends Control

signal level_selected(level_id)
signal back_pressed

func _on_level_1_pressed():
	level_selected.emit(1)

func _on_back_pressed():
	back_pressed.emit()
