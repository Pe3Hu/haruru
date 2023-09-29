extends MarginContainer


@onready var pt = $HBox/VBox/ProprietorTitle
@onready var foreman = $HBox/Foreman
@onready var tss = $HBox/VBox/TerrainSpreadsheet
@onready var rss = $HBox/VBox/ResourceSpreadsheet
@onready var barn = $HBox/VBox/Barn

var economy = null
var proprietor = null
var flaps = []
var terrains = {}
var specializations = {}
var abundances = {}
var type = null


func set_attributes(input_: Dictionary):
	if input_.keys().has("realm"):
		proprietor = input_.realm
		type = "realm"
	if input_.keys().has("tribe"):
		proprietor = input_.tribe
		type = "tribe"
	
	economy = proprietor.sketch.economy
	
	pt.text = str(proprietor.index)
	init_flaps()
	init_tss()
	fill_tss()
	init_rss()
	
	var input = {}
	input.accountant = self
	barn.set_attributes(input)
	foreman.set_attributes(input)


func init_flaps() -> void:
	if type == "realm":
		for patch in proprietor.patchs:
			for flap in patch.flaps:
				flaps.append(flap)
				
				if !terrains.has(flap.terrain):
					terrains[flap.terrain] = []
				
				terrains[flap.terrain].append(flap)


func init_tss() -> void:
	var input = {}
	input.type = "blank"
	input.subtype = null
	var icon = Global.scene.icon.instantiate()
	tss.add_child(icon)
	
	var titles = ["flap", "square", "workplace", "abundance"]
	tss.columns = titles.size() + 1
	
	for title in titles:
		input.type = "economy"
		input.subtype = title
		icon = Global.scene.icon.instantiate()
		tss.add_child(icon)
		icon.set_attributes(input)
	
	for terrain in Global.arr.terrain:
		input.type = "terrain"
		input.subtype = terrain
		icon = Global.scene.icon.instantiate()
		tss.add_child(icon)
		icon.set_attributes(input)
		
		for title in titles:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			tss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + terrain + " " + title


func fill_tss() -> void:
	for terrain in terrains:
		var flaps_size = terrains[terrain].size()
		var abundance = 0
		var square = 0
		var workplace = 0
		
		for flap in terrains[terrain]:
			square += flap.square
			workplace += flap.workplaces
			abundance += flap.workplaces * flap.abundance
		
		square = round(square / 100)
		#workplace = round(square / 4)
		abundance = round(abundance / 10)
		set_tss_number_based_on_type_and_subtype(terrain, "flap", flaps_size)
		set_tss_number_based_on_type_and_subtype(terrain, "square", square)
		set_tss_number_based_on_type_and_subtype(terrain, "workplace", workplace)
		set_tss_number_based_on_type_and_subtype(terrain, "abundance", workplace)


func get_tss_icon_based_on_type_and_subtype(type_: String, subtype_: String) -> MarginContainer:
	var name_ = "value of " + type_ + " " + subtype_
	var icon = tss.get_node(name_)
	return icon


func set_tss_number_based_on_type_and_subtype(subtype_: String, type_: String, value_: int) -> void:
	var icon = get_tss_icon_based_on_type_and_subtype(subtype_, type_)
	icon.set_number(value_)


func get_tss_number_based_on_type_and_subtype(type_: String, subtype_: String) -> int:
	var icon = get_tss_icon_based_on_type_and_subtype(type_, subtype_)
	return icon.get_number()


