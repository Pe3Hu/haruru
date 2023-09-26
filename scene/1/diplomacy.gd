extends MarginContainer


@onready var tribes = $HBox/Tribes
@onready var realms = $HBox/Realms

var sketch = null
var time = null
var empires = []


func _ready() -> void:
	#init_tribes()
	pass


func init_tribes() -> void:
	var input = {}
	input.diplomacy = self
	input.type = "vampire"
	var tribe = Global.scene.tribe.instantiate()
	tribes.add_child(tribe)
	tribe.set_attributes(input)


func do_it() -> void:
	for tribe in tribes.get_children():
		tribe.follow_phase()
	
	var tribe = tribes.get_child(0)
	
	if Global.arr.phase.back() == tribe.phase:
		var day = int(Global.node.sketch.day.text) + 1
		Global.node.sketch.day.text = str(day)


func servants_simulation() -> void:
	var tribe = tribes.get_child(0)
	#var type = "servant"
	#var population = 50
	#var deadline = Global.dict.time.day
	var data = {}
	data.type = "servant"
	data.population = 100
	data.deadline = Global.dict.time.month#month
	data.time = 0
	var total = data.population * data.deadline
	#var subtype = "farmer"
	
	for subtype in Global.dict.facet.type[data.type]:
		tribe.init_servants(subtype, data.population)
		simulation(data.deadline)
		data.resource = get_resource_analytics()
		data.time += Time.get_unix_time_from_system() - time
		#input.time = Time.get_unix_time_from_system() - time
		#input.type = type
		data.subtype = subtype
		#input.population = population
		#input.deadline = deadline
		tribe.reset()
		data.avg = {}
			
		for key in data.resource:
			data.avg[key] = snapped(float(data.resource[key]) / total, 0.01)
		
		Global.node.sketch.day.text = str(0)
		data.time = snapped(data.time, 0.01)
		Global.save_statistics(data)
		#print(data)
		#data[subtype] = input
	
	#Global.save_statistics(data)
	#print(data)


func simulation(deadline) -> void:
	time = Time.get_unix_time_from_system()
	
	while int(Global.node.sketch.day.text) < deadline:
		do_it()


func get_resource_analytics() -> Dictionary:
	var tribe = tribes.get_child(0)
	var analytics = {}
	
	for business in Global.dict.business:
		for key in Global.dict.business[business]:
			var resource = Global.dict.business[business][key]
			analytics[resource] = tribe.warehouse.get_value_of_resource(resource)
			
			if Global.dict.endowment.has(resource):
				analytics[resource] -= Global.dict.endowment[resource]
			
			if analytics[resource] == 0:
				analytics.erase(resource)
	
	return analytics


func init_reams() -> void:
	for empire in sketch.cloth.empires.get_children():
		var input = {}
		input.sketch = sketch
		input.state = empire.capital.state["dukedom"]
		
		var realm = Global.scene.realm.instantiate()
		realms.add_child(realm)
		realm.set_attributes(input)
	
	sketch.cloth.shift_layer(0)
	
	for realm in realms.get_children():
		if realm.index == 0:
			var fieldwork = realm.accountant.foreman.find_worst_incomplete_fieldwork("comfortable")
			var n = 0
			
			for specialization in fieldwork.specializations:
				n += fieldwork.specializations[specialization]
			
			#print(["before next_day", fieldwork.specializations, n, fieldwork.ic.get_number()])
	
	for _i in Global.dict.time.month:
		sketch.next_day()
	
	realms_are_trading()
	
	for realm in realms.get_children():
		if realm.index == 0:
			var fieldwork = realm.accountant.foreman.find_worst_incomplete_fieldwork("comfortable")
			var n = 0
			
			for specialization in fieldwork.specializations:
				n += fieldwork.specializations[specialization]
			
			#print(["after next_day", fieldwork.specializations, n, fieldwork.ic.get_number()])


func realms_are_harvesting() -> void:
	for realm in realms.get_children():
		realm.harvest()
		realm.meal()
		realm.craft()
		realm.migration()
		realm.education()
		realm.accountant.update_resource_income()
		realm.manager.update_resource_priority()
		realm.accountant.update_settlement_population()


func realms_are_trading() -> void:
	for realm in realms.get_children():
		realm.manager.develop_strategy_for_market_behavior()
