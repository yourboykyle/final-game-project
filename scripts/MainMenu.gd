extends Control

signal play_pressed

@onready var play_button = $RightPanel/CenterContainer/VBoxContainer/PlayButton
@onready var music_toggle_btn = $RightPanel/MusicToggleButton
@onready var stash_panel = $StashPanel
@onready var xp_progress = $RightPanel/XPBar/XPProgress
@onready var xp_label = $RightPanel/XPBar/XPLabel
@onready var level_label = $RightPanel/XPBar/LevelLabel
@onready var upgrade_slots_container = $RightPanel/UpgradeSlotsPanel/UpgradeSlotsContainer

var stash_slots: Array = []
var upgrade_slots: Array = []
var hotbar_ui: Node
var selected_source_index: int = -1
var selected_source_container: String = ""
var tooltip: ItemTooltip
var trash_button: Button
var stats_label: Control

func _ready():	
	var vbox = $RightPanel/CenterContainer/VBoxContainer
	_setup_stash()
	_setup_upgrade_slots()

	var hotbar_ui_script = load("res://interface/scripts/HotbarUI.gd")
	
	hotbar_ui = hotbar_ui_script.new()
	hotbar_ui.parent_menu = self
	vbox.add_child(hotbar_ui)
	vbox.move_child(hotbar_ui, 1)
	
	play_button.pressed.connect(_on_play_pressed)
	music_toggle_btn.pressed.connect(_on_music_toggle_pressed)
	update_music_button_text()
	update_xp_display()
	
	InventoryManager.upgrades_changed.connect(_refresh_upgrades)
	Globals.level_changed.connect(_on_level_changed)
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
		slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP

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
		
		#click detection
		slot_panel.gui_input.connect(_on_stash_slot_clicked.bindv([i]))
		
		#hover detection for item tooltips
		slot_panel.mouse_entered.connect(_on_stash_slot_hover.bindv([i, true]))
		slot_panel.mouse_exited.connect(_on_stash_slot_hover.bindv([i, false]))
	
	var button_hbox = HBoxContainer.new()
	main_vbox.add_child(button_hbox)
	
	trash_button = Button.new()
	trash_button.text = "Trash"
	trash_button.pressed.connect(_on_trash_pressed)
	trash_button.modulate = Color.GRAY
	button_hbox.add_child(trash_button)
	
	#space
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	main_vbox.add_child(spacer)
	
	#tab with instructions and stats page
	var tab_container = TabContainer.new()
	tab_container.custom_minimum_size = Vector2(0, 210)
	main_vbox.add_child(tab_container)
	
	#instructons
	var instructions_panel = Panel.new()
	tab_container.add_child(instructions_panel)
	tab_container.set_tab_title(0, "Instructions")
	
	var instructions_text = RichTextLabel.new()
	instructions_text.text = "- Click an item to select it\n- Click again to deselect\n-While an item is selected, click different container to move, or the trash button to trash\n- Use Trash button to delete selected item"
	instructions_text.fit_content = true
	instructions_text.anchor_left = 0
	instructions_text.anchor_top = 0
	instructions_text.anchor_right = 1
	instructions_text.anchor_bottom = 1
	instructions_panel.add_child(instructions_text)
	
	#stats
	var stats_panel = Panel.new()
	tab_container.add_child(stats_panel)
	tab_container.set_tab_title(1, "Stats")
	stats_label = RichTextLabel.new()
	stats_label.text = "Games Entered: 0"
	stats_label.anchor_left = 0
	stats_label.anchor_top = 0
	stats_label.anchor_right = 1
	stats_label.anchor_bottom = 1
	stats_label.fit_content = true
	stats_panel.add_child(stats_label)
	
	tooltip = ItemTooltip.new()
	stash_panel.add_child(tooltip)
	
	InventoryManager.inventory_changed.connect(_refresh_all)

func _setup_upgrade_slots():
	for i in range(InventoryManager.max_upgrades_capacity):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(70, 70)
		slot_panel.modulate = Color.LIGHT_BLUE
		slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var overlay = Node2D.new()
		slot_panel.add_child(overlay)
		
		var sprite_rect = TextureRect.new()
		sprite_rect.custom_minimum_size = Vector2(55, 55)
		sprite_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		sprite_rect.position = Vector2(7, 7)
		overlay.add_child(sprite_rect)
		
		var item_label = Label.new()
		item_label.text = ""
		item_label.add_theme_font_size_override("font_size", 10)
		item_label.position = Vector2(10, 5)
		overlay.add_child(item_label)
		
		upgrade_slots_container.add_child(slot_panel)
		
		upgrade_slots.append({
			"panel": slot_panel,
			"sprite": sprite_rect,
			"name": item_label,
			"index": i
		})
		
		slot_panel.gui_input.connect(_on_upgrade_slot_clicked.bindv([i]))
		
		slot_panel.mouse_entered.connect(_on_upgrade_slot_hover.bindv([i, true]))
		slot_panel.mouse_exited.connect(_on_upgrade_slot_hover.bindv([i, false]))

func _on_stash_slot_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.pressed:
		_handle_selection(slot_index, "stash")

func _on_stash_slot_hover(slot_index: int, is_hovering: bool):
	if is_hovering:
		var item = InventoryManager.stash.get_item(slot_index)
		if not item.is_empty():
			var item_data = ItemDb.get_item_data(item.id)
			tooltip.show_tooltip(item_data)
		else:
			tooltip.hide_tooltip()
	else:
		tooltip.hide_tooltip()

