extends Weapon


func start_reload():
	# Turret gun has "infinite" ammo, achieved by reloading instantly
	current_ammo = max_ammo
	emit_signal("weapon_ammo_changed", current_ammo)
