extends Node2D

signal weapon_changed(new_weapon)

onready var current_weapon: Weapon = $Pistol

var weapons: Array = []
var current_weapon_index = 0

func _ready():
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	current_weapon.show()

func _process(delta):
	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		current_weapon.shoot()

func initialize(team: int):
	for weapon in weapons:
		weapon.initialize(team)

func get_current_weapon() -> Weapon:
	return current_weapon

func reload():
	current_weapon.start_reload()

func switch_weapon(weapon: Weapon):
	# If it's the current weapon switching isn't necessary
	# If the weapon is reloading a switch shouldn't be possible 
	if weapon == current_weapon or current_weapon.animation_player.get_current_animation() == "reload":
		return
	current_weapon.hide()
	weapon.show()
	current_weapon = weapon
	current_weapon_index = weapons.find(current_weapon,0)
	emit_signal("weapon_changed", current_weapon)

func get_weapon_from_index(index: int) -> Weapon:
	if index < 0:
		index = weapons.size() - 1
	index = index % weapons.size()
	return weapons[index]

func _unhandled_input(event):
	if current_weapon.semi_auto and event.is_action_released("shoot"):
		current_weapon.shoot()
	elif event.is_action_pressed("reload"):
		reload()
	elif event.is_action_pressed("change_weapon_up"):
		var next_weapon: Weapon = get_weapon_from_index(current_weapon_index + 1)
		switch_weapon(next_weapon)
	elif event.is_action_pressed("change_weapon_down"):
		var next_weapon: Weapon = get_weapon_from_index(current_weapon_index - 1)
		switch_weapon(next_weapon)
