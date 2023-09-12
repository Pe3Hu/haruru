extends MarginContainer


@onready var label = $Label

var parent = null
var key = null


func set_attributes(input_: Dictionary) -> void:
	for key_ in input_:
		set(key_, input_[key_])
	
	label.text = str(key)
	
	if Global.arr.token.has(key):
		label.text = key[0]
	
	custom_minimum_size = Vector2(Global.vec.size.letter)
