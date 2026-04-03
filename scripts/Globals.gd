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

var oxygen_decay_rate := 1.0
var xp: int = 0
var death_disabled = false

var crosshair_instance
const CROSSHAIR = preload("res://interface/Crosshair.tscn")
@export var shooting_enabled = true

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
var player = null;
var doors_locked = false; 
var boss_spawned = false; 
var room_box_positions = {}

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
