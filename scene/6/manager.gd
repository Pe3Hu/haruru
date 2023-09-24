extends MarginContainer


var realm = null
var accountant = null
var foreman = null


func set_attributes(input_: Dictionary):
	realm = input_.realm
	accountant = realm.accountant
	foreman = accountant.foreman
	fill_accountant_rss()


func fill_accountant_rss() -> void:
	share_responsibility()
	fill_fieldworks()
	accountant.update_resource_income()
	accountant.update_population()


func share_responsibility() -> void:
	init_harvesters()
	init_handlers()


func fill_fieldworks() -> void:
	for specialization in accountant.servants:
		var population = accountant.get_rss_icon_based_on_type_and_subtype(specialization, "population").get_number()
		
		if population > 0:
			foreman.fill_best_workplaces(specialization, population)
			#var abundance = 0
			
#			for resource in Global.arr.resource:
#				var data = Global.dict.facet.type["servant"][specialization]
#
#				if data.workouts.has(resource):
#					accountant.change_specialization_resource_icon_by_abundance(specialization, resource, abundance)
#					var conversion = Global.get_conversion(resource)
#					var icon = accountant.get_rss_icon_based_on_type_and_subtype(servant, resource)
#					var value = float(data.workout[resource]) / data.dice * abundance
#
#					if data.workout[resource] > 0:
#						value *= conversion
#
#					value = floor(value)
#
#					#print([servant, resource, value, abundance, float(data.workout[resource]) / data.dice, conversion])
#					icon.change_number(value)


func init_harvesters() -> void:
	var workplaces = {}
	
	for terrain in Global.arr.terrain:
		workplaces[terrain] = {}
		workplaces[terrain].total = accountant.get_tss_icon_based_on_terrain_and_subtype(terrain, "workplace").get_number()#workplace
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
			workplaces[terrain].servants[servant] = accountant.servants[servant]


func set_population(subtype_: String, population_: int) -> void:
	accountant.servants[subtype_] = population_
	var icon = accountant.get_rss_icon_based_on_type_and_subtype(subtype_, "population")
	icon.number.text = str(population_)


func init_handlers() -> void:
	for servant in accountant.servants:
		if accountant.servants[servant] > 0:
			var raws = []
			
			for outcome in Global.dict.facet.type["servant"][servant].outcomes:
				var data = Global.dict.facet.type["servant"][servant].outcomes[outcome]
				
				if data.has("raw"):
					if data.raw == data.resource and !raws.has(data.raw):
						raws.append(data.raw)
			
			for raw in raws:
				var handler = Global.get_handler_based_on_raw(raw)
				var donor = accountant.get_rss_icon_based_on_type_and_subtype(servant, "population")
				var population = accountant.servants[servant] * Global.num.realm.handler / raws.size()
				donor.change_number(-population)
				set_population(servant, donor.get_number())
				var recipient = accountant.get_rss_icon_based_on_type_and_subtype(handler, "population")
				recipient.change_number(population)
				set_population(handler, recipient.get_number())
