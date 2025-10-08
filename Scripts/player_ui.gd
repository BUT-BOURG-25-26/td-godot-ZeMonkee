extends Sprite3D

@export var max_hp : int = 100

func _ready() -> void:
	$Panel/ProgressBar.max_value = max_hp
	$Panel/ProgressBar.value = max_hp


func take_damage(damage: float):
	$Panel/ProgressBar.value -= damage
