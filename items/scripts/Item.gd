class_name Item extends Node2D
#Super class for all items
@export var item_name : String
@export var item_description: String = ""
@export var weight = 1
@export var sfx_volume_db: float = 2.5
@export var sfx_stream: AudioStream
"""
This comment block is to explain item ids (will remove later)
we'll input them manually for now cuz we don't have time to automate imo
Whenver you are coding and want to reference an item, use it's id rather than name so that if the name is changed code doesn't break
Conventions:
	If your item is just an item: start the id with a 1
	If your item is equippable: start id with a 2
	If your item is a weapon: start id with a 3
	If your item is an upgrade: start id with a 4
	then add the number of this particular item that has been added to the end
	put in 0s for the 10s and 100s place if not used
	
	EXAMPLE: if you made a weapon, and yours is the third created, the id would be 3003
	
	When you add an item please add it's scene to the item container scene just so we can keep items organized
	Thanks!
"""
@export var item_id : int
@export var max_stack_size: int = 5
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	max_stack_size = 5

func _process(delta):
	pass

func play_sound_effect():
	Globals.play_sfx(sfx_stream, sfx_volume_db)
