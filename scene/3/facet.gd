extends MarginContainer


@onready var bg = $BG
@onready var icons = $HBox/Icons
@onready var quantities = $HBox/Quantities

var member = null
var influence = null
var gold = null
var index = null
var fail = false


func set_attributes(input_: Dictionary) -> void:
	for key in input_:
		set(key, input_[key])
	
	for token in Global.arr.token:
		var value = get(token)
		
		if value != null:
			var input = {}
			input.parent = self
			input.key = token
			var icon = Global.scene.icon.instantiate()
			icons.add_child(icon)
			icon.set_attributes(input)
		
			icon = Global.scene.icon.instantiate()
			input.key = value
			quantities.add_child(icon)
			icon.set_attributes(input)
	
	if input_.keys().size() == 2:
		fail = true
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
	
	paint_bg()
	custom_minimum_size = Vector2(Global.vec.size.facet)


func paint_bg() -> void:
	var style = StyleBoxFlat.new()
	bg.set("theme_override_styles/panel", style)
	var color = null
	
	match member.type.label.text:
		"vampire":
			match member.subtype.label.text:
				"ancestor":
					color = Color.RED
	
	if color == null:
		color = Color.DIM_GRAY
	
	#if fail:
	#	color = Color.WHITE
	
	style.bg_color = color


func get_attributes() -> Dictionary:
	var input = {}
	input.member = member
	input.index = index
	
	if influence != null:
		input.influence = influence
	
	if gold != null:
		input.gold = gold
	
	return input
