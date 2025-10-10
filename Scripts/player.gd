class_name Player
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.0
@export var camera: Camera3D
@export var attack_damage: float = 20.0
@export var health: float = 100.0
@export var can_attack: bool = true
@export var blocking: bool = false

@onready var health_bar = $Player_ui
@onready var model = $Model
@onready var attack_range = $AttackRange
@onready var death_screen = $DeathScreen
@onready var animation_player = $Model/AnimationPlayer
@onready var attack_cooldown = $AttackCooldown
@onready var attack_sound = $AttackSound

var attack_range_list = []

func _physics_process(delta: float) -> void:
	var move_inputs = read_move_input()
	var direction = (transform.basis * move_inputs).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Comportement
	if is_on_floor() and can_attack:
		if Input.is_action_just_pressed("attack"):
			animation_player.play("1H_Melee_Attack_Slice_Horizontal") # Attack animation
			attack_input()
		
		elif Input.is_action_pressed("block"):
			animation_player.play("Blocking")
			blocking_input()
		
		elif Input.is_action_just_released("block"):
			unblocking_input()
		
		elif Input.is_action_just_pressed("jump"):
			animation_player.play("Jump_Idle") # Jump animation
			velocity.y = jump_force
		
		elif velocity.x != 0 or velocity.z != 0:
			animation_player.play("Running_A") # Walk animation
		
		else:
			animation_player.play("Idle") # Idle animation
	
	else:
		velocity.y += get_gravity().y * delta
		
	move_and_slide()
	
	# Tourner le modèle
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, delta * 10.0)
		attack_range.rotation.y = lerp_angle(attack_range.rotation.y, target_rotation, delta * 10.0)

func read_move_input() -> Vector3:
	var move_inputs: Vector3
	move_inputs.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_inputs.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	move_inputs = move_inputs.normalized()
	return move_inputs


func attack_input():
	can_attack = false
	speed = 0.0
	attack_sound.play()
	for ennemy in attack_range_list:
		ennemy.call("take_damage", attack_damage)
	attack_cooldown.start()
	
func blocking_input():
	blocking = true
	speed = 0.0

func unblocking_input():
	blocking = false
	speed = 5.0

func _add_attack_list(body: Node3D) -> void:
	if("Ennemy" in body.name):
		attack_range_list.append(body)

func _remove_attack_list(body: Node3D) -> void:
	if("Ennemy" in body.name):
		attack_range_list.erase(body)
		
func take_damage(damage: float):
	if(health > 0) and not blocking:
		health -= damage
		health_bar.take_damage(damage)
		if(health <= 0):
			die()
		
func die():
	set_process(false)
	set_physics_process(false)
	animation_player.play("Death_B")
	death_screen.call("show_death_screen")
	

func _attack_cooldown() -> void:
	can_attack = true
	speed = 5.0
