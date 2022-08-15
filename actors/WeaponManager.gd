extends Node2D

class_name WeaponManager

signal weapon_changed(new_weapon)

onready var current_weapon: Weapon = $Pistol

var weapons: Array = []
var current_weapon_index = 0

# TODO: Make general for actors and make the player's weapon manager an extension (using inheritance)

func _ready():
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	current_weapon.show()

func initialize(team: int):
	for weapon in weapons:
		weapon.initialize(team)

func get_current_weapon() -> Weapon:
	return current_weapon

# Used by AI to connect signals 
func get_all_weapons() -> Array:
	return weapons

func add_weapon(weapon: Weapon):
	# Don't want duplicates in array
	if not weapons.has(weapon):
		# If it is not added as a child it won't actually be useable
		add_child(weapon)
		weapons.append(weapon)
		weapon.hide()

func shoot():
	current_weapon.shoot()

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

func switch_to_random_weapon():
	# Using get_weapon_from_index() is not strictly necessary but it feels safer
	var new_weapon = get_weapon_from_index(randi() % weapons.size())
	switch_weapon(new_weapon)
