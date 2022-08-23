extends Node2D

class_name BuyableOption

enum OptionType {
	TEAM,
	DEFENSE,
	WEAPON
}

export (PackedScene) var item_scene = null
export (String) var signal_to_emit = ""
export (String) var shop_name = ""
export (int) var cost = 0
export (bool) var should_not_be_removed = false

export (OptionType) var option_type = OptionType.WEAPON

