extends Control

signal play_pressed

@onready var play_button = $RightPanel/CenterContainer/VBoxContainer/PlayButton
@onready var stash_panel = $StashPanel

var stash_slots: Array = []
var hotbar_ui: Node
var selected_source_index: int = -1
var selected_source_container: String = ""

func _ready():	
	var vbox = $RightPanel/CenterContainer/VBoxContainer
	_setup_stash()

	var hotbar_ui_script = load("res://interface/scripts/HotbarUI.gd")
	
	hotbar_ui = hotbar_ui_script.new()
	hotbar_ui.parent_menu = self
	vbox.add_child(hotbar_ui)
	vbox.move_child(hotbar_ui, 1)
	
	play_button.pressed.connect(_on_play_pressed)
	
	_refresh_all()

func _setup_stash():
	#padding container
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 30)
	margin_container.add_theme_constant_override("margin_top", 10)
	stash_panel.add_child(margin_container)

	var main_vbox = VBoxContainer.new()
	margin_container.add_child(main_vbox)
	
	var label_container = CenterContainer.new()
	main_vbox.add_child(label_container)

	var inv_label = Label.new()
	inv_label.text = "Inventory:"
	inv_label.add_theme_font_size_override("font_size", 16)
	main_vbox.add_child(inv_label)

	var grid = GridContainer.new()
	grid.columns = 5
	main_vbox.add_child(grid)
	
	for i in range(InventoryManager.stash.capacity):
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
		
		grid.add_child(slot_panel)
		
		stash_slots.append({
			"panel": slot_panel,
			"sprite": sprite_rect,
			"name": item_label,
			"qty": quant_label,
			"index": i
		})
		
		slot_panel.gui_input.connect(_on_stash_slot_clicked.bindv([i]))
	
	InventoryManager.inventory_changed.connect(_refresh_all)

func _on_stash_slot_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.pressed:
		_handle_selection(slot_index, "stash")

func _handle_selection(slot_index: int, container: String):
	if selected_source_index == -1:
		var item = null;
		if container == "stash":
			item = InventoryManager.stash.get_item(slot_index)
		else:
			item = InventoryManager.hotbar.get_item(slot_index)
		if not item.is_empty():
			selected_source_index = slot_index
			selected_source_container = container
			_refresh_all()
		return
	
	if selected_source_container == container:
		if selected_source_index == slot_index:
			selected_source_index = -1
			_refresh_all()
		return
	
	if selected_source_container == "stash" and container == "hotbar":
		InventoryManager.move_stash_to_hotbar(selected_source_index)
	elif selected_source_container == "hotbar" and container == "stash":
		InventoryManager.move_hotbar_to_stash(selected_source_index)
	
	selected_source_index = -1
	_refresh_all()

func _refresh_all():
	_refresh_stash()
	if hotbar_ui:
		hotbar_ui.refresh_display()

func _refresh_stash():
	for slot_info in stash_slots:
		var item = InventoryManager.stash.get_item(slot_info.index)
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
	
	for slot_info in stash_slots:
		if slot_info.index == selected_source_index and selected_source_container == "stash":
			slot_info.panel.modulate = Color.YELLOW

func _on_play_pressed():
	play_pressed.emit()
