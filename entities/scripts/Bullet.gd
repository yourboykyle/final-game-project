class_name Bullet extends Area2D

var speed = 800
var damage = 0
@onready var sprite_2d: Sprite2D = $Sprite2D

var direction = Vector2.ZERO 
var shooter = ""

func _ready():
	rotation = direction.angle()
	Globals.player.died.connect(bullet_death)

func _process(delta):
	position += direction * speed * delta 
	if Globals.dungeon_manager.changing_room: 
		queue_free()

func bullet_death(): 
	queue_free() 
		

func _on_body_entered(body):
	if body == shooter: 
		return
	if body.has_method("take_damage"):
		
		body.take_damage(damage)
	
	queue_free() 



 