func _handle_selection(slot_index: int, container: String):
	if selected_source_index == -1:
		var item = null
		if container == "stash":
			item = InventoryManager.stash.get_item(slot_index)
		elif container == "upgrades":
			item = InventoryManager.upgrades.get_item(slot_index)
		else:
			item = InventoryManager.hotbar.get_item(slot_index)
		
		var can_select = (container == "upgrades") or (not item.is_empty())
		
		if can_select:
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
	elif selected_source_container == "stash" and container == "upgrades":
		InventoryManager.move_stash_to_upgrades(selected_source_index, slot_index)
	elif selected_source_container == "upgrades" and container == "stash":
		InventoryManager.move_upgrades_to_stash(selected_source_index)
	
	selected_source_index = -1
	_refresh_all()

func _refresh_all():
	_refresh_stash()
	_refresh_stats()
	_refresh_upgrades()
	update_xp_display()
	if hotbar_ui:
		hotbar_ui.refresh_display()

func _refresh_stats():
	if stats_label:
		stats_label.text = (
			"Games Entered: %d\n" +
			"Successful Extracts: %d\n" +
			"Deaths: %d\n" +
			"Entities Killed: %d\n" +
			"Bosses Killed: %d\n" +
			"Items Collected: %d\n" +
			"XP Collected: %d"
		) % [Globals.games_entered, Globals.successful_extracts,
			Globals.deaths, Globals.entities_killed, Globals.bosses_killed,
			Globals.items_collected, Globals.xp]

func _refresh_stash():
	for slot_info in stash_slots:
		var item = InventoryManager.stash.get_item(slot_info.index)
		var panel = slot_info.panel
		
		if item.is_empty():
			panel.modulate = Color.LIGHT_BLUE
			slot_info.sprite.texture = null
			slot_info.name.text = ""
			slot_info.qty.text = ""
		else:
			panel.modulate = Color(0.6, 0.6, 0.6)
			var item_data = ItemDb.get_item_data(item.id)
			slot_info.sprite.texture = item_data.texture
			slot_info.name.text = item_data.name
			slot_info.qty.text = "Qty: %d" % item.quantity
	
	for slot_info in stash_slots:
		if slot_info.index == selected_source_index and selected_source_container == "stash":
			slot_info.panel.modulate = Color.YELLOW
	
	if selected_source_index != -1 and selected_source_container == "stash":
		trash_button.modulate = Color.WHITE
	else:
		trash_button.modulate = Color.GRAY

func _on_play_pressed():
	play_pressed.emit()

func _on_music_toggle_pressed():
	Globals.music_enabled = !Globals.music_enabled
	update_music_button_text()

func update_music_button_text():
	var enabled = "ON"
	if not Globals.music_enabled:
		enabled = "OFF"
	music_toggle_btn.text = "Music: %s" % enabled

func update_xp_display():
	var xp_needed = Globals.get_xp_for_next_level()
	var progress = Globals.get_xp_progress()
	
	level_label.text = "Level: %d/%d" % [Globals.level, Globals.MAX_LEVEL]
	xp_label.text = "%d/%d XP" % [Globals.xp, xp_needed]
	xp_progress.value = progress * 100.0
	
	xp_progress.modulate = Color.GREEN

func _on_trash_pressed():
	if selected_source_index != -1 and selected_source_container == "stash":
		Globals.add_xp(5)
		InventoryManager.stash.remove_item(selected_source_index)
		selected_source_index = -1
		selected_source_container = ""
		InventoryManager.inventory_changed.emit()
		_refresh_all()

func _on_upgrade_slot_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.pressed:
		if slot_index < InventoryManager.get_unlocked_upgrade_slots():
			_handle_selection(slot_index, "upgrades")

func _on_upgrade_slot_hover(slot_index: int, is_hovering: bool):
	if slot_index >= InventoryManager.get_unlocked_upgrade_slots():
		return
	
	if is_hovering:
		var item = InventoryManager.upgrades.get_item(slot_index)
		if not item.is_empty():
			var item_data = ItemDb.get_item_data(item.id)
			tooltip.show_tooltip(item_data)
		else:
			tooltip.hide_tooltip()
	else:
		tooltip.hide_tooltip()

func _refresh_upgrades():
	var unlocked_slots = InventoryManager.get_unlocked_upgrade_slots()
	
	for slot_info in upgrade_slots:
		var slot_index = slot_info.index
		var panel = slot_info.panel
		
		if slot_index < unlocked_slots:
			#free slots
			var item = InventoryManager.upgrades.get_item(slot_index)
			if item.is_empty():
				panel.modulate = Color.LIGHT_BLUE
				slot_info.sprite.texture = null
				slot_info.name.text = "[empty]"
			else:
				panel.modulate = Color(0.8, 0.8, 0.8)
				var item_data = ItemDb.get_item_data(item.id)
				slot_info.sprite.texture = item_data.texture
				slot_info.name.text = item_data.name
			panel.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			#lock slot
			panel.modulate = Color.RED
			slot_info.sprite.texture = null
			slot_info.name.text = ""
			panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for slot_info in upgrade_slots:
		if slot_info.index == selected_source_index and selected_source_container == "upgrades":
			slot_info.panel.modulate = Color.YELLOW

func _on_level_changed(new_level: int):
	_refresh_upgrades()


func _on_button_pressed() -> void:
	get_tree().quit()
