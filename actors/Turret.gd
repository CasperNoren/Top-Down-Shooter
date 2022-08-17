extends Node2D

enum State {
	IDLE,
	ENGAGE
}

export (Team.TeamName) var team_name = Team.TeamName.NEUTRAL

onready var team = $Team
onready var weapon_manager = $WeaponManager
onready var turret_gun = $WeaponManager/TurretGun

var current_state: int = State.IDLE setget set_state
var target: KinematicBody2D = null

func _ready():
	weapon_manager.initialize(team.team)
	for weapon in weapon_manager.get_all_weapons():
		weapon.connect("weapon_out_of_ammo", self, "handle_reload")
	# Default for all weapon managers are pistol so a switch is necessary
	weapon_manager.switch_weapon(turret_gun)

func _physics_process(delta):
	# This is a simplified version of the AI script
	match (current_state):
		State.IDLE:
			pass
		State.ENGAGE:
			if target != null and weapon_manager != null:
				rotate_toward(target.global_position)
				if abs(global_position.angle_to(target.global_position)) <= 0.1:
					weapon_manager.shoot()
			else:
				print("Error: Turret engage state but no weapon/target")

func rotate_toward(location: Vector2):
	rotation = lerp_angle(rotation, global_position.direction_to(location).angle(), 0.1)

func set_state(new_state: int):
	if new_state == current_state:
		return
	current_state = new_state

func handle_reload():
	# Turret shouldn't have to reload but it's good to have just in case
	weapon_manager.reload()

func _on_DetectionZone_body_entered(body):
	if body.has_method("get_team") and body.get_team() != team.team:
		set_state(State.ENGAGE)
		target = body


func _on_DetectionZone_body_exited(body):
	if target and body == target:
		set_state(State.IDLE)
		target = null
