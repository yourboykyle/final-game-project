extends Control

@onready var label = $OxygenLabel

var current_oxygen: float = 100.0
var max_oxygen: float = 100.0

var color_background = Color(0.1, 0.3, 0.4)
var color_depleted = Color(0.2, 0.5, 0.6)
var color_oxygen = Color(0.2, 0.9, 1.0) 

func _ready():
	set_oxygen(max_oxygen, max_oxygen)

func set_oxygen(current: float, max: float):
	max_oxygen = max
	current_oxygen = current
	queue_redraw()

func _draw():
	var center = Vector2(50,50)
	var radius = 40.0
	var stroke_width = 6.0

	draw_circle(center, radius, color_background)
	draw_arc(center, radius, 0, PI * 2, 32, color_depleted, stroke_width)

	if max_oxygen > 0:
		var oxygen_percent = current_oxygen / max_oxygen
		var arc_end = oxygen_percent * PI * 2
		draw_arc(center, radius, -PI/2, -PI/2 + arc_end, 32, color_oxygen, stroke_width)
	
	draw_circle(center, radius - stroke_width - 2, color_background)
	var percent_text = "%d%%" % int(current_oxygen / max_oxygen * 100)
	draw_string(get_theme_font("font"), center - Vector2(15, 5), percent_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)
