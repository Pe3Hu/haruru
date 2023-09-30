extends MarginContainer


@onready var icon = $HBox/Icon
@onready var population = $HBox/Population
@onready var facets = $HBox/Facets

var tribe = null
var fieldwork = null
var dice = null
var outcomes = []
var type = null
var specialization = null
var index = null
var hunger = 0
var malady = 0
var abode = null
var lunch = 1


func set_attributes(input_: Dictionary) -> void:
	tribe = input_.tribe
	type = input_.type
	specialization = input_.specialization
	index = Global.num.index.member
	Global.num.index.member += 1
	
	tribe.realm.manager.members.append(self)
	tribe.realm.manager.queues.homeless.append(self)
	
	init_dice()


func init_dice() -> void:
	var input = {}
	input.member = self
	input.box = tribe.carton.preparation
	dice = Global.scene.dice.instantiate()
	tribe.carton.preparation.dices.add_child(dice)
	dice.set_attributes(input)
	tribe.carton.preparation.update_dices_columns()


func get_attributes() -> Dictionary:
	var input = {}
	input.tribe = tribe
	input.type = type
	input.specialization = specialization
	
	return input


func extract_raw(raw_: String, value_: int) -> void:
	tribe.warehouse.change_resource_value(raw_, value_)
	if Global.dict.servant.leftover.has(specialization):
		var leftover = Global.dict.servant.leftover[specialization]
		var value = value_ * 1.0
		tribe.warehouse.change_resource_value(leftover, value)


func produce_product(product_: String, value_: int) -> void:
	var raw = Global.dict.product[product_]
	var available = tribe.warehouse.get_value_of_resource_available_for_withdraw(raw, -value_)
	tribe.warehouse.change_resource_value(raw, -available)
	tribe.warehouse.change_resource_value(product_, available)


func add_outcome(outcome_: String) -> void:
	#print([Global.node.sketch.day.text, index, outcome_])
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
			for _j in indexs.size():#range(indexs.size() - 1, -1, -1):
				var index_ = indexs[_j]
				outcomes.remove_at(index_)
			
			#print([Global.node.sketch.day.text, "member check_critical is true", index, indexs])
			return


func check_standard() -> void:
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
				for _j in indexs.size():#range(indexs.size() - 1, -1, -1):
					var index_ = indexs[_j]
					outcomes.remove_at(index_)
				
				#print([Global.node.sketch.day.text, "member check_standard is true", index, indexs])
				return
		else:
			_i = 0


func meal() -> void:
	var thresholds = [3, 6, 9]
	var charge = 0
	
	if hunger + lunch > 0:
		for _i in abs(lunch):
			hunger += sign(lunch)
			
			if thresholds.has(hunger):
				charge += 1
	else:
		hunger = 0
	
	if sign(lunch) > 0:
		dice.add_debuffs(charge)
	else:
		dice.add_buffs(charge)
	
	lunch = 1


func sleep() -> void:
	var value = 0
	
	if abode == null:
		value = 1
	else:
		value = -1

	var thresholds = [5, 10, 15, 20, 25]
	var charge = 0
	
	if malady + value > 0:
		for _i in abs(value):
			malady += sign(value)
			
			if thresholds.has(hunger):
				charge += 1
	else:
		malady = 0
	
	if sign(value) > 0:
		dice.add_debuffs(charge)
	else:
		dice.add_buffs(charge)
	
