class_name RoomBase
extends Node2D
var chest_scene = preload("res://interactables/Chest.tscn") 
var bubble_scene = preload("res://interactables/Bubble.tscn") 
var chests: Array = []
var bubble

@export var room_id : String
@export var room_type : Globals.RoomType
@export var allowed_exits : Array[Globals.RoomExit] = []

var grid_position : Vector2i

func initialize(grid_pos: Vector2i):
	var gen = Globals.dungeon_manager 
	Globals.doors_locked = false

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
	Globals.doors_locked = true

func unlock_doors(grid_pos:Vector2i): 
	var gen = Globals.dungeon_manager
	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.NORTH]):
		$Doors/DoorNorth/CollisionShape2D.set_deferred("disabled", false)
		$Doors/DoorNorth.show()
		print("adding north")

	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.SOUTH]):
		$Doors/DoorSouth/CollisionShape2D.set_deferred("disabled", false)
		$Doors/DoorSouth.show()
		print("adding south")

	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.EAST]):
		$Doors/DoorEast/CollisionShape2D.set_deferred("disabled", false)
		$Doors/DoorEast.show()
		print("adding east")

	if gen.dungeon_layout.has(grid_pos + Globals.DIR_VECTORS[Globals.Direction.WEST]):
		$Doors/DoorWest/CollisionShape2D.set_deferred("disabled", false)
		$Doors/DoorWest.show()
		print("adding west") 
	
	Globals.doors_locked = false
	 

func create_chest(posx, posy):
	if Globals.opened_chests.has(room_id):
		return
	
	var new_chest = chest_scene.instantiate()
	add_child(new_chest)
	new_chest.position = Vector2(posx, posy)
	new_chest.connect("opened", _on_chest_opened.bind(new_chest))
	chests.append(new_chest)

func _on_chest_opened(chest_instance):
	if is_instance_valid(chest_instance):
		Globals.remove_room_pickup(room_id, chest_instance.position)
		remove_child(chest_instance)
		chests.erase(chest_instance)
	
	if chests.is_empty():
		Globals.opened_chests.append(room_id)

func create_bubble(posx, posy):
	if Globals.opened_bubbles.has(room_id):
		return
	
	if !bubble:
		bubble = bubble_scene.instantiate()
	
	add_child(bubble)
	bubble.connect("used", _on_bubble_used)
	bubble.position = Vector2(posx, posy)

func _on_bubble_used():
	Globals.opened_bubbles.append(room_id)
	if is_instance_valid(bubble):
		remove_child(bubble)
		Globals.remove_room_pickup(room_id, self.position)
		bubble = null
	
