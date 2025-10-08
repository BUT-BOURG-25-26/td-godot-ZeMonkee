class_name Ennemy
extends CharacterBody3D

@export var health: float = 100
@export var speed: float = 1.5
@onready var player : Node3D = get_tree().get_root().get_node("MainScene/Player")
@onready var model = $Model
@onready var attack_range = $AttackRange
@onready var health_bar = $HealthBar

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	# Direction vers le joueur
	var direction = (player.global_transform.origin - global_transform.origin)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Gravité
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0

	move_and_slide()

	# Rotation du modèle
	if direction.length() > 0.01:
		var target_rotation = atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, delta * 10.0)
		attack_range.rotation.y = lerp_angle(attack_range.rotation.y, target_rotation, delta * 10.0)
		
		
func damage():
	health -= 10
	health_bar.take_damage(10)
	if(health<=0):
		die()
		
func die():
	queue_free()
	
	
