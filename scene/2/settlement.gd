extends MarginContainer


@onready var appellation = $VBoxContainer/Appellation
@onready var structures = $VBoxContainer/Structures

var realm = null
var knob = null
var workplace = {}


func set_attributes(input_: Dictionary) -> void:
	knob = input_.knob
	realm = knob.state["earldom"].realm
	workplace.total = input_.workplace
	workplace.busily = 0
	workplace.freely = input_.workplace
	
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
	var population = min(population_, workplace.freely)
	workplace.busily += population
	workplace.freely -= population
	var icon = realm.accountant.get_rss_icon_based_on_type_and_subtype("unemployed" ,"population")
	icon.change_number(population)


func erect_structure(type_: String) -> void:
	var input = {}
	input.settlement = self
	input.type = type_
	
	var structure = Global.scene[type_].instantiate()
	structures.add_child(structure)
	structure.set_attributes(input)

