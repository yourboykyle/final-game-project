extends Node2D

@export var map_size = Vector2(180, 180)

var room_pixel_size = 0.0
var room_positions = {}
var min_bounds = Vector2i.ZERO

func _ready():
	var viewport = get_viewport_rect().size
	position = Vector2(viewport.x - map_size.x - 20, 20)

	build_minimap()
	queue_redraw()


func build_minimap():

	var dungeon = Globals.dungeon_manager
	if dungeon == null:
		return

	var rooms = dungeon.dungeon_layout.keys()
	if rooms.is_empty():
		return

	# --- Find bounds ---
	var min_x = rooms[0].x
	var max_x = rooms[0].x
	var min_y = rooms[0].y
	var max_y = rooms[0].y

	for r in rooms:
		min_x = min(min_x, r.x)
		max_x = max(max_x, r.x)
		min_y = min(min_y, r.y)
		max_y = max(max_y, r.y)

	min_bounds = Vector2i(min_x, min_y)

	var width = max_x - min_x + 1
	var height = max_y - min_y + 1

	# --- Compute pixel size so everything fits ---
	room_pixel_size = min(
		map_size.x / width,
		map_size.y / height
	)

	# --- Cache room positions ---
	room_positions.clear()

	for grid in rooms:

		var norm = Vector2(
			grid.x - min_x,
			grid.y - min_y
		)

		var pos = norm * room_pixel_size

		room_positions[grid] = pos


func _process(_delta):
	queue_redraw()


func _draw():

	var dungeon = Globals.dungeon_manager
	if dungeon == null:
		return

	# draw rooms
	for grid in room_positions.keys():

		var pos = room_positions[grid]

		var rect = Rect2(
			pos,
			Vector2(room_pixel_size, room_pixel_size)
		)

		var room_data = dungeon.dungeon_layout[grid]
		var room_type = room_data["type"]

		var color = Globals.ROOM_COLORS.get(room_type, Color.GRAY)

		draw_rect(rect, color)

	# current room
	var player_grid = dungeon.current_grid

	if room_positions.has(player_grid):

		var pos = room_positions[player_grid]

		var rect = Rect2(
			pos,
			Vector2(room_pixel_size, room_pixel_size)
		)

		draw_rect(rect, Color.GREEN)
