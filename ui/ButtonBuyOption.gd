extends Button

var option: BuyableOption = null

func initialize(option: BuyableOption):
	self.option = option
	text = option.shop_name

func _pressed():
	print(option.shop_name, " buy button pressed")
	GlobalSignals.emit_signal("buy_option_pressed", option)
