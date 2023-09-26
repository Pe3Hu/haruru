extends MarginContainer


@onready var vbox = $VBox
@onready var ia = $VBox/Abundance
@onready var ic = $VBox/Current
@onready var im = $VBox/Max

var foreman = null
var hbox = null
var terrain = null
var abundance = null
var specializations = {}


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


func set_specialization_resupply(specialization_: String, resupply_: int) -> int:
	if resupply_ != 0:
		var population = null
		var freely = get_freely()
		var current = ic.get_number()
		
		if resupply_ > 0:
			population = min(resupply_, freely)
			
			if resupply_ > freely:
				print("error: too many resupply in set_servant_populations")
		else:
			population = max(resupply_, -current)
			
			if resupply_ < -current:
				print("error: too few specializations in set_servant_populations", [freely, current, im.get_number()])
		
		ic.change_number(population)
		
		if !specializations.has(specialization_):
			specializations[specialization_] = 0
		
		specializations[specialization_] += population
		
		#if foreman.accountant.realm.index == 0 and specialization_ == "unemployed" and int(foreman.accountant.realm.sketch.day.text) > 0:
		#	print(["set_specialization_resupply", specialization_, specializations[specialization_]])
		update_visible()
		return population
	
	return 0


func update_visible() -> void:
	var freely = get_freely()
	visible = freely > 0
	
	if freely > 0:
		hbox.visible = true
	else:
		if foreman.find_worst_nonempty_fieldwork(terrain) == self:
			hbox.visible = false


func get_specialization_population(specialization_: String) -> int:
	var population = 0
	
	if specializations.has(specialization_):
		population += specializations[specialization_]
	
	return population
