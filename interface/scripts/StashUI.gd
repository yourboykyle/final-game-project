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
	#40 slots
	add_child(grid)

	for i in range(inventory_manager.stash_capacity):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(60, 60)
		slot_panel.modulate = Color.DARK_GRAY

		var v_box = VBoxContainer.new()
		slot_panel.add_child(v_box)

		var label = Label.new()
		label.text = str(i)
		label.add_theme_font_size_override("font_size", 8)
		v_box.add_child(label)

		grid.add_child(slot_panel)
		stash_slots.append({"panel": slot_panel, "label": label, "index": i})
	
	inventory_manager.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed()
	print("STASH READY")

func _on_inventory_changed():
	for slot_info in stash_slots:
		var item = inventory_manager.stash.get_item(slot_info.index)
		var panel = slot_info.panel

		if item.is_empty():
			panel.modulate = Color.DARK_GRAY
			slot_info.label.text = ""
		else:
			panel.modulate = Color.DARK_SLATE_GRAY
			slot_info.label.text= "ID: %d\nQty: %d" % [item.id, item.quantity]
