extends Node2D

class_name Weapon

signal weapon_ammo_changed(new_ammo_count)
signal weapon_out_of_ammo

export (PackedScene) var Bullet
export (int) var max_ammo = 10
export (bool) var semi_auto = true
export (bool) var debug_mode = false

var team: int = -1
var current_ammo: int = max_ammo setget set_current_ammo

onready var end_of_gun = $EndOfGun
onready var attack_cooldown = $AttackCooldown
onready var animation_player = $AnimationPlayer
onready var muzzle_flash = $MuzzleFlash
onready var muzzle_flash_particles = $MuzzleFlashParticles

func _ready():
	muzzle_flash.hide()
	current_ammo = max_ammo

func initialize(team: int):
	self.team = team

func shoot():
	# Good for testing what stops the gun from firing:
	if debug_mode:
		print("\nAmmo: " + str(current_ammo != 0) + "\nCooldown: " + str(attack_cooldown.is_stopped()) + "\nNot reloading: " + str(not animation_player.get_current_animation() == "reload") + "\nBullet Instance: " + str(Bullet != null) + "\n")
	# print(str(current_ammo != 0) + " " + str(attack_cooldown.is_stopped()) + " " + str(not animation_player.get_current_animation() == "reload") + " " + str(Bullet != null))
	if current_ammo != 0 and attack_cooldown.is_stopped() and not animation_player.get_current_animation() == "reload" and Bullet != null:
		var bullet_instance = Bullet.instance()
		var direction = (end_of_gun.global_position - global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, team, end_of_gun.global_position, direction)
		attack_cooldown.start()
		animation_player.play("MuzzleFlash")
		set_current_ammo(current_ammo - 1)
		
		muzzle_flash_particles.emitting = true

func start_reload():
	# No reason to start a reload if it's full
	if not current_ammo >= max_ammo:
		muzzle_flash.hide()
		animation_player.play("reload")
	
func _stop_reload():
	current_ammo = max_ammo
	emit_signal("weapon_ammo_changed", current_ammo)

func set_current_ammo(new_ammo: int):
	var actual_ammo = clamp(new_ammo, 0, max_ammo)
	if actual_ammo != current_ammo:
		current_ammo = actual_ammo
		if current_ammo <= 0:
			emit_signal("weapon_out_of_ammo")
		emit_signal("weapon_ammo_changed", current_ammo)
