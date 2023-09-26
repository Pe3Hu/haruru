extends MarginContainer


@onready var appellation = $VBoxContainer/Appellation
@onready var structures = $VBoxContainer/Structures

var realm = null
var knob = null
#var workplace = {}
var grade = null
var fieldwork = null


func set_attributes(input_: Dictionary) -> void:
	knob = input_.knob
	realm = knob.state["earldom"].realm
	grade = input_.grade
	#workplace.total = Global.num.settlement.workplace[grade]
	#workplace.busily = 0
	#workplace.freely = Global.num.settlement.workplace[grade]
	
	#realm.accountant.foreman.update_comfortable(self)
	set_appellation()
	erect_structure("school")


func set_appellation() -> void:
	if !Global.dict.appellation.temp.city.is_empty():
		appellation.text = Global.dict.appellation.temp.city.pick_random()
		Global.dict.appellation.temp.city.erase(appellation)
	else:
		Global.fill_appellation_temp("city")
		set_appellation()


func bring_settlers(population_: int) -> void:
	#fieldwork = realm.accountant.foreman.find_worst_incomplete_fieldwork("comfortable")
	
	#workplace.busily += population
	#workplace.freely -= population
	#print("bring_settlers")
	#realm.accountant.change_unemployed_population(population)
	var population = min(population_, fieldwork.get_freely())
	fieldwork.set_specialization_resupply("unemployed", population)


func erect_structure(type_: String) -> void:
	var input = {}
	input.settlement = self
	input.type = type_
	
	var structure = Global.scene[type_].instantiate()
	structures.add_child(structure)
	structure.set_attributes(input)


