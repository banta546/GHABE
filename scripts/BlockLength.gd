extends ProgressBar

var label:Label

func _ready():
	label = $BlockLengthLabel
	self.max_value = 1800000
	label.text = "1800000 / 1800000"

func set_max_length(value:int):
	self.max_value = value
	label.text = "{x} / {y}".format({"x":self.max_value-self.value, "y":self.max_value})

func set_current_length(value:int):
	self.value = value
	label.text = "{x} / {y}".format({"x":self.max_value-self.value, "y":self.max_value})
