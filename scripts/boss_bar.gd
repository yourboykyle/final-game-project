extends ProgressBar 
@onready var label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	Globals.boss_bar = self
	var style = StyleBoxFlat.new() 
	style.bg_color = Color.RED 
	style.corner_radius_top_left = 55/2 
	style.corner_radius_top_right = 55/2
	style.corner_radius_bottom_left = 55/2
	style.corner_radius_bottom_right = 55/2 
	add_theme_stylebox_override("fill", style) 
	var background = StyleBoxFlat.new()
	background.bg_color = Color.DIM_GRAY
	background.corner_radius_top_left = 55/2 
	background.corner_radius_top_right = 55/2
	background.corner_radius_bottom_left = 55/2
	background.corner_radius_bottom_right = 55/2 
	add_theme_stylebox_override("background", background) 
func connect_boss(boss):
	if boss == null:
		print("Boss is null")
		return
	
	boss.health_changed.connect(update_bar)
	max_value = boss.max_health
	value = boss.health 
	if Globals.current_floor == 3: 
		label.text = "Angler"
	else: 
		label.text = "Ripper Shark"
	
	show()
func update_bar(current, max):
	value = current
