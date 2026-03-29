extends Node2D

var hotbar
var hotbar_slots: Array = []

func _ready():
	hotbar = InventoryManager.hotbar
	_create_slots()
	InventoryManager.hotbar_slot_selected.connect(_on_hotbar_slot_selected)
	InventoryManager.inventory_changed.connect(_on_inventory_changed)

func _create_slots() -> void:
	var slot_size = 60
	var spacing = 10
	var viewport_width = get_viewport_rect().size.x
	var total_width = (slot_size * hotbar.capacity) + (spacing * (hotbar.capacity - 1))
	var start_x = (viewport_width / 2) - (total_width / 2)


	for i in range(hotbar.capacity):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(slot_size, slot_size)
		panel.position = Vector2(start_x + (i * (slot_size + spacing)), 1000)

		var vbox = VBoxContainer.new()
		var label = Label.new()
		label.text = "[empty]"
		label.add_theme_font_size_override("font_size", 8)
		vbox.add_child(label)
		panel.add_child(vbox)
		add_child(panel)

		hotbar_slots.append({
			"panel": panel,
			"label": label,
			"index": i
		})

	_update_display()

func _on_hotbar_slot_selected(slot_index: int) -> void:
	_update_display()

func _on_inventory_changed() -> void:
	_update_display()

func _update_display() -> void:
	for slot in hotbar_slots:
		var index = slot["index"]
		var panel = slot["panel"]
		var label = slot["label"]
		var item = hotbar.get_item(index)

		if index == InventoryManager.hotbar_selected_index:
			panel.modulate = Color.YELLOW
		else:
			if not item.is_empty():
				panel.modulate = Color(0.5, 0.5, 0.7)
			else:
				panel.modulate = Color(0.7, 0.8, 1.0)
		
		if not item.is_empty():
			label.text = "ID: %d\nQty: %d" % [item["id"], item["quantity"]]
		else:
			label.text = "[empty]"
