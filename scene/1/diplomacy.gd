extends MarginContainer


@onready var tribes = $HBox/Tribes
@onready var realms = $HBox/Realms

var sketch = null
var time = null
var empires = []
var accreditation = {}
var selected = {}


func init_reams() -> void:
	var empires_ = [sketch.cloth.empires.get_child(0)]#,sketch.cloth.empires.get_child(1), sketch.cloth.empires.get_child(2)]
	for empire in empires_:
	#for empire in sketch.cloth.empires.get_children():
		var input = {}
		input.sketch = sketch
		input.state = empire.capital.state["dukedom"]
		
		var realm = Global.scene.realm.instantiate()
		realms.add_child(realm)
		realm.set_attributes(input)
		realm.accountant.visible = true
		realm.accountant.barn.visible = true
	
	sketch.cloth.shift_layer(0)
	selected.realm = realms.get_child(0)
	selected.tribe = selected.realm.tribes.get_child(0)
	#selected.tribe.visible = true
	#selected.tribe.accountant.visible = true
	#selected.realm.warehouse.visible = true
	#selected.realm.accountant.barn.visible = true
	
#	for accountant in sketch.economy.accountants.get_children():
#		if accountant.proprietor == selected.realm:
#			accountant.visible = true
#			break
	
	#for _i in Global.dict.time.month:
	#	sketch.next_day()
	
	#for _i in Global.dict.time.week:
	#	realms_are_trading()
	do_it()


func do_it() -> void:
	for _i in 2:#Global.dict.time.week:
		skip_day()


func skip_day() -> void:
	for realm in realms.get_children():
		realm.manager.meal()
		
		for tribe in realm.tribes.get_children():
			tribe.skip_day()
	
	var day = int(Global.node.sketch.day.text) + 1
	Global.node.sketch.day.text = str(day)
	selected.realm.accountant.foreman.give_prizes()
	print("day " + str(day))
	
	if day % 2 == 0:
		selected.realm.accountant.foreman.rotate_members()



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
	sketch.marketplace.prepare_before_trading()
	
	for realm in realms.get_children():
		realm.manager.develop_strategy_for_market_behavior()
	
	sketch.marketplace.skip_trading()
	
	
	for mediator in sketch.marketplace.mediators.get_children():
		mediator.comeback()


func calc_accreditation() -> void:
	accreditation[Global.num.index.accreditation] = {}
	for resource in Global.arr.resource:
		accreditation[Global.num.index.accreditation][resource] = 0
		
		for realm in realms.get_children():
			accreditation[Global.num.index.accreditation][resource] += realm.warehouse.get_resource_value(resource)
	
	print(["accreditation", Global.num.index.accreditation, accreditation[Global.num.index.accreditation]])
	Global.num.index.accreditation += 1
