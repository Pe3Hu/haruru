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
	init_harvesters()
	#fill_fieldworks()
	init_handlers()
	accountant.update_resource_income()
	accountant.update_population()
	update_resource_priority()


func init_harvesters() -> void:
	var workplaces = {}
	
	for terrain in Global.arr.terrain:
		workplaces[terrain] = {}
		workplaces[terrain].total = accountant.get_tss_icon_based_on_type_and_subtype(terrain, "workplace").get_number()#workplace
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
				var population = round(accountant.specializations[specialization] * Global.num.realm.handler / raws.size())
				foreman.empty_worst_workplaces(specialization, population)
				
				for _i in population:
					school.add_to_schedule_graduation(false, handler, true)
				
				school.graduation_check()
	
	school.fill_icons()
	var unemployed = -school.settlement.fieldwork.get_specialization_population("unemployed")
	school.settlement.fieldwork.set_specialization_resupply("unemployed", unemployed)
	
	
	#if realm.index == 0:
	#	print("reseted", accountant.get_rss_number_based_on_type_and_subtype("unemployed", "population"))


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
		accountant.set_rss_number_based_on_type_and_subtype("priority", resource, _i)


func develop_strategy_for_market_behavior() -> void:
	update_resource_priority()
	var n = 1
	
	var sale = 1
	
	for _i in n:
		var procurement = 100 * (n - _i)
		var stockpiles = {}
		var goals = {}
		
		for resource in Global.arr.resource:
			if resource != "food":
				var data = {}
				#data.resource = resource
				data.priority = accountant.get_rss_number_based_on_type_and_subtype("priority", resource)
				data.stockpile = accountant.get_rss_number_based_on_type_and_subtype("stockpile", resource)
				
				#if data.stockpile > 0:
				stockpiles[resource] = round(data.stockpile * 0.4)
				accountant.realm.warehouse.change_resource_value(resource, -stockpiles[resource])
				
				if stockpiles[resource] >= procurement:#stockpiles[resource] > 0 and 
					data.goal = -stockpiles[resource] * sale
				else:
					data.goal = procurement - stockpiles[resource]
				
				goals[resource] = data.goal
		
		
		var input = {}
		input.realm = realm
		input.resources = stockpiles
		input.goals = goals
		var mediator = Global.scene.mediator.instantiate()
		realm.sketch.marketplace.mediators.add_child(mediator)
		mediator.set_attributes(input)
