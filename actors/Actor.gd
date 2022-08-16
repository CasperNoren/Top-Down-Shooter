extends KinematicBody2D

class_name Actor

signal died

onready var collision_shape = $CollisionShape2D
onready var health_stat = $Health
onready var ai = $AI
onready var weapon_manager: WeaponManager = $WeaponManager
onready var team = $Team

export (int) var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	ai.initialize(self, weapon_manager, team.team)
	weapon_manager.initialize(team.team)

func rotate_toward(location: Vector2):
	rotation = lerp_angle(rotation, global_position.direction_to(location).angle(), 0.1)
	
func velocity_toward(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed

func has_reached_position(location: Vector2) -> bool:
	return global_position.distance_to(location) < 5

func get_team() -> int:
	return team.team

func handle_hit(damage: int):
	health_stat.health -= damage
	if health_stat.health <= 0:
		die()

func die():
	emit_signal("died")
	queue_free()
