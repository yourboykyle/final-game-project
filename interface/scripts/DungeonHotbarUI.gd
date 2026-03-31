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

		var overlay = Node2D.new()
		panel.add_child(overlay)

		var sprite_rect = TextureRect.new()
		sprite_rect.custom_minimum_size = Vector2(48, 48)
		sprite_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		sprite_rect.position = Vector2(2, 8)
		overlay.add_child(sprite_rect)

		var item_label = Label.new()
		item_label.text = ""
		item_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		item_label.add_theme_font_size_override("font_size", 9)
		item_label.position = Vector2(2, 2)
		overlay.add_child(item_label)

		var quant_label = Label.new()
		quant_label.text = ""
		quant_label.add_theme_font_size_override("font_size", 10)
		quant_label.position = Vector2(2, 45)
		overlay.add_child(quant_label)

		add_child(panel)

		hotbar_slots.append({
			"panel": panel,
			"sprite": sprite_rect,
			"name": item_label,
			"qty": quant_label,
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
		var sprite = slot["sprite"]
		var name = slot["name"]
		var qty = slot["qty"]
		var item = hotbar.get_item(index)

		if index == InventoryManager.hotbar_selected_index:
			panel.modulate = Color.YELLOW
		else:
			if not item.is_empty():
				panel.modulate = Color(0.5, 0.5, 0.7)
			else:
				panel.modulate = Color(0.7, 0.8, 1.0)
		
		if not item.is_empty():
			var item_data = ItemDb.get_item_data(item["id"])
			sprite.texture = item_data.texture
			name.text = item_data.name
			qty.text = "Qty: %d" % item["quantity"]
		else:
			sprite.texture = null
			name.text = "[empty]"
			qty.text = ""
