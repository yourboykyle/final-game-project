extends Node

@onready var container = $"../DungeonContainer"
var registry = RoomRegistry.new()

var dungeon_layout = {}
var dungeon_size = 64
var room_spacing = 768
var max_rooms = 20

const DIRS = [
	Vector2i(1,0),
	Vector2i(-1,0),
	Vector2i(0,1),
	Vector2i(0,-1)
]

func generate():

	var start = Vector2i(0,0)
	spawn_room(start, DataTypes.RoomType.START)

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
			
			var types = [DataTypes.RoomType.COMBAT, DataTypes.RoomType.TREASURE, DataTypes.RoomType.BOSS, DataTypes.RoomType.SHOP]
			var roomType = types.pick_random()
			spawn_room(next, roomType)
			frontier.append(next)

func spawn_room(grid_pos: Vector2i, roomType: DataTypes.RoomType):
	var scene = registry.get_room_scene(roomType)
	var room = scene.instantiate()

	room.initialize(grid_pos)

	room.position = Vector2(
		grid_pos.x * room_spacing,
		grid_pos.y * room_spacing
	)

	container.add_child(room)
	dungeon_layout[grid_pos] = room

func neighbor_count(pos: Vector2i):

	var count = 0

	for dir in DIRS:
		if dungeon_layout.has(pos + dir):
			count += 1

	return count
