extends MarginContainer


@onready var mi = $VBox/Mentors/Icon
@onready var mc = $VBox/Mentors/Current
@onready var mm = $VBox/Mentors/Max
@onready var pi = $VBox/Pupils/Icon
@onready var pc = $VBox/Pupils/Current
@onready var pm = $VBox/Pupils/Max

var settlement = null
var type = null
var grade = null
var mentors = {}
var pupils = {}
var graduations = {}


func set_attributes(input_: Dictionary) -> void:
	settlement = input_.settlement
	type = input_.type
	grade = 0
	
	fill_icons()


func fill_icons() -> void:
	var input = {}
	input.type = "servant"
	input.subtype = "mentor"
	mi.set_attributes(input)
	input.type = "servant"
	input.subtype = "pupil"
	pi.set_attributes(input)
	input.type = "number"
	input.subtype = 0
	mc.set_attributes(input)
	input.type = "number"
	input.subtype = 0
	mm.set_attributes(input)
	mm.change_number(Global.num.structure.school.workplace[grade])
	input.type = "number"
	input.subtype = 0
	pc.set_attributes(input)
	input.type = "number"
	input.subtype = 0
	pm.set_attributes(input)
	pm.change_number(Global.num.structure.school.workplace[grade])


func enrollment() -> void:
	var workplaces = pm.get_number() - pc.get_number()
	
	if workplaces > 0:
		var unemployeds = settlement.fieldwork.get_specialization_population("unemployed")
		var entrants = min(unemployeds, workplaces)
		
		while entrants > 0:
			if settlement.fieldwork != null:
				var specialization = choose_specialization()
				
				if specialization != null:
					var flag = mentor_takes_vacation(specialization)
					add_to_schedule_graduation(flag, specialization, false)
				
				entrants -= 1
			else:
				entrants = 0
				print("error: no fieldwork for entrants")


func choose_specialization() -> Variant:
	var specialization = null
	
	specialization = choose_specialization_based_on_resource_priority()
#	if int(settlement.realm.sketch.day.text) > 10:
#		specialization = choose_raw_specialization()
#	else:
#		specialization = choose_product_specialization()
	
	return specialization


func choose_raw_specialization() -> Variant:
	return null


func choose_specialization_based_on_resource_priority() -> Variant:
	var fieldworks = []
	
	for terrain in Global.arr.workplace:
		#var node = settlement.realm.accountant.foreman.terrains.get_node(terrain.capitalize())
		var fieldwork = settlement.realm.accountant.foreman.find_best_incomplete_fieldwork(terrain)
		
		if fieldwork != null:
			fieldworks.append(fieldwork)
	
	fieldworks.sort_custom(func(a, b): return a.abundance > b.abundance)
	
	var specializations = []
	
	for fieldwork in fieldworks:
		if fieldwork.abundance == fieldworks.front().abundance:
			specializations.append_array(Global.get_specializations_based_on_workplace(fieldwork.terrain))
	
	var datas = []
	
	for specialization in specializations:
		var workouts = Global.get_workouts_based_on_specialization(specialization)
		
		for resource in workouts:
			if workouts[resource] > 0:
				var data = {}
				data.specialization = specialization
				data.resource = resource
				data.priority = settlement.realm.accountant.get_rss_number_based_on_type_and_subtype("priority", resource)
				datas.append(data)
	
	if !datas.is_empty():
		datas.sort_custom(func(a, b): return a.priority < b.priority)
		var specialization = datas.front().specialization
		return specialization
	
	return null


func choose_product_specialization() -> Variant:
	var datas = []
	
	for raw in Global.dict.conversion.raw:
		var data = {}
		data.product = Global.dict.conversion.raw[raw]
		data.income = settlement.realm.accountant.get_rss_number_based_on_type_and_subtype("income", raw)
		data.specializations = Global.get_specializations_based_on_resource(data.product)
		data.populations = {}
		data.freely = 0
		
		for specialization in data.specializations:
			data.populations[specialization] = settlement.realm.accountant.get_rss_number_based_on_type_and_subtype(specialization, "population")
			data.freely += data.populations[specialization]
		
		if data.freely > 0:
			datas.append(data)
	
	if !datas.is_empty():
		datas.sort_custom(func(a, b): return a.income > b.income)
		var specializations = datas.front().specializations
		var specialization = specializations.front()
		return specialization
	
	return null


func mentor_takes_vacation(specialization_: String) -> bool:
	var population = settlement.fieldwork.get_specialization_population(specialization_)
	
	if population > 0:
		#print(specialization_)
		settlement.realm.accountant.foreman.empty_worst_workplaces(specialization_, 1)
		
		#if settlement.realm.index == 0:
			#var n = settlement.realm.accountant.get_rss_number_based_on_type_and_subtype("unemployed", "population")
			
			#print(["mentor_takes_vacation", n, settlement.fieldwork.specializations["unemployed"]])
		return true
	
	return false


func add_to_schedule_graduation(mentor_availability_: bool, specialization_: String, skip_: bool) -> void:
	
	#settlement.realm.accountant.change_unemployed_population(-1)
	#settlement.realm.accountant.change_icon_number_by_value("pupil", "population", 1)
	settlement.fieldwork.set_specialization_resupply("pupil", 1)
	settlement.fieldwork.set_specialization_resupply("unemployed",  -1)
	pc.change_number(1)
	
	if mentor_availability_:
		#settlement.realm.accountant.change_icon_number_by_value("mentor", "population", 1)
		settlement.fieldwork.set_specialization_resupply("mentor",  1)
		mc.change_number(1)
	
	var study = 0
	
	if !skip_:
		study = Global.dict.period.study.withmentor
		
		if !mentor_availability_:
			study = Global.dict.period.study.selftaught
	
	var day = int(settlement.realm.sketch.day.text) + study
	
	if !graduations.has(day):
		graduations[day] = {}
		
	if !graduations[day].has(specialization_):
		graduations[day][specialization_] = []
	
	graduations[day][specialization_].append("pupil")
	
	if mentor_availability_:
		graduations[day][specialization_].append("mentor")


func graduation_check() -> void:
	var day = int(settlement.realm.sketch.day.text) 
	#if settlement.realm.index == 0:
	#	print([day, graduations])
	
	if graduations.has(day):
		while !graduations[day].is_empty():
			var specialization = graduations[day].keys().front()
			var scholars = graduations[day][specialization]
			prom(specialization, scholars)
			graduations[day].erase(specialization)
		
		graduations.erase(day)


func prom(specialization_: String, scholars_: Array) -> void:
	settlement.realm.accountant.foreman.fill_best_workplaces(specialization_, scholars_.size())
	#if settlement.realm.index == 0:
	#print([settlement.realm.index, "prom", specialization_, scholars_.size()])
	for scholar in scholars_:
		#settlement.realm.accountant.change_icon_number_by_value(scholar, "population", -1)
		settlement.fieldwork.set_specialization_resupply(scholar,  -1)
		
		match scholar:
			"mentor":
				mc.change_number(-1)
			"pupil":
				pc.change_number(-1)
