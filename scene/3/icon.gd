extends MarginContainer


@onready var label = $Label
@onready var tr = $TextureRect

var type = null
var subtype = null


func set_attributes(input_: Dictionary) -> void:
	type  = input_.type
	subtype  = input_.subtype
#	for key_ in input_:
#		set(key_, input_[key_])
#
#	label.text = str(key)
#
#	if Global.arr.token.has(key):
#		label.text = key[0]
	
	custom_minimum_size = Vector2(Global.vec.size.letter)
	var path = "res://asset/png/icon/"
	
	match type:
		"resource":
			custom_minimum_size = Vector2(Global.vec.size.resource)
			path += type + "/" + subtype + ".png"
			tr.texture = load(path)
		"servant":
			custom_minimum_size = Vector2(Global.vec.size.servant)
			path += type + "/" + subtype + ".png"
			tr.texture = load(path)
		"outcome":
			custom_minimum_size = Vector2(Global.vec.size.outcome)
			path += type + "/" + subtype + ".png"
			tr.texture = load(path)
