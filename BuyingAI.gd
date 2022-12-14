extends Node2D

class_name BuyingAI

signal buying_ai_choose_option(option)

# Should have priorities like: 
# 	if the player has more actors -> prioritize more actors
# 	if only the home base is left -> prioritize turrets
# 	else -> buy weapons
# Maybe priority should be an int that can be changed depending on factors?
# Maybe BuyableOption should have an export enum with type like: upgrade, defense, team
export (bool) var choose_random = false

# If scene structure changes the refrence can just be put here
onready var information_source: MapAI = get_parent().get_parent()

var available_options: Array = []
var money: int = 0

# Information:
var amount_of_bases_owned: int = 0
var amount_of_bases_opponents_own: int = 0
var total_bases: int = 0
var team_max_units_alive: int = 0
var amount_of_turrets: int = 0

func choose_next_purchase():
	print("BuyingAI: ", money)
	if money <= 0 or available_options.size() <= 0:
		return
	var choosen_option: BuyableOption = null
	
	if choose_random:
		choosen_option = available_options[randi() % available_options.size()]
	else:
		update_information()
		# All options of a certain type can run out and in that case the option shouldn't be choosable
		var chooseable_types: Array = []
		for option_type in BuyableOption.OptionType.size():
			for option in available_options:
				if option_type == option.option_type:
					chooseable_types.append(option_type)
					break
		# For debugging:
		var debug_print_chooseable_types = "Chooseable Types: "
		for type in chooseable_types:
			debug_print_chooseable_types += str(BuyableOption.OptionType.keys()[type]) + " "
		print(debug_print_chooseable_types)
		
		var choosen_type: int = BuyableOption.OptionType.WEAPON
		var available_options_with_choosen_type: Array = []
		
		# Chooses what buy option is best
		if amount_of_bases_opponents_own >= total_bases - 1 and chooseable_types.find(BuyableOption.OptionType.DEFENSE) != -1:
			# Team only has one (or less) bases left, should really buy turrets to defend 
			choosen_type = BuyableOption.OptionType.DEFENSE
		elif team_max_units_alive < 10 and chooseable_types.find(BuyableOption.OptionType.TEAM) != -1:
			choosen_type = BuyableOption.OptionType.TEAM
		elif amount_of_turrets < 1 and chooseable_types.find(BuyableOption.OptionType.DEFENSE) != -1:
			choosen_type = BuyableOption.OptionType.DEFENSE
		elif team_max_units_alive < 15 and chooseable_types.find(BuyableOption.OptionType.TEAM) != -1:
			choosen_type = BuyableOption.OptionType.TEAM
		elif amount_of_turrets < 2 and team_max_units_alive >= 15 and chooseable_types.find(BuyableOption.OptionType.DEFENSE) != -1:
			# Needs to have the team check so it gets the chance to buy guns
			choosen_type = BuyableOption.OptionType.DEFENSE
		elif chooseable_types.find(BuyableOption.OptionType.WEAPON) != -1:
			choosen_type = BuyableOption.OptionType.WEAPON
		else:
			# Team can never run out so it is the default
			choosen_type = BuyableOption.OptionType.TEAM
		
		# Get all options with the choosen type
		for option in available_options:
			if option.option_type == choosen_type:
				available_options_with_choosen_type.append(option)
		
		#print("BuyingAI: options with type: ", available_options_with_choosen_type)
		# Should probably be checked beforehand to see that there are available options of the choosen type
		if available_options_with_choosen_type.size() > 0:
			# Picks random from the ones with the type instead of choosing any available_option randomly
			choosen_option = available_options_with_choosen_type[randi() % available_options_with_choosen_type.size()]
			#print("choosen: ", choosen_option)
	
	if choosen_option == null:
		print("BuyingAI didn't choose an option")
		return
	print("BuyingAI choose: ", choosen_option.shop_name)
	emit_signal("buying_ai_choose_option", choosen_option)

# So if scene structure changes or different information is needed this is more scalable
func update_information():
	#print("BuyingAI source: ", information_source)
	#print("BuyingAI bases: ", information_source.capturable_bases)
	amount_of_bases_owned = number_of_bases_owned_by_team(information_source.capturable_bases, information_source.team_name)
	amount_of_bases_opponents_own = number_of_bases_owned_by_opponent(information_source.capturable_bases, information_source.team_name)
	total_bases = information_source.capturable_bases.size()
	team_max_units_alive = information_source.max_units_alive
	amount_of_turrets = information_source.get_amount_of_turrets()
	#print("BuyingAI team owned bases: ", amount_of_bases_owned)
	#print("BuyingAI opponent owned bases: ", amount_of_bases_opponents_own)

func number_of_bases_owned_by_team(bases: Array, team: int) -> int:
	var amount_of_bases: int = 0
	for base in bases:
		if base.team.team == team:
			amount_of_bases += 1
	return amount_of_bases

# It needs to be different to be more dynamic
func number_of_bases_owned_by_opponent(bases: Array, team: int) -> int:
	var amount_of_bases: int = 0
	for base in bases:
		# No need to hardcode in what the opponent's team is
		if base.team.team != team and base.team.team != Team.TeamName.NEUTRAL:
			amount_of_bases += 1
	return amount_of_bases

# Returns all options that aren't removed
func set_available_options(all_options: Array, removed_options: Array) -> Array:
	available_options = []
	for option in all_options:
		# -1 means that the option is not in the list
		if removed_options.find(option) == -1:
			available_options.append(option)
	return available_options

func set_money(money: int):
	self.money = money 
