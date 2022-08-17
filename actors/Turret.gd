extends Node2D

enum State {
	IDLE,
	ENGAGE
}

export (Team.TeamName) var team_name = Team.TeamName.NEUTRAL

onready var detection_zone = $DetectionZone
onready var weapon_manager = $WeaponManager
onready var turret_gun = $WeaponManager/TurretGun

var current_state: int = State.IDLE setget set_state
var target: KinematicBody2D = null
var team: int = Team.TeamName.NEUTRAL

func _ready():
	for weapon in weapon_manager.get_all_weapons():
		weapon.connect("weapon_out_of_ammo", self, "handle_reload")
	# Default for all weapon managers are pistol so a switch is necessary
	weapon_manager.switch_weapon(turret_gun)

func initialize(team: int):
	self.team = team
	weapon_manager.initialize(team)

func _physics_process(delta):
	# This is a simplified version of the AI script
	match (current_state):
		State.IDLE:
			# TODO: Make idle animation like slowly spinning back and forth
			pass
		State.ENGAGE:
			if not is_instance_valid(target):
				# TODO: Make this change in the actor AI Script
				handle_target_gone()
				return
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
	# Turret gun technically doesn't have infinite ammo, it just reloads instantly
	weapon_manager.reload()

func _on_DetectionZone_body_entered(body):
	# Not initialized yet
	if team == Team.TeamName.NEUTRAL:
		return
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ENGAGE)
		target = body


func _on_DetectionZone_body_exited(body):
	if target and body == target:
		handle_target_gone()

func handle_target_gone():
	# Not initialized yet
	if team == Team.TeamName.NEUTRAL:
		return
	# TODO: Make this change in the actor AI Script
	for body in detection_zone.get_overlapping_bodies():
			if body.has_method("get_team") and body.get_team() != team:
				set_state(State.ENGAGE)
				target = body
				return
	set_state(State.IDLE)
	target = null
