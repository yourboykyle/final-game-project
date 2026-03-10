class_name Bullet extends Area2D

@export var speed = 600
var direction = Vector2.ZERO

func _ready():
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
	
