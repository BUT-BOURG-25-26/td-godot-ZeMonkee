extends Sprite3D

@export var max_hp : int = 100

func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_hp
	$SubViewport/Panel/ProgressBar.value = max_hp


func take_damage(damage: float):
	$SubViewport/Panel/ProgressBar.value -= damage
