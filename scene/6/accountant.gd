extends MarginContainer


@onready var label = $Label
@onready var et = $VBox/EmpireTitle
@onready var resources = $VBox/Resources
@onready var ss = $VBox/Spreadsheet

var economy = null
var empire = null
var flaps = []
var terrains = {}


func set_attributes(input_: Dictionary):
	economy = input_.economy
	empire = input_.empire
	
	et.text = str(empire.index)
	init_flaps()
	init_ss()
	fill_ss()


func init_flaps() -> void:
	for patch in empire.patchs:
		for flap in patch.flaps:
			flaps.append(flap)
			
			if !terrains.has(flap.terrain):
				terrains[flap.terrain] = []
			
			terrains[flap.terrain].append(flap)


func init_ss() -> void:
	var input = {}
	input.type = "blank"
	input.subtype = null
	var icon = Global.scene.icon.instantiate()
	ss.add_child(icon)
	
	var titles = ["flap", "square", "abundance"]
	ss.columns = titles.size() + Global.dict.raw.keys().size() + 1
	
	for title in titles:
		input.type = "economy"
		input.subtype = title
		icon = Global.scene.icon.instantiate()
		ss.add_child(icon)
		icon.set_attributes(input)
	
	for raw in Global.dict.raw:
		input.type = "resource"
		input.subtype = raw
		icon = Global.scene.icon.instantiate()
		ss.add_child(icon)
		icon.set_attributes(input)
	
	for terrain in Global.arr.terrain:
		input.type = "terrain"
		input.subtype = terrain
		icon = Global.scene.icon.instantiate()
		ss.add_child(icon)
		icon.set_attributes(input)
		
		for title in titles:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			ss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + terrain + " " + title
		
		for raw in Global.dict.raw:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			ss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + terrain + " " + raw


func init_resources_old() -> void:
	for raw in Global.dict.raw:
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.name = raw.capitalize()
		var input = {}
		input.type = "resource"
		input.subtype = raw
		var icon = Global.scene.icon.instantiate()
		hbox.add_child(icon)
		icon.name = "Icon"
		var label_ = label.duplicate()
		label_.name = "Value"
		hbox.add_child(label_)
		resources.add_child(hbox)
		icon.set_attributes(input)
	
	label.visible = false


func fill_ss() -> void:
	for terrain in terrains:
		var icon = get_icon_based_on_terrain_and_subtype(terrain, "flap")
		icon.number.text = str(terrains[terrain].size())
		
		var abundance = 0
		var square = 0
		
		for flap in terrains[terrain]:
			square += flap.square
			abundance += flap.square * flap.abundance
		
		square = round(square / 100)
		abundance = round(abundance / 1000)
		icon = get_icon_based_on_terrain_and_subtype(terrain, "square")
		icon.number.text = str(square)
		
		icon = get_icon_based_on_terrain_and_subtype(terrain, "abundance")
		icon.number.text = str(abundance)


func get_icon_based_on_terrain_and_subtype(terrain_: String, subtype_: String) -> MarginContainer:
	var name_ = "value of " + terrain_ + " " + subtype_
	var icon = ss.get_node(name_)
	return icon
