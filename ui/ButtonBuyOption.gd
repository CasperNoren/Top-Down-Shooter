extends Button

var option: int = -1

func initialize(option: int):
	self.option = option
	text = str(MoneyManager.BuyOptions.keys()[option])

func _pressed():
	print(MoneyManager.BuyOptions.keys()[option], " buy button pressed")
	GlobalSignals.emit_signal("buy_option_pressed", option)
