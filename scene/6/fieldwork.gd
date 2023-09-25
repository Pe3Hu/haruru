extends MarginContainer


@onready var vbox = $VBox
@onready var ia = $VBox/Abundance
@onready var ic = $VBox/Current
@onready var im = $VBox/Max

var foreman = null
var hbox = null
var terrain = null
var abundance = null
var servants = {}


func set_attributes(input_: Dictionary) -> void:
	foreman = input_.foreman
	hbox = input_.hbox
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


func get_freely() -> int:
	return im.get_number() - ic.get_number()


func set_servant_resupply(servant_: String, resupply_: int) -> void:
	var freely = get_freely()
	var population = min(resupply_, freely)
	ic.change_number(population)
	
	if !servants.has(servant_):
		servants[servant_] = 0
	
	servants[servant_] += population
	update_visible()
	
	if resupply_ > freely:
		print("too many in set_servant_populations")


func update_visible() -> void:
	var freely = get_freely()
	#print(freely)
	visible = freely > 0
	
	if freely > 0:
		hbox.visible = true
	else:
		if foreman.find_worst_fieldwork(terrain) == self:
			hbox.visible = false
