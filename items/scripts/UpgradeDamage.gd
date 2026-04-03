extends Upgrade

func _ready():
	pass

func apply_upgrade(player: Node2D) -> void:
	player.change_damage(5)

