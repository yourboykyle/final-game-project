extends Control


func _on_button_pressed() -> void:
	get_tree().current_scene.load_main_menu()


func _on_button_2_pressed() -> void:
	get_tree().qui()
