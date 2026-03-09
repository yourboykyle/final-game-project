extends Area2D

var speed = 600
var direction = Vector2.ZERO

func _ready():
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
