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
	update_resource_priority()


func share_responsibility() -> void:
	init_harvesters()
	init_handlers()


func init_harvesters() -> void:
	var workplaces = {}
	
	for terrain in Global.arr.terrain:
		workplaces[terrain] = {}
		workplaces[terrain].total = accountant.get_tss_icon_based_on_terrain_and_subtype(terrain, "workplace").get_number()#workplace
		workplaces[terrain].specializations = {}
		var distribution = {}
		distribution.limit = 1
		distribution.min = 0.1
		distribution.specializations = {}
		
		for subtype in Global.dict.facet.type["servant"]:
			var specialization = Global.dict.facet.type["servant"][subtype]
			
			if specialization.workplace == terrain:
				workplaces[terrain].specializations[subtype] = 0
				distribution.specializations[subtype] = distribution.min
				distribution.limit -= distribution.min
		
		Global.rng.randomize()
		var value = Global.rng.randf_range(0, distribution.limit)
		distribution.limit -= value
		var first = distribution.specializations.keys().front()
		distribution.specializations[first] += value
		var last = distribution.specializations.keys().back()
		distribution.specializations[last] += distribution.limit
		
		for specialization in distribution.specializations:
			var population = round(workplaces[terrain].total * distribution.specializations[specialization])
			
			foreman.fill_best_workplaces(specialization, population)
			#set_population(specialization, population)
			#workplaces[terrain].specializations[servant] = accountant.specializations[servant]


func set_population(subtype_: String, population_: int) -> void:
	accountant.specializations[subtype_] = population_
	var icon = accountant.get_rss_icon_based_on_type_and_subtype(subtype_, "population")
	icon.number.text = str(population_)


func init_handlers() -> void:
	var school = null
	
	for settlement in realm.settlements.get_children():
		for structure in settlement.structures.get_children():
			if structure.type == "school":
				school = structure
				break
	
	for specialization in accountant.specializations:
		if accountant.specializations[specialization] > 0:
			var raws = []
			
			for outcome in Global.dict.facet.type["servant"][specialization].outcomes:
				var data = Global.dict.facet.type["servant"][specialization].outcomes[outcome]
				
				if data.has("raw"):
					if data.raw == data.resource and !raws.has(data.raw):
						raws.append(data.raw)
			
			for raw in raws:
				var handler = Global.get_handler_based_on_raw(raw)
				var donor = accountant.get_rss_icon_based_on_type_and_subtype(specialization, "population")
				var population = accountant.specializations[specialization] * Global.num.realm.handler / raws.size()
				foreman.empty_worst_workplaces(specialization, population)
				
				for _i in population:
					school.add_to_schedule_graduation(false, handler, true)
				
				school.graduation_check()
				
				#donor.change_number(-population)
				#set_population(servant, donor.get_number())
				#var recipient = accountant.get_rss_icon_based_on_type_and_subtype(handler, "population")
				#recipient.change_number(population)
				#set_population(handler, recipient.get_number())
	
	school.fill_icons()


func fill_fieldworks() -> void:
	for specialization in accountant.specializations:
		var population = accountant.get_rss_icon_based_on_type_and_subtype(specialization, "population").get_number()
		
		if population > 0:
			foreman.fill_best_workplaces(specialization, population)


func update_resource_priority() -> void:
	var datas = {}
	var profits = []
	
	for resource in Global.arr.resource:
		var data = {}
		data.profit = accountant.get_rss_number_based_on_type_and_subtype("profit", resource)
		data.price = Global.dict.merchandise.price[resource]
		data.order = 0
		data.value = data.profit * data.price
		data.resource = resource
		
		if Global.dict.conversion.product.has(resource):
			data.order = 1
		
		if !datas.has(data.profit):
			datas[data.profit] = {}
			profits.append(data.profit)
			
		if !datas[data.profit].has(data.price):
			datas[data.profit][data.price] = []
		
		datas[data.profit][data.price].append(data)
		datas[data.profit][data.price].sort_custom(func(a, b): return a.order < b.order)
	
	profits.sort()
	
	var resources = []
	
	for profit in profits:
		var prices = datas[profit].keys()
		
		prices.sort_custom(func(a, b): return a > b)
		
		for price in prices:
			for data in  datas[profit][price]:
				resources.append(data.resource)
	
	for _i in resources.size():
		var resource = resources[_i]
		var icon = accountant.get_rss_icon_based_on_type_and_subtype("priority", resource)
		icon.number.text = str(_i)

