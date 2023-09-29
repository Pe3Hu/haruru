extends MarginContainer


@onready var icon = $HBox/Icon
@onready var population = $HBox/Population
@onready var facets = $HBox/Facets

var tribe = null
var fieldwork = null
var dices = []
#var workplace = null
#var series = {}
var outcomes = []
var type = null
var specialization = null
var index = null



func set_attributes(input_: Dictionary) -> void:
	tribe = input_.tribe
	type = input_.type
	specialization = input_.subtype
	index = Global.num.index.member
	Global.num.index.member += 1
	#workplace = Global.get_workplace_based_on_specialization(specialization)
#	series.standard = {}
#	series.standard.success = 0
#	series.standard.limit = 3
#	series.critical = {}
#	series.critical.success = 0
#	series.critical.fail = 3
#	series.standard.limit = 3
	
	
	icon.set_attributes(input_)
	input_.type = "number"
	input_.subtype = input_.population
	population.set_attributes(input_)
	init_facets()


func init_facets() -> void:
	var data = Global.dict.facet.type[type][specialization]
	var index = 0
	
	for outcome in data.outcomes:
		for _i in data.outcomes[outcome].facets:
			var input = data.outcomes[outcome].duplicate()
			input.member = self
			input.outcome = outcome
			input.index = index
			index += 1
			input.erase("facets")
			var facet = Global.scene.facet.instantiate()
			facets.add_child(facet)
			facet.set_attributes(input)


func get_population() -> int:
	return population.get_number()


func change_population(value_: int) -> void:
	population.change_number(value_)


func get_attributes() -> Dictionary:
	var input = {}
	input.tribe = tribe
	input.type = type
	input.subtype = specialization
	input.population = population.text
	
	return input


func extract_raw(raw_: String, value_: int) -> void:
	tribe.warehouse.change_resource_value(raw_, value_)


func produce_product(product_: String, value_: int) -> void:
	var raw = Global.dict.product[product_]
	var available = tribe.warehouse.get_value_of_resource_available_for_withdraw(raw, -value_)
	tribe.warehouse.change_resource_value(raw, -available)
	tribe.warehouse.change_resource_value(product_, available)


func add_outcome(outcome_: String) -> void:
	if outcomes.size() >= 10:
		outcomes.pop_front()
	
	outcomes.append(outcome_)
	
	if outcome_.contains("critical"):
		check_critical()
	else:
		check_standard()


func check_critical() -> void:
	var limit = {}
	limit.max = min(5, outcomes.size())
	limit.min = 2
	var indexs = []
	
	for _i in range(outcomes.size() - 1, outcomes.size() - limit.max, -1):
		var outcome = outcomes[_i]
		
		if outcome == "critical success":
			indexs.append(_i)
	
		if indexs.size() == limit.min:
			for _j in range(indexs.size() - 1, -1, -1):
				var index = indexs[_j]
				outcomes.remove_at(index)
			
			print([Global.node.sketch.day.text, "member check_critical is true", index, indexs])
			return


func check_standard() -> void:
	var flag = true
	var limit = {}
	limit.max = min(3, outcomes.size())
	limit.min = 3
	var indexs = []
	var _i = outcomes.size() - 1
	
	while _i > 0:
		var outcome = outcomes[_i]
		
		if outcome == "success":
			indexs.append(_i)
			_i -= 1
			
			if indexs.size() == limit.min:
				for _j in range(indexs.size() - 1, -1, -1):
					var index = indexs[_j]
					outcomes.remove_at(index)
				
				print([Global.node.sketch.day.text, "member check_standard is true", index, indexs])
				return
		else:
			_i = 0
	
