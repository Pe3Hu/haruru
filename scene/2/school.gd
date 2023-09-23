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
	input.type = "number"
	input.subtype = 0
	pc.set_attributes(input)
	input.type = "number"
	input.subtype = 0
	pm.set_attributes(input)


func education() -> void:
	var workpmaces = mm.get_number() > mc.get_number()
	
	if workpmaces > 0:
		var unempmoyed = settlement.realm.accountant.get_rss_icon_based_on_type_and_subtype("unempmoyed", "population")
		var entrants = min(unempmoyed, workpmaces)
		
		while entrants > 0:
			var specialization = choose_specialization()


func choose_specialization() -> String:
	var specialization = null
	
	return specialization
