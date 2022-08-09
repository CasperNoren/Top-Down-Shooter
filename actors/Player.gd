extends KinematicBody2D
class_name Player

signal player_health_changed(new_health)
signal died

export (int) var speed = 100

onready var collision_shape = $CollisionShape2D
onready var blink_target = $BlinkTarget
onready var blink_particles = $BlinkParticles
onready var weapon_manager = $WeaponManager
onready var health_stat = $Health
onready var team = $Team
onready var camera_transform = $CameraTransform

func _ready():
	weapon_manager.initialize(team.team)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var movement_direction := Vector2.ZERO
	if Input.is_action_pressed("up"):
		movement_direction.y += -1
	if Input.is_action_pressed("down"):
		movement_direction.y += 1
	if Input.is_action_pressed("left"):
		movement_direction.x += -1
	if Input.is_action_pressed("right"):
		movement_direction.x += 1
	
	movement_direction = movement_direction.normalized()
	
	move_and_slide(movement_direction * speed)
	
	look_at(get_global_mouse_position())


func _unhandled_input(event):
	if event.is_action_pressed("blink"):
		blink()

func set_camera_transform(camera_path: NodePath):
	camera_transform.remote_path = camera_path

func get_team() -> int:
	return team.team

func blink():
	blink_particles.restart()
	global_position = blink_target.global_position

func handle_hit():
	health_stat.health -= 20
	emit_signal("player_health_changed", health_stat.health)
	if health_stat.health <= 0:
		die()

func die():
	print("Player died")
	emit_signal("died")
	queue_free()
