extends Node

@onready var container = $"../DungeonContainer"

var registry = RoomRegistry.new()

var dungeon_layout = {}
var dungeon_size = 64
var room_spacing = Globals.ROOM_SIZE
var max_rooms = 0

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
	Globals.dungeon_manager = self

func generate():
	dungeon_layout.clear()

	# scale dungeon size with floor
	max_rooms = Globals.GEN_BASE_ROOMS + Globals.current_floor * Globals.GEN_EXTRA_ROOMS_PER_FLOOR

	var start = Vector2i(0,0)
	add_room(start, Globals.RoomType.START)

	var frontier = [start]

	# Generate main layout (using just combat rooms, special ones added later)
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

			add_room(next, Globals.RoomType.COMBAT)
			frontier.append(next)

	# Assign special rooms after generation
	assign_special_rooms()

	# load the starting room
	load_room(start, null)

	$"../CanvasLayer/GameplayUI/Minimap".build_minimap()


func add_room(grid_pos: Vector2i, roomType: Globals.RoomType):

	dungeon_layout[grid_pos] = {
		"type": roomType
	}


func load_room(grid_pos: Vector2i, entry_dir: Variant = null):
	# remove previous room
	if current_room:
		current_room.queue_free()

	var room_data = dungeon_layout[grid_pos]

	# get correct scene based on FINAL type
	var scene = registry.get_room_scene(room_data["type"])
	current_room = scene.instantiate()

	current_room.initialize(grid_pos)

	container.add_child(current_room)

	current_grid = grid_pos
	
	# Adjust the player's position based on entry direction
	var player = $"../DungeonContainer/Player"
	var center = Globals.ROOM_SIZE / 2
	var spawn = Globals.ROOM_CENTER

	var offset = 120

	if entry_dir != null:
		match entry_dir:
			Globals.Direction.NORTH:
				spawn = Vector2(center, Globals.ROOM_SIZE - offset)

			Globals.Direction.SOUTH:
				spawn = Vector2(center, offset)

			Globals.Direction.EAST:
				spawn = Vector2(offset, center)

			Globals.Direction.WEST:
				spawn = Vector2(Globals.ROOM_SIZE - offset, center)

	player.position = spawn


func change_room(direction: Globals.Direction):
	if changing_room: return
	changing_room = true
	
	var dir = Globals.DIR_VECTORS[direction]
	var next = current_grid + dir

	if dungeon_layout.has(next):
		load_room(next, direction)
	
	await get_tree().create_timer(0.5).timeout
	changing_room = false


func neighbor_count(pos: Vector2i):

	var count = 0

	for dir in DIRS:
		if dungeon_layout.has(pos + dir):
			count += 1

	return count


# Special room assignment

func assign_special_rooms():
	assign_boss_room()
	assign_treasure_rooms()


func assign_boss_room():
	var farthest = Vector2i.ZERO
	var max_dist = -1

	for pos in dungeon_layout.keys():
		if pos == Vector2i.ZERO:
			continue
		
		var dist = pos.length_squared()
		if dist > max_dist:
			max_dist = dist
			farthest = pos

	if dungeon_layout.has(farthest):
		dungeon_layout[farthest]["type"] = Globals.RoomType.BOSS


func assign_treasure_rooms():
	var floor = Globals.current_floor
	
	# base + scaling
	var chance = Globals.GEN_TREASURE_BASE_CHANCE + (floor * Globals.GEN_BONUS_TREASURE_CHANCE_PER_FLOOR)

	for pos in dungeon_layout.keys():
		if pos == Vector2i.ZERO:
			continue
		
		if dungeon_layout[pos]["type"] != Globals.RoomType.COMBAT:
			continue
		
		if randf() < chance:
			dungeon_layout[pos]["type"] = Globals.RoomType.TREASURE
