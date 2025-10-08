class_name Ennemy
extends CharacterBody3D

@export var health: float = 100
@export var speed: float = 1.5
@export var attack_damage: float = 10.0
@export var can_attack: bool = true
@export var player_in_range: bool = false

@onready var player : Node3D = get_tree().get_root().get_node("MainScene/Player")
@onready var model = $Model
@onready var attack_range = $AttackRange
@onready var health_bar = $HealthBar
@onready var attack_cooldown = $AttackCooldown

func _ready() -> void:
	health_bar.max_hp = health

func _process(_delta: float) -> void:
	attack()

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
		
		
func take_damage(damage: float):
	health -= damage
	health_bar.take_damage(damage)
	if(health<=0):
		die()
		
func die():
	queue_free()

func attack():
	if player_in_range and can_attack:
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
	can_attack = true;
