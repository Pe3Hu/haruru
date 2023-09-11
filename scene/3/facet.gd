extends MarginContainer


@onready var bg = $BG
@onready var icons = $HBox/Icons
@onready var quantities = $HBox/Quantities

var dice = null
var influence = null
var gold = null


func set_attributes(input_: Dictionary) -> void:
	for key in input_:
		set(key, input_[key])
		
		var input = {}
		input.parent = self
		input.key = key[0]
		var icon = Global.scene.icon.instantiate()
		icons.add_child(icon)
		icon.set_attributes(input)
	
		icon = Global.scene.icon.instantiate()
		input.key = input_[key]
		quantities.add_child(icon)
		icon.set_attributes(input)
	
	if input_.keys().is_empty():
		var input = {}
		input.parent = self
		input.key = ""
		var icon = Global.scene.icon.instantiate()
		icons.add_child(icon)
		icon.set_attributes(input)
		icon.visible = false
	
		icon = Global.scene.icon.instantiate()
		input.key = ""
		quantities.add_child(icon)
		icon.set_attributes(input)
		icon.visible = false
	
	#var style = StyleBoxFlat.new()
	#bg.set("theme_override_styles/panel", style)
	custom_minimum_size = Vector2(Global.vec.size.letter)

