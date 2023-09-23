extends MarginContainer


@onready var vbox = $VBox
@onready var ia = $VBox/Abundance
@onready var ic = $VBox/Current
@onready var im = $VBox/Max

var terrain = null
var abundance = null


func set_attributes(input_: Dictionary) -> void:
	terrain  = input_.terrain
	abundance  = input_.abundance
	
	fill_icons()


func fill_icons() -> void:
	var input = {}
	input.type = "number"
	input.subtype = 0
	ia.set_attributes(input)
	ia.change_number(abundance)
	ic.set_attributes(input)
	im.set_attributes(input)


func get_icon(name_: String) -> Variant:
	for icon in vbox.get_children():
		if icon.name == name_.capitalize():
			return icon
	
	return null
