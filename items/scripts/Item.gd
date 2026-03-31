class_name Item extends Node2D
#Super class for all items
@export var item_name : String
"""
This comment block is to explain item ids (will remove later)
we'll input them manually for now cuz we don't have time to automate imo
Whenver you are coding and want to reference an item, use it's id rather than name so that if the name is changed code doesn't break
Conventions:
	If your item is just an item: start the id with a 1
	If your item is equippable: start id with a 2
	If your item is a weapon: start id with a 3
	then add the number of this particular item that has been added to the end
	put in 0s for the 10s and 100s place if not used
	
	EXAMPLE: if you made a weapon, and yours is the third created, the id would be 3003
	
	When you add an item please add it's scene to the item container scene just so we can keep items organized
	Thanks!
"""
@export var item_id : int
@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(delta):
	pass

func get_sprite():
	return sprite_2d
