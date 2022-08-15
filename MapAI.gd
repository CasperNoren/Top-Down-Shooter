extends Node2D


enum BaseCaptureStartOrder {
	FIRST,
	LAST
}

export (Team.TeamName) var team_name = Team.TeamName.NEUTRAL
export (BaseCaptureStartOrder) var base_capture_start_order
export (PackedScene) var unit = null
export (int) var max_units_alive = 4

var target_base: CapturableBase = null
var capturable_bases: Array = []
var respawn_points: Array = []
var next_spawn_to_use: int = 0
var pathfinding: PathFinding
var bought_weapons_array: Array = []

onready var team = $Team
onready var unit_container = $UnitContainer
onready var respawn_timer = $RespawnTimer
onready var money_manager = $MoneyManager
onready var bought_weapons_container = $BoughtWeaponsContainer

func initialize(capturable_bases: Array, respawn_points: Array, pathfinding: PathFinding):
	if capturable_bases.size() == 0 or respawn_points.size() == 0 or unit == null:
		push_error("MapAI not initialized")
		return
	team.team = team_name
	
	money_manager.initialize(team.team)
	money_manager.connect("bought_weapon", self, "add_weapon_to_team")
	
	self.pathfinding = pathfinding
	self.capturable_bases = capturable_bases
	self.respawn_points = respawn_points
	for respawn in respawn_points:
		spawn_unit(respawn.global_position)
	
	for base in capturable_bases:
		base.connect("base_captured", self, "handle_base_captured")
	
	check_for_next_capturable_bases()

func handle_base_captured(_new_team: int):
	check_for_next_capturable_bases()

func check_for_next_capturable_bases():
	var next_base = get_next_capturable_base()
	if next_base != null:
		target_base = next_base
		assign_next_capturable_base_to_units(next_base)

func get_next_capturable_base():
	#Assume base capture start order is first
	var list_of_bases = range(capturable_bases.size())
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_bases = range(capturable_bases.size() - 1, -1, -1)
	for i in list_of_bases:
		var base: CapturableBase = capturable_bases[i]
		if team.team != base.team.team:
			print("Assigning team: ", team.team, " to capture base: ", i)
			return base
	
	return null


func assign_next_capturable_base_to_units(base: CapturableBase):
	for unit in unit_container.get_children():
		set_unit_ai_to_advance_to_next_base(unit)

func spawn_unit(spawn_location: Vector2):
	var unit_instance = unit.instance()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died", self, "handle_unit_death")
	unit_instance.ai.pathfinding = pathfinding
	set_unit_ai_to_advance_to_next_base(unit_instance)
	
	for weapon in bought_weapons_array:
		unit_instance.weapon_manager.add_weapon(weapon.instance())
	# There is a switch to random weapon in AI but that is activated before all the bought ...
	# ... weapons are added
	unit_instance.weapon_manager.switch_to_random_weapon()
	
	print(team.team, " spawned: ", unit, " at: ", spawn_location)

func set_unit_ai_to_advance_to_next_base(unit: Actor):
	if target_base != null:
		var ai: AI = unit.ai
		ai.next_base = target_base.get_random_position_within_capture_radius()
		# AI shouldn't stop a fight just because a new base has been set
		if ai.current_state == ai.State.ENGAGE:
			return
		ai.set_state(AI.State.ADVANCE)

func handle_unit_death():
	if respawn_timer.is_stopped() and unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()

func _on_RespawnTimer_timeout():
	var respawn = respawn_points[next_spawn_to_use]
	spawn_unit(respawn.global_position)
	#Possible substitute: next_spawn_to_use = next_spawn_to_use + 1 % repawn_points.size()
	next_spawn_to_use += 1
	if next_spawn_to_use == respawn_points.size():
		next_spawn_to_use = 0
	
	if unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()

func add_weapon_to_team(weapon):
	# Don't want duplicates
	if bought_weapons_array.has(weapon):
		return
	bought_weapons_array.append(weapon)
	
	for unit in unit_container.get_children():
		unit.weapon_manager.add_weapon(weapon.instance())
