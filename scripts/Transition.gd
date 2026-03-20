extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

var is_transitioning: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_rect.color.a = 0.0
	layer = -1


func fade_out() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	layer = 128
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(fade_rect, "color:a", 1.0, 0.15)
	await tween.finished
	is_transitioning = false

func fade_in() -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fade_rect, "color:a", 0.0, 0.15)
	await tween.finished
	layer = -1
	is_transitioning = false
