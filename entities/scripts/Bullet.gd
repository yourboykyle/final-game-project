class_name Bullet extends Area2D

@onready var weapon_holder = get_node("/root/Main/Player/WeaponHolder")
var speed = 800
var damage = 0

var direction = Vector2.ZERO

func _ready():
	damage = weapon_holder.get_child(0).damage
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
	

func _on_body_entered(body):
	if body.has_method("take_damage"):
		
		body.take_damage(damage)
	
	queue_free()
