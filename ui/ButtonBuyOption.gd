extends Button

var option: BuyableOption = null

func initialize(option: BuyableOption):
	self.option = option
	var button_text = option.shop_name + " " + str(option.cost) + "g"
	text = button_text

func _pressed():
	print(option.shop_name, " buy button pressed")
	GlobalSignals.emit_signal("buy_option_pressed", option)
