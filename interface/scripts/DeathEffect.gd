extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false

func show_effect() -> void:
	visible = true
	if animation_player:
		animation_player.play("pulse")
	
func hide_effect() -> void:
	visible = false
	if animation_player:
		animation_player.stop()
