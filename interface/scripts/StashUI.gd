extends VBoxContainer

@onready var inventory_manager = InventoryManager

var stash_slots: Array = []
var selected_slot: int = -1

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	print("Stash capacity: ", inventory_manager.stash.capacity)

	var grid = GridContainer.new()
	grid.columns = 8
	#40 slots, maybe have upgrade later if theres time
	add_child(grid)

	for i in range(inventory_manager.stash_capacity):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(60, 60)
		slot_panel.modulate = Color.DARK_GRAY

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
		
		grid.add_child(slot_panel)
		
		stash_slots.append({
			"panel": slot_panel,
			"sprite": sprite_rect,
			"name": item_label,
			"qty": quant_label,
			"index": i
		})
	
	inventory_manager.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed()
	print("STASH READY")

func _on_inventory_changed():
	for slot_info in stash_slots:
		var item = inventory_manager.stash.get_item(slot_info.index)
		var panel = slot_info.panel

		if item.is_empty():
			panel.modulate = Color.DARK_GRAY
			slot_info.sprite.texture = null
			slot_info.name.text = ""
			slot_info.qty.text = ""
		else:
			panel.modulate = Color.DARK_SLATE_GRAY
			var item_data = ItemDb.get_item_data(item.id)
			slot_info.sprite.texture = item_data.texture
			slot_info.name.text = item_data.name
			slot_info.qty.text = "Qty: %d" % item.quantity
