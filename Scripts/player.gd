class_name Player
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 5.0
@export var camera: Camera3D

@onready var model = $Model
@onready var attack_range = $AttackRange

var attack_range_list = []

func _process(delta: float) -> void:
	attack_input()

func _physics_process(delta: float) -> void:
	var move_inputs = read_move_input()
	var direction = (transform.basis * move_inputs).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Gravité / saut
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
	else:
		velocity.y += get_gravity().y * delta

	move_and_slide()

	# Tourner le modèle
	if direction.length() > 0.01:
		var target_rotation = atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, delta * 10.0)
		attack_range.rotation.y = lerp_angle(attack_range.rotation.y, target_rotation, delta * 10.0)

func read_move_input() -> Vector3:
	var move_inputs: Vector3
	move_inputs.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_inputs.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	move_inputs = move_inputs.normalized()
	return move_inputs


func attack_input():
	if Input.is_action_just_pressed("attack"):
		for ennemy in attack_range_list:
			ennemy.call("damage")
		

func _add_attack_list(body: Node3D) -> void:
	if("Ennemy" in body.name):
		attack_range_list.append(body)


func _remove_attack_list(body: Node3D) -> void:
	if("Ennemy" in body.name):
		attack_range_list.erase(body)
