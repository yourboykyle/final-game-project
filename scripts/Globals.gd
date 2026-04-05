extends Node

# Procedural generation config
const GEN_BASE_ROOMS = 10
const GEN_EXTRA_ROOMS_PER_FLOOR = 3

const GEN_TREASURE_BASE_CHANCE = 0.1
const GEN_BONUS_TREASURE_CHANCE_PER_FLOOR = 0.02
# End generation config

var dungeon_manager
var current_floor = 0

var opened_chests : Array = []
var opened_bubbles : Array = []
signal enemy_defeated(position: Vector2)
signal level_changed(new_level: int)

var oxygen_decay_rate := 1.0
var xp: int = 0
var level: int = 0
var death_disabled = false

const MAX_LEVEL = 5
const XP_PER_LEVEL = 100

var crosshair_instance
const CROSSHAIR = preload("res://interface/Crosshair.tscn")
@export var shooting_enabled = true
var music_enabled: bool = true

# Stats tracking
var games_entered: int = 0
var successful_extracts: int = 0
var deaths: int = 0
var entities_killed: int = 0
var bosses_killed: int = 0
var items_collected: int = 0

const BOX = preload("res://rooms/Box.tscn")

var ROOM_SIZE = 192 * 16 # tilemap width (in roombase) * pixels width of each tile
var ROOM_CENTER = Vector2(ROOM_SIZE / 2, ROOM_SIZE / 2)

enum RoomType {
	START,
	COMBAT,
	TREASURE,
	BOSS,
	
	# Tutorial
	TUTORIAL_START,
	TUTORIAL_MOVE,
	TUTORIAL_COMBAT,
	TUTORIAL_END,
	TUTORIAL_MAP,
	TUTORIAL_ATTACK,
	TUTORIAL_OXYGEN,
}

enum RoomExit {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

const DIR_VECTORS = {
	Direction.NORTH: Vector2i(0, -1),
	Direction.SOUTH: Vector2i(0, 1),
	Direction.EAST: Vector2i(1, 0),
	Direction.WEST: Vector2i(-1, 0)
}

const ROOM_COLORS = {
	RoomType.START: Color.FUCHSIA,
	RoomType.COMBAT: Color.RED,
	RoomType.BOSS: Color.BLUE,
	RoomType.TREASURE: Color.GOLD
}  

var spawned_rooms = {} 
var room_enemies = {} 
var room_pickups = {}
var rewards_spawned = {}
var player = null;
var doors_locked = false; 
var boss_spawned = false; 
var room_box_positions = {} 
var canvas_modulate = null 
var boss_bar = null

func remove_room_pickup(room_id, position):
	if room_pickups.has(room_id):
		room_pickups[room_id] = room_pickups[room_id].filter(
			func(p): return p["position"] != position
		)

enum ATTACK_TYPE {
	CONE,
	RECTANGLE,
	PROJECTILE
}

enum Groups {
	INTERACTABLE,
}

const GROUP_STRINGS = [
	"interactable"
]

# Health scaling:
const DIFF_HEALTH_BASE = 1.0
const DIFF_HEALTH_PER_FLOOR = 0.5

func get_health_multiplier(floor: int) -> float:
	return DIFF_HEALTH_BASE + (floor - 1) * DIFF_HEALTH_PER_FLOOR

func play_sfx(stream: AudioStream, volume_db: float = 2.5):
	if !stream:
		return
	var audio = AudioStreamPlayer.new()
	audio.stream = stream
	audio.volume_db = volume_db
	get_tree().current_scene.add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)

#XP stuffs
func get_xp_required_for_level(level: int) -> int:
	var total = 0
	for i in range(level):
		total += (i + 1) * XP_PER_LEVEL
	return total

func get_xp_for_next_level() -> int:
	if level >= MAX_LEVEL:
		return 0
	return (level + 1) * XP_PER_LEVEL

func add_xp(amount: int) -> void:
	xp += amount
	
	while level < MAX_LEVEL:
		var xp_needed = get_xp_for_next_level()
		if xp >= xp_needed:
			xp -= xp_needed
			level += 1
			level_changed.emit(level)
		else:
			break

func get_xp_progress() -> float:
	if level >= MAX_LEVEL:
		return 1.0
	var xp_needed = get_xp_for_next_level()
	return float(xp) / float(xp_needed)
