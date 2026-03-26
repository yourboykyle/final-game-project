extends Control

signal level_selected(level_id)
signal back_pressed

func _on_back_pressed():
	back_pressed.emit()

func _on_tutorial_pressed() -> void:
	level_selected.emit(0)

func _on_level_1_pressed():
	level_selected.emit(1)

func _on_level_2_pressed():
	level_selected.emit(2)

func _on_level_3_pressed():
	level_selected.emit(3)
