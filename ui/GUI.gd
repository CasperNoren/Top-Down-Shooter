extends CanvasLayer

class_name GUI

onready var health_bar = $MarginContainer/Rows/BottomRow/HealthSection/HealthBar
onready var health_tween = $MarginContainer/Rows/BottomRow/HealthSection/HealthTween
onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/CurrentAmmo
onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/MaxAmmo
onready var base_label = $MarginContainer/Rows/TopRow/BaseLabel
onready var money_label = $MarginContainer/Rows/TopRow/MoneyLabel

var player: Player
var money_manager: MoneyManager

func set_player(player: Player):
	self.player = player
	
	set_new_health_value(player.health_stat.health)
	player.connect("player_health_changed", self, "set_new_health_value")
	
	set_weapon(player.weapon_manager.get_current_weapon())
	player.weapon_manager.connect("weapon_changed", self, "set_weapon")

func set_weapon(weapon: Weapon):
	set_current_ammo(weapon.current_ammo)
	set_max_ammo(weapon.max_ammo)
	if not weapon.is_connected("weapon_ammo_changed", self, "set_current_ammo"):
		weapon.connect("weapon_ammo_changed", self, "set_current_ammo")

func set_money_manager(money_manager: MoneyManager):
	self.money_manager = money_label
	money_manager.connect("money_changed", self, "set_money_label")

func set_new_health_value(new_health: int):
	var transition_time: float = 0.4
	var original_color = Color("#961515")
	var highlight_color = Color("#ee7a7a")
	var bar_style = health_bar.get("custom_styles/fg")
	health_tween.interpolate_property(health_bar, "value", health_bar.value, new_health, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	health_tween.interpolate_property(bar_style, "bg_color", original_color, highlight_color, transition_time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	health_tween.interpolate_property(bar_style, "bg_color", highlight_color, original_color, transition_time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	health_tween.start()

# Dynamically shows bases' team status, can have as many bases as fits on screen
func set_bases(bases: Array):
	var new_text: String = "[center]"
	for base in bases:
		match base.team.team:
			Team.TeamName.PLAYER:
				new_text += "[color=green]"
			Team.TeamName.ENEMY:
				new_text += "[color=blue]"
			Team.TeamName.NEUTRAL:
				new_text += "[color=white]"
		new_text += "o [/color]"
		base_label.bbcode_text = new_text

func set_money_label(new_value: int):
	money_label.bbcode_text = "[color=yellow]" + str(new_value) + "[/color]"

func set_current_ammo(new_ammo: int):
	current_ammo.text = str(new_ammo)

func set_max_ammo(new_max_ammo: int):
	max_ammo.text = str(new_max_ammo)
