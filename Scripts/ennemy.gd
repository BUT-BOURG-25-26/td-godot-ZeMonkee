class_name Ennemy
extends CharacterBody3D

@export var health: float = 100
@export var speed: float = 1
@export var attack_damage: float = 10.0
@export var can_attack: bool = true
@export var player_in_range: bool = false

@onready var player : Node3D = get_tree().get_root().get_node("MainScene/Player")
@onready var model = $Model
@onready var collision = $CollisionShape3D
@onready var attack_range = $AttackRange
@onready var health_bar = $HealthBar
@onready var attack_cooldown = $AttackCooldown
@onready var dead_cooldown = $DeadCooldown
@onready var hit_cooldown = $HitCooldown
@onready var animation_player = $Model/AnimationPlayer

# Son
@onready var attack_sound = $AttackSound
@onready var hit_sound_1 = $HitSound1
@onready var hit_sound_2 = $HitSound2
@onready var death_sound = $DeathSound
@onready var hit_sound : Array[AudioStreamPlayer] = [$HitSound1, $HitSound2]

func _ready() -> void:
	health_bar.max_hp = health

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	# Direction vers le joueur
	var direction = (player.global_transform.origin - global_transform.origin)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Comportement
	if is_on_floor() and can_attack:
		if player_in_range and can_attack:
			attack()
			animation_player.play("1H_Melee_Attack_Slice_Horizontal") # Attack animation
		
		elif velocity.x != 0 or velocity.z != 0:
			animation_player.play("Walking_D_Skeletons") # Walk animation
		
		else:
			animation_player.play("Idle") # Idle animation
	
	else:
		velocity.y += get_gravity().y * delta
	
	move_and_slide()
	
	# Rotation du modèle
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, delta * 10.0)
		attack_range.rotation.y = lerp_angle(attack_range.rotation.y, target_rotation, delta * 10.0)
		
		
func take_damage(damage: float):
	health -= damage
	health_bar.take_damage(damage)
	hit_sound[randi_range(0,1)].play()
	animation_player.play("Hit_B")
	can_attack = false
	speed = 0.0
	hit_cooldown.start()
	if(health<=0):
		die()

func attack():
	speed = 0.0
	attack_sound.play()
	player.call("take_damage", attack_damage)
	can_attack = false
	attack_cooldown.start()

func _in_attack_range(body: Node3D) -> void:
	if body == player:
		player_in_range = true

func _out_attack_range(body: Node3D) -> void:
	if body == player:
		player_in_range = false
		
func _attack_cooldown_timeout() -> void:
	speed = 1.0
	can_attack = true;

func _hit_cooldown() -> void:
	speed = 1.0
	can_attack = true;

func die():
	set_process(false)
	set_physics_process(false)
	collision.queue_free()
	animation_player.play("Death_B")
	death_sound.play()
	dead_cooldown.start()

func _dead_cooldown() -> void:
	queue_free()
