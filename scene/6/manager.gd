extends MarginContainer


var proprietor = null
var accountant = null
var foreman = null
var warehouse = null
var coupons = {}
var queues = {}
var members = []


func set_attributes(input_: Dictionary):
	if input_.keys().has("realm"):
		proprietor = input_.realm
		queues.meal = 0
	if input_.keys().has("tribe"):
		proprietor = input_.tribe
	
	accountant = proprietor.accountant
	foreman = accountant.foreman
	warehouse = proprietor.warehouse
	
	for resource in Global.arr.resource:
		coupons[resource] = {}
	
	#fill_accountant_rss()


func update_accountant_rss() -> void:
	accountant.update_resource_income()
	accountant.update_population()
	update_resource_priority()


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
				accountant.proprietor.warehouse.change_resource_value(resource, -stockpiles[resource])
				
				if stockpiles[resource] >= procurement:#stockpiles[resource] > 0 and 
					data.goal = -stockpiles[resource] * sale
				else:
					data.goal = procurement - stockpiles[resource]
				
				goals[resource] = data.goal
		
		var input = {}
		input.realm = proprietor
		input.resources = stockpiles
		input.goals = goals
		var mediator = Global.scene.mediator.instantiate()
		proprietor.sketch.marketplace.mediators.add_child(mediator)
		mediator.set_attributes(input)


func hold_fieldwork_tenders() -> void:
	for terrain in Global.arr.terrain:
		var fieldwork = accountant.foreman.find_best_incomplete_fieldwork(terrain)
		var pool = []
		var tribes = {}
		
		for tribe in proprietor.tribes.get_children():
			tribes[tribe] = []
			
			for member in tribe.members.get_children():
				if member.fieldwork == null and Global.get_workplace_based_on_specialization(member.specialization) == terrain:
					tribes[tribe].append(member)
					pool.append(tribe)
		
		
		while fieldwork != null and !pool.is_empty():
			fieldwork = accountant.foreman.find_best_incomplete_fieldwork(terrain)
			var tribe = pool.pick_random()
			var member = tribes[tribe].pick_random()
			tribes[tribe].erase(member)
			pool.erase(tribe)
			fieldwork.employ_member(member)
			
			if tribes[tribe].is_empty():
				while pool.has(tribe):
					pool.erase(tribe)


func meal() -> void:
	accountant.barn.reduce_shelf_life()
	var food = warehouse.get_resource_value("food")
	#food.profit = food.input - food.output
	accountant.barn.absorption(queues.meal)
	accountant.barn.restock(food)
	warehouse.change_resource_value("food", -food)
	
	for member in members:
		member.meal()


func sleep() -> void:
	for member in members:
		member.sleep(1)


func pick_diners() -> void:
	var value = min(coupons.food, members.size())
	var mouths = []
	mouths.append_array(members)
	coupons.food -= value
	
	while value > 0:
		value -= 1
		var member = mouths.pick_random()
		member.lunch = -1
		mouths.erase(member)
		proprietor.realm.manager.queues.meal += 1


