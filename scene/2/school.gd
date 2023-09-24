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
	var workplaces = mm.get_number() - mc.get_number()
	
	if workplaces > 0:
		var unemployeds = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype("unemployed", "population").get_number()
		var entrants = min(unemployeds, workplaces)
		
		while entrants > 0:
			var specialization = choose_specialization()
			
			if specialization != null:
				mentor_takes_vacation(specialization)
				add_to_schedule_graduation(specialization)
			
			entrants -= 1


func choose_specialization() -> Variant:
	var specialization = null
	specialization = choose_product_specialization()
	
	return specialization


func choose_product_specialization() -> Variant:
	var datas = []
	
	for raw in Global.dict.conversion.raw:
		var data = {}
		data.product = Global.dict.conversion.raw[raw]
		data.income = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype("income", raw).get_number()
		data.specializations = Global.get_specializations_based_on_resource(data.product)
		data.populations = {}
		data.freely = 0
		
		for specialization in data.specializations:
			data.populations[specialization] = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype(specialization, "population").get_number()
			data.freely += data.populations[specialization]
		
		if data.freely > 0:
			datas.append(data)
	
	if !datas.is_empty():
		datas.sort_custom(func(a, b): return a.income > b.income)
		var specializations = datas.front().specializations
		var specialization = specializations.front()
		return specialization
	
	return null


func mentor_takes_vacation(specialization_: String) -> void:
	var workplace = Global.get_workplace_based_on_specialization(specialization_)
	var fieldwork = settlement.realm.accountant.foreman.find_worst_fieldwork(workplace)
	settlement.realm.accountant.change_specialization_population(specialization_, fieldwork, -1)
	fieldwork.set_servant_resupply(specialization_, -1)


func add_to_schedule_graduation(specialization_: String) -> void:
	var icon = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype("unemployed", "population")
	icon.change_number(-1)
	icon = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype("mentor", "population")
	icon.change_number(1)
	mc.change_number(1)
	icon = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype("pupil", "population")
	icon.change_number(1)
	pc.change_number(1)
	var day = int(settlement.realm.sketch.day.text) + Global.dict.period.study
	
	if !graduations.has(day):
		graduations[day] = []
	
	graduations[day].append(specialization_)


func graduation_check() -> void:
	var day = int(settlement.realm.sketch.day.text) 
	
	if graduations.has(day):
		while !graduations[day].is_empty():
			var specialization = graduations[day].pop_front()
			prom(specialization)


func prom(specialization_: String) -> void:
	var abundance = settlement.realm.accountant.foreman.fill_best_workplaces(specialization_, 2)
	
	settlement.realm.accountant.change_icon_number_by_value(specialization_, "population", 2)
	settlement.realm.accountant.change_icon_number_by_value("mentor", "population", -1)
	settlement.realm.accountant.change_icon_number_by_value("pupil", "population", -1)
	
	mc.change_number(-1)
	pc.change_number(-1)

	
