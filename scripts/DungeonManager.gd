extends Node

@onready var container = $"../DungeonContainer"

var registry = RoomRegistry.new()

var dungeon_layout = {}
var dungeon_size = 64
var room_spacing = Globals.room_size
var max_rooms = 20

var current_room = null
var current_grid = Vector2i.ZERO
var changing_room = false

const DIRS = [
	Vector2i(1,0),
	Vector2i(-1,0),
	Vector2i(0,1),
	Vector2i(0,-1)
]

func _ready():
	Globals.dungeon_generator = self

func generate():

	dungeon_layout.clear()

	var start = Vector2i(0,0)
	add_room(start, Globals.RoomType.START)

	var frontier = [start]

	while frontier.size() > 0 and dungeon_layout.size() < max_rooms:

		var current = frontier.pick_random()

		for dir in DIRS:

			if randi() % 2 == 0:
				continue

			var next = current + dir

			if dungeon_layout.has(next):
				continue
			
			if neighbor_count(next) > 1:
				continue

			var types = [
				Globals.RoomType.COMBAT,
				Globals.RoomType.TREASURE,
				Globals.RoomType.BOSS,
				Globals.RoomType.SHOP
			]

			var roomType = types.pick_random()

			add_room(next, roomType)
			frontier.append(next)

	# load the starting room
	load_room(start)


func add_room(grid_pos: Vector2i, roomType: Globals.RoomType):

	var scene = registry.get_room_scene(roomType)

	dungeon_layout[grid_pos] = {
		"type": roomType,
		"scene": scene
	}


func load_room(grid_pos: Vector2i):
	# remove previous room
	if current_room:
		current_room.queue_free()

	var room_data = dungeon_layout[grid_pos]

	current_room = room_data.scene.instantiate()

	current_room.initialize(grid_pos)

	container.add_child(current_room)

	current_grid = grid_pos
	
	var player = $"../Player"
	var player_spawn_coords = Globals.room_size / 2
	player.position = Vector2(player_spawn_coords, player_spawn_coords)


func change_room(direction: Globals.Direction):
	if changing_room: return
	changing_room = true
	
	var dir = Globals.DIR_VECTORS[direction]

	var next = current_grid + dir

	if dungeon_layout.has(next):
		load_room(next)
	
	await get_tree().create_timer(0.5).timeout
	changing_room = false


func neighbor_count(pos: Vector2i):

	var count = 0

	for dir in DIRS:
		if dungeon_layout.has(pos + dir):
			count += 1

	return count
