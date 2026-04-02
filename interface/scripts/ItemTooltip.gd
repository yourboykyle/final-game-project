class_name ItemTooltip
extends Control

var panel: PanelContainer
var vbox: VBoxContainer
var name_label: Label
var desc_label: Label
var current_tween: Tween

func _ready():
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 0)
	add_child(panel)
	
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)
	
	name_label = Label.new()
	name_label.text = ""
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color.YELLOW)
	name_label.custom_minimum_size = Vector2(180, 0)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)
	
	desc_label = Label.new()
	desc_label.text = ""
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.custom_minimum_size = Vector2(180, 0)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)
	

func show_tooltip(item_data: Dictionary) -> void:
	name_label.text = item_data.get("name", "Unknown")
	desc_label.text = item_data.get("description", "No description available")
	
	# Kill previous tween
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	panel.size = Vector2.ZERO

func hide_tooltip() -> void:
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.tween_property(self, "modulate:a", 0.0, 0.1)

func _process(delta):
	if modulate.a > 0.01:
		global_position = get_global_mouse_position() + Vector2(10, 10)
