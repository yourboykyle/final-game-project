extends StaticBody2D

@export var wall_type : Globals.Direction
@export var thickness := 32

func _ready():
	setup_wall()

func setup_wall():
	var room_size = Globals.ROOM_SIZE
	var shape = $CollisionShape2D.shape as RectangleShape2D

	match wall_type:
		Globals.Direction.NORTH:
			position = Vector2(room_size / 2, 0)
			shape.size = Vector2(room_size, thickness)

		Globals.Direction.SOUTH:
			position = Vector2(room_size / 2, room_size)
			shape.size = Vector2(room_size, thickness)

		Globals.Direction.WEST:
			position = Vector2(0, room_size / 2)
			shape.size = Vector2(thickness, room_size)

		Globals.Direction.EAST:
			position = Vector2(room_size, room_size / 2)
			shape.size = Vector2(thickness, room_size)
