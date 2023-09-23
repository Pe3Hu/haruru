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
var servants = {}


func set_attributes(input_: Dictionary):
	realm = input_.realm
	economy = input_.realm.sketch.economy
	
	rt.text = str(realm.index)
	init_flaps()
	init_tss()
	fill_tss()
	init_rss()
	fill_rss()
	update_population()
	
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
	var comes = ["income", "outcome", "profit", "stockpile"]
	
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
	
	#print(Global.dict.facet.type["servant"].keys())
	
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
		
		if !servants.has(subtype):
			servants[subtype] = 0
	
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


func fill_rss() -> void:
	share_responsibility()
	
	for servant in servants:
		for resource in Global.arr.resource:
			var data = Global.dict.facet.type["servant"][servant]
			
			if data.workout.has(resource):
				var population = get_rss_icon_based_on_type_and_subtype(servant, "population").get_number()
				var icon = get_rss_icon_based_on_type_and_subtype(servant, resource)
				var avg = floor(float(data.workout[resource]) / data.dice * population)
				icon.number.text = str(avg)
	
	update_resource_income()


func share_responsibility() -> void:
	init_harvesters()
	init_handlers()


func init_harvesters() -> void:
	var workplaces = {}
	
	for terrain in Global.arr.terrain:
		workplaces[terrain] = {}
		workplaces[terrain].total = get_tss_icon_based_on_terrain_and_subtype(terrain, "workplace").get_number()#workplace
		workplaces[terrain].servants = {}
		var distribution = {}
		distribution.limit = 1
		distribution.min = 0.1
		distribution.servants = {}
		
		for subtype in Global.dict.facet.type["servant"]:
			var servant = Global.dict.facet.type["servant"][subtype]
			
			if servant.workplace == terrain:
				workplaces[terrain].servants[subtype] = 0
				distribution.servants[subtype] = distribution.min
				distribution.limit -= distribution.min
		
		Global.rng.randomize()
		var value = Global.rng.randf_range(0, distribution.limit)
		distribution.limit -= value
		var first = distribution.servants.keys().front()
		distribution.servants[first] += value
		var last = distribution.servants.keys().back()
		distribution.servants[last] += distribution.limit
		
		for servant in distribution.servants:
			var population = round(workplaces[terrain].total * distribution.servants[servant])
			set_population(servant, population)
			workplaces[terrain].servants[servant] = servants[servant]


func set_population(subtype_: String, population_: int) -> void:
	servants[subtype_] = population_
	
	var icon = get_rss_icon_based_on_type_and_subtype(subtype_, "population")
	icon.number.text = str(population_)


func init_handlers() -> void:
	for servant in servants:
		if servants[servant] > 0:
			var raws = []
			
			for outcome in Global.dict.facet.type["servant"][servant].outcome:
				var data = Global.dict.facet.type["servant"][servant].outcome[outcome]
				
				if data.has("raw"):
					if data.raw == data.resource and !raws.has(data.raw):
						raws.append(data.raw)
			
			for raw in raws:
				var handler = Global.get_handler_based_on_raw(raw)
				var donor = get_rss_icon_based_on_type_and_subtype(servant, "population")
				var population = servants[servant] * Global.num.realm.handler / raws.size()
				donor.change_number(-population)
				set_population(servant, donor.get_number())
				var recipient = get_rss_icon_based_on_type_and_subtype(handler, "population")
				recipient.change_number(population)
				set_population(handler, recipient.get_number())


func get_rss_icon_based_on_type_and_subtype(type_: String, subtype_: String) -> MarginContainer:
	var name_ = "value of " + type_ + " " + subtype_
	var icon = rss.get_node(name_)
	return icon


func update_resource_income() -> void:
	for resource in Global.arr.resource:
		var value = 0
		
		for servant in servants:
			value += get_rss_icon_based_on_type_and_subtype(servant, resource).get_number()
		
		var icon = get_rss_icon_based_on_type_and_subtype("income", resource)
		icon.number.text = str(value)


func update_population() -> void:
	var value = 0

	for servant in servants:
		value += get_rss_icon_based_on_type_and_subtype(servant, "population").get_number()
		
	var icon = get_rss_icon_based_on_type_and_subtype("profit", "population")
	icon.number.text = str(value)