func init_rss() -> void:
	var input = {}
	input.type = "blank"
	input.subtype = null
	var icon = Global.scene.icon.instantiate()
	rss.add_child(icon)
	
	var titles = ["population"]
	var comes = ["income", "outcome", "profit", "stockpile", "priority"]
	
	rss.columns = Global.arr.resource.size() + titles.size() + 1
	
	for title in titles:
		input.type = "economy"
		input.subtype = title
		icon = Global.scene.icon.instantiate()
		rss.add_child(icon)
		icon.set_attributes(input)
	
	for resource in Global.arr.resource:
		input.type = "resource"
		input.subtype = resource
		icon = Global.scene.icon.instantiate()
		rss.add_child(icon)
		icon.set_attributes(input)
	
	for subtype in Global.dict.facet.type["servant"]:
		input.type = "servant"
		input.subtype = subtype
		icon = Global.scene.icon.instantiate()
		rss.add_child(icon)
		icon.set_attributes(input)
		
		for title in titles:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			rss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + subtype + " " + title
		
		for resource in Global.arr.resource:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			rss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + subtype + " " + resource
		
		if !specializations.has(subtype):
			specializations[subtype] = 0
	
	for subtype in comes:
		input.type = "economy"
		input.subtype = subtype
		icon = Global.scene.icon.instantiate()
		rss.add_child(icon)
		icon.set_attributes(input)
		
		for title in titles:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			rss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + subtype + " " + title
		
		for resource in Global.arr.resource:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			rss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + subtype + " " + resource


func get_rss_icon_based_on_type_and_subtype(type_: String, subtype_: String) -> MarginContainer:
	var name_ = "value of " + type_ + " " + subtype_
	var icon = rss.get_node(name_)
	return icon


func set_rss_number_based_on_type_and_subtype(subtype_: String, type_: String, value_: int) -> void:
	var icon = get_rss_icon_based_on_type_and_subtype(subtype_, type_)
	icon.set_number(value_)


func get_rss_number_based_on_type_and_subtype(type_: String, subtype_: String) -> int:
	var icon = get_rss_icon_based_on_type_and_subtype(type_, subtype_)
	return icon.get_number()


func change_rss_icon_number_based_on_type_and_subtype_value(subtype_: String, type_: String, value_: int) -> void:
	var icon = get_rss_icon_based_on_type_and_subtype(subtype_, type_)
	icon.change_number(value_)
	
	if specializations.has(subtype_):
		specializations[subtype_] += value_


func change_specialization_population(specialization_: String, fieldwork_: MarginContainer ,population_: int) -> void:
	change_rss_icon_number_based_on_type_and_subtype_value(specialization_, "population", population_)
	var abundance = fieldwork_.abundance * population_

	if !abundances.has(specialization_):
		abundances[specialization_] = {}

	for resource in Global.dict.facet.type["servant"][specialization_].workouts:
		if !abundances[specialization_].has(resource):
			abundances[specialization_][resource] = 0
		
		abundances[specialization_][resource] += abundance
		update_specialization_resource_icon(specialization_, resource)


func update_specialization_resource_icon(specialization_: String, resource_: String) -> void:
	var data = Global.dict.facet.type["servant"][specialization_]
	var conversion = Global.get_conversion(resource_)
	var value = float(data.workouts[resource_]) / data.dice * abundances[specialization_][resource_]
	
	if data.workouts[resource_] > 0:
		value *= conversion
	
	value = round(value)
	
	set_rss_number_based_on_type_and_subtype(specialization_, resource_, value)


func update_resource_income() -> void:
	for resource in Global.arr.resource:
		var income = 0
		
		for servant in specializations:
			income += get_rss_number_based_on_type_and_subtype(servant, resource)
		
		var outcome = get_rss_number_based_on_type_and_subtype("outcome", resource)
		set_rss_number_based_on_type_and_subtype("income", resource, income)
		set_rss_number_based_on_type_and_subtype("profit", resource, income - outcome)


func update_population() -> void:
	var value = 0

	for servant in specializations:
		value += get_rss_number_based_on_type_and_subtype(servant, "population")
	
	set_rss_number_based_on_type_and_subtype("profit", "population", value)


func update_settlement_population() -> void:
	var settlement_specializations = ["unemployed", "mentor", "pupil"]
	
	for specialization in settlement_specializations:
		update_settlement_specialization_population(specialization)
	
	update_population()


func update_settlement_specialization_population(specialization_: String) -> void:
	var population = 0
	
	for settlement in proprietor.settlements.get_children():
		population += settlement.fieldwork.get_specialization_population(specialization_)
	
	#if proprietor.index == 0 :
	#	print([int(proprietor.sketch.day.text), specialization_, population])

	set_rss_number_based_on_type_and_subtype(specialization_, "population", population)

