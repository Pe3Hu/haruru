extends MarginContainer


@onready var rt = $VBox/RealmTitle
@onready var foreman = $VBox/Foreman
@onready var tss = $VBox/TerrainSpreadsheet
@onready var rss = $VBox/ResourceSpreadsheet
@onready var barn = $VBox/Barn

var economy = null
var realm = null
var flaps = []
var terrains = {}
var specializations = {}
var abundances = {}


func set_attributes(input_: Dictionary):
	realm = input_.realm
	economy = input_.realm.sketch.economy
	
	rt.text = str(realm.index)
	init_flaps()
	init_tss()
	fill_tss()
	init_rss()
	
	var input = {}
	input.accountant = self
	barn.set_attributes(input)
	foreman.set_attributes(input)


func init_flaps() -> void:
	for patch in realm.patchs:
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
		var icon = get_tss_icon_based_on_terrain_and_subtype(terrain, "flap")
		icon.number.text = str(terrains[terrain].size())
		
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
		icon = get_tss_icon_based_on_terrain_and_subtype(terrain, "square")
		icon.number.text = str(square)
		
		icon = get_tss_icon_based_on_terrain_and_subtype(terrain, "workplace")
		icon.number.text = str(workplace)
		
		icon = get_tss_icon_based_on_terrain_and_subtype(terrain, "abundance")
		icon.number.text = str(abundance)


func get_tss_icon_based_on_terrain_and_subtype(terrain_: String, subtype_: String) -> MarginContainer:
	var name_ = "value of " + terrain_ + " " + subtype_
	var icon = tss.get_node(name_)
	return icon


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


func get_rss_number_based_on_type_and_subtype(type_: String, subtype_: String) -> int:
	var name_ = "value of " + type_ + " " + subtype_
	var icon = rss.get_node(name_)
	return icon.get_number()


func change_specialization_population(specialization_: String, fieldwork_: MarginContainer ,population_: int) -> void:
	change_icon_number_by_value(specialization_, "population", population_)
	var abundance = fieldwork_.abundance * population_
	var population = get_rss_number_based_on_type_and_subtype(specialization_, "population")
	#print([population, "realm " + str(realm.index), specialization_, population_, fieldwork_.abundance, abundance])
	
	if !abundances.has(specialization_):
		abundances[specialization_] = {}

	for resource in Global.dict.facet.type["servant"][specialization_].workouts:
		if !abundances[specialization_].has(resource):
			abundances[specialization_][resource] = 0
		
		abundances[specialization_][resource] += abundance
		#var workout = Global.dict.facet.type["servant"][specialization_].workouts[resource]
		#var a = Global.dict.facet.type["servant"][specialization_].workouts
		#if int(realm.sketch.day.text) > 0: #Global.dict.facet.type["servant"][specialization_].workouts.size() > 1 and
		#	var b = null
		update_specialization_resource_icon(specialization_, resource)
		#change_specialization_resource_icon_by_abundance(specialization_, resource, abundance)


func change_icon_number_by_value(subtype_: String, type_: String, value_: int) -> void:
	var icon = get_rss_icon_based_on_type_and_subtype(subtype_, type_)
	icon.change_number(value_)
	
	if specializations.has(subtype_):
		specializations[subtype_] += value_


#func change_specialization_resource_icon_by_abundance(specialization_: String, resource_: String, abundance_: int) -> void:
#	var data = Global.dict.facet.type["servant"][specialization_]
#	var conversion = Global.get_conversion(resource_)
#	var value = float(data.workouts[resource_]) / data.dice * abundance_
#
#	if data.workouts[resource_] > 0:
#		value *= conversion
#
#	value = round(value)
#	change_icon_number_by_value(specialization_, resource_, value)


func update_specialization_resource_icon(specialization_: String, resource_: String) -> void:
	var data = Global.dict.facet.type["servant"][specialization_]
	var conversion = Global.get_conversion(resource_)
	var value = float(data.workouts[resource_]) / data.dice * abundances[specialization_][resource_]
	
	if data.workouts[resource_] > 0:
		value *= conversion
	
	var icon = get_rss_icon_based_on_type_and_subtype(specialization_, resource_)
	icon.number.text = str(round(value))
	
#	if int(realm.sketch.day.text) > 0: #specialization_ == "cook" and resource_ == "food" and
#		var population = get_rss_number_based_on_type_and_subtype(specialization_, "population")
#		print([specialization_, resource_, population, value, abundances[specialization_][resource_], "realm " + str(realm.index), float(data.workouts[resource_]) / data.dice, conversion]) #specialization_, resource_ float(data.workouts[resource_]) / data.dice, conversion


func update_resource_income() -> void:
	for resource in Global.arr.resource:
		var income = 0
		
		for servant in specializations:
			income += get_rss_icon_based_on_type_and_subtype(servant, resource).get_number()
		
		var icons = {}
		icons.income = get_rss_icon_based_on_type_and_subtype("income", resource)
		icons.income.number.text = str(income)
		
		var outcome = get_rss_number_based_on_type_and_subtype("outcome", resource)
		
		icons.profit = get_rss_icon_based_on_type_and_subtype("profit", resource)
		icons.profit.number.text = str(income - outcome)


func update_population() -> void:
	var value = 0

	for servant in specializations:
		value += get_rss_icon_based_on_type_and_subtype(servant, "population").get_number()
	
	var icon = get_rss_icon_based_on_type_and_subtype("profit", "population")
	icon.number.text = str(value)


func change_unemployed_population(population_: int) -> void:
	var specialization = "unemployed"
	var workplace = "comfortable"
	var fieldwork = foreman.find_worst_incomplete_fieldwork(workplace)
	var resupply = fieldwork.set_sspecialization_resupply(specialization, population_)
	change_icon_number_by_value(specialization, "population", resupply)
