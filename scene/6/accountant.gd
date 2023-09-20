extends MarginContainer


@onready var label = $Label
@onready var et = $VBox/EmpireTitle
@onready var tss = $VBox/TerrainSpreadsheet
@onready var rss = $VBox/ResourceSpreadsheet

var economy = null
var empire = null
var flaps = []
var terrains = {}
var servants = {}


func set_attributes(input_: Dictionary):
	economy = input_.economy
	empire = input_.empire
	
	et.text = str(empire.index)
	init_flaps()
	init_tss()
	fill_tss()
	init_rss()
	fill_rss()


func init_flaps() -> void:
	for patch in empire.patchs:
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
			abundance += flap.square * flap.abundance
		
		square = round(square / 100)
		workplace = round(square / 10)
		abundance = round(abundance / 10000)
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
	var comes = ["income", "outcome", "profit"]
	
	rss.columns = Global.dict.raw.keys().size() + titles.size() + 1
	
	for title in titles:
		input.type = "economy"
		input.subtype = title
		icon = Global.scene.icon.instantiate()
		rss.add_child(icon)
		icon.set_attributes(input)
	
	for raw in Global.dict.raw:
		input.type = "resource"
		input.subtype = raw
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
		
		for raw in Global.dict.raw:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			rss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + subtype + " " + raw
		
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
		
		for raw in Global.dict.raw:
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			rss.add_child(icon)
			icon.set_attributes(input)
			icon.name = "value of " + subtype + " " + raw


func fill_rss() -> void:
	share_responsibility()
	
	for servant in servants:
		for raw in Global.dict.raw:
			var data = Global.dict.facet.type["servant"][servant]
			
			if data.workout.has(raw):
				var population = get_rss_icon_based_on_servant_and_subtype(servant, "population").get_number()
				var icon = get_rss_icon_based_on_servant_and_subtype(servant, raw)
				var avg = floor(float(data.workout[raw]) / data.dice * population)
				icon.number.text = str(avg)
	
	update_raw_income()


func share_responsibility() -> void:
	var workplaces = {}
	
	for terrain in Global.arr.terrain:
		workplaces[terrain] = {}
		workplaces[terrain].total = get_tss_icon_based_on_terrain_and_subtype(terrain, "abundance").get_number()#workplace
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
			workplaces[terrain].servants[servant] = round(workplaces[terrain].total * distribution.servants[servant])
	
	for terrain in workplaces:
		for servant in workplaces[terrain].servants:
			var icon = get_rss_icon_based_on_servant_and_subtype(servant, "population")
			icon.number.text = str(workplaces[terrain].servants[servant])


func get_rss_icon_based_on_servant_and_subtype(servant_: String, subtype_: String) -> MarginContainer:
	var name_ = "value of " + servant_ + " " + subtype_
	var icon = rss.get_node(name_)
	return icon


func update_raw_income() -> void:
	for raw in Global.dict.raw:
		var value = 0
		
		for servant in servants:
			value += get_rss_icon_based_on_servant_and_subtype(servant, raw).get_number()
		
		var icon = get_rss_icon_based_on_servant_and_subtype("income", raw)
		icon.number.text = str(value)
