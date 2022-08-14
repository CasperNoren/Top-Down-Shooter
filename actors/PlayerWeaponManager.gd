extends "res://actors/WeaponManager.gd"


func _process(delta):
	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		shoot()

func _unhandled_input(event):
	if current_weapon.semi_auto and event.is_action_released("shoot"):
		shoot()
	elif event.is_action_pressed("reload"):
		reload()
	elif event.is_action_pressed("change_weapon_up"):
		var next_weapon: Weapon = get_weapon_from_index(current_weapon_index + 1)
		switch_weapon(next_weapon)
	elif event.is_action_pressed("change_weapon_down"):
		var next_weapon: Weapon = get_weapon_from_index(current_weapon_index - 1)
		switch_weapon(next_weapon)
