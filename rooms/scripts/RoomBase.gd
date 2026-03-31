class_name RoomBase
extends Node2D
var chest_scene = preload("res://interactables/Chest.tscn") 
var bubble_scene = preload("res://interactables/Bubble.tscn") 
var chest
var bubble

@export var room_id : String
@export var room_type : Globals.RoomType
@export var allowed_exits : Array[Globals.RoomExit] = []

var grid_position : Vector2i

func initialize(grid_pos: Vector2i):
	var gen = Globals.dungeon_manager

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.NORTH]):
		$Doors/DoorNorth.queue_free()

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.SOUTH]):
		$Doors/DoorSouth.queue_free()

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.EAST]):
		$Doors/DoorEast.queue_free()

	if !gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.WEST]):
		$Doors/DoorWest.queue_free()

func set_room_data(pos:Vector2i): 
	grid_position = pos
	room_id = str(pos)

func lock_doors(): 
	if $Doors/DoorNorth: 
		$Doors/DoorNorth.hide()
		$Doors/DoorNorth/CollisionShape2D.set_disabled(true)
	if $Doors/DoorSouth:
		$Doors/DoorSouth/CollisionShape2D.set_disabled(true)
		$Doors/DoorSouth.hide()
	if $Doors/DoorEast:
		$Doors/DoorEast/CollisionShape2D.set_disabled(true)
		$Doors/DoorEast.hide()
	if $Doors/DoorWest:
		$Doors/DoorWest/CollisionShape2D.set_disabled(true)
		$Doors/DoorWest.hide()

func unlock_doors(grid_pos:Vector2i): 
	var gen = Globals.dungeon_manager
	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.NORTH]):
		$Doors/DoorNorth/CollisionShape2D.set_disabled(false)
		$Doors/DoorNorth.show()
		print("adding north")

	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.SOUTH]):
		$Doors/DoorSouth/CollisionShape2D.set_disabled(false)
		$Doors/DoorSouth.show()
		print("adding south")

	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.EAST]):
		$Doors/DoorEast/CollisionShape2D.set_disabled(false)
		$Doors/DoorEast.show()
		print("adding east")

	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.WEST]):
		$Doors/DoorWest/CollisionShape2D.set_disabled(false)
		$Doors/DoorWest.show()
		print("adding west")
	 

func create_chest(posx, posy):
	chest = chest_scene.instantiate()
	
	add_child(chest)
	chest.connect("opened", _on_chest_opened)
	chest.position = Vector2(posx, posy)

func _on_chest_opened():
	Globals.opened_chests.append(room_id)
	if is_instance_valid(chest):
		remove_child(chest)
		chest = null

func create_bubble(posx, posy):
	bubble = bubble_scene.instantiate()
	
	add_child(bubble)
	bubble.position = Vector2(posx, posy)
