extends Weapon


export (int) var bullets_per_shot = 10
export (int) var bullet_spread = 10

#onready var muzzle_flash_particles = $MuzzleFlashParticles

# TODO: Sometimes the weapon isn't shoot despite everything working. The click doesn't seem to ...
# ... reach the shoot() function
func shoot():
	if debug_mode:
		print("\nAmmo: " + str(current_ammo != 0) + "\nCooldown: " + str(attack_cooldown.is_stopped()) + "\nNot reloading: " + str(not animation_player.get_current_animation() == "reload") + "\nBullet Instance: " + str(Bullet != null) + "\n")
	if current_ammo != 0 and attack_cooldown.is_stopped() and not animation_player.get_current_animation() == "reload" and Bullet != null:
		for n in bullets_per_shot:
			var bullet_instance = Bullet.instance()
			var spread_for_bullet: Vector2 = Vector2(rand_range(- bullet_spread, bullet_spread), 0)
			var direction = (end_of_gun.global_position - global_position + spread_for_bullet).normalized()
			GlobalSignals.emit_signal("bullet_fired", bullet_instance, team, end_of_gun.global_position, direction)
		attack_cooldown.start()
		animation_player.play("MuzzleFlash")
		set_current_ammo(current_ammo - 1)
		
		muzzle_flash_particles.emitting = true
