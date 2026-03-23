extends HBoxContainer

@onready var inventory_manager = InventoryManager

var hotbar_slots: Array = []
var parent_menu: Node = null

func _ready():
	for i in range(inventory_manager.hotbar.capacity):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(60, 60)
		slot_panel.modulate = Color.LIGHT_BLUE
		
		var v_box = VBoxContainer.new()
		slot_panel.add_child(v_box)
		
		var item_label = Label.new()
		item_label.text = ""
		item_label.add_theme_font_size_override("font_size", 10)
		v_box.add_child(item_label)
		
		add_child(slot_panel)
		
		hotbar_slots.append({
			"panel": slot_panel,
			"label": item_label,
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
			slot_info.label.text = "[empty]"
		else:
			panel.modulate = Color.SLATE_BLUE
			slot_info.label.text = "ID: %d\nQty: %d" % [item.id, item.quantity]
	
	if parent_menu:
		for slot_info in hotbar_slots:
			if slot_info.index == parent_menu.selected_source_index and parent_menu.selected_source_container == "hotbar":
				slot_info.panel.modulate = Color.YELLOW
