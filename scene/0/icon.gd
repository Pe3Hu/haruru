extends MarginContainer


@onready var number = $Number
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
	var types = ["resource", "servant", "outcome", "terrain", "economy"]
	
	if types.has(type):
		custom_minimum_size = Vector2(Global.vec.size[type])
		path += type + "/" + subtype + ".png"
		tr.texture = load(path)
	
	match type:
		"number":
			custom_minimum_size = Vector2(Global.vec.size.number)
			tr.visible = false
			number.visible = true
			number.text = str(subtype)
		"blank":
			custom_minimum_size = Vector2(Global.vec.size.number)


func get_number() -> int:
	return int(number.text)


func change_number(value_: int) -> void:
	number.text = str(int(number.text) + value_)
