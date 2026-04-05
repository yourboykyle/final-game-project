extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# stats
	var stats_panel = $Panel
	var stats_label = $Panel/Label
	stats_label.text = (
			"Games Entered: %d\n" +
			"Successful Extracts: %d\n" +
			"Deaths: %d\n" +
			"Entities Killed: %d\n" +
			"Bosses Killed: %d\n" +
			"Items Collected: %d\n" +
			"XP Collected: %d"
		) % [Globals.games_entered, Globals.successful_extracts,
			Globals.deaths, Globals.entities_killed, Globals.bosses_killed,
			Globals.items_collected, Globals.xp]

	stats_panel.add_child(stats_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().current_scene.load_credits() # Replace with function body.


func _on_button_2_pressed() -> void:
	get_tree().current_scene.load_main_menu()# Replace with function body.


func _on_button_3_pressed() -> void:
	get_tree().quit()
