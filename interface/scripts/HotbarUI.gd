extends HBoxContainer

@onready var inventory_manager = InventoryManager

var hotbar_slots: Array = []
var parent_menu: Node = null

func _ready():
	for i in range(inventory_manager.hotbar.capacity):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(60, 60)
		slot_panel.modulate = Color.LIGHT_BLUE
		
		var overlay = Node2D.new()
		slot_panel.add_child(overlay)

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
		
		add_child(slot_panel)
		
		hotbar_slots.append({
			"panel": slot_panel,
			"sprite": sprite_rect,
			"name": item_label,
			"qty": quant_label,
			"index": i
		})
		
		slot_panel.gui_input.connect(_on_slot_clicked.bindv([i]))
	
	inventory_manager.inventory_changed.connect(refresh_display)
	refresh_display()

func _on_slot_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.pressed:
		if parent_menu:
			parent_menu._handle_selection(slot_index, "hotbar")

func refresh_display():
	for slot_info in hotbar_slots:
		var item = inventory_manager.hotbar.get_item(slot_info.index)
		var panel = slot_info.panel
		
		if item.is_empty():
			panel.modulate = Color.LIGHT_BLUE
			slot_info.sprite.texture = null
			slot_info.name.text = "[empty]"
			slot_info.qty.text = ""
		else:
			panel.modulate = Color(0.6, 0.6, 0.6)
			var item_data = ItemDb.get_item_data(item.id)
			slot_info.sprite.texture = item_data.texture
			slot_info.name.text = item_data.name
			slot_info.qty.text = "Qty: %d" % item.quantity
	
	if parent_menu:
		for slot_info in hotbar_slots:
			if slot_info.index == parent_menu.selected_source_index and parent_menu.selected_source_container == "hotbar":
				slot_info.panel.modulate = Color.YELLOW
