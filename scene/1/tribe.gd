extends MarginContainer


@onready var carton = $VBox/Carton
@onready var members = $VBox/Members
@onready var squads = $VBox/Squads
@onready var warehouse = $VBox/Warehouse
@onready var manager = $VBox/Manager

var sketch = null
var accountant = null
var realm = null
var phase = null
var index = null


func set_attributes(input_: Dictionary) -> void:
	realm = input_.realm
	sketch = realm.sketch
	index = Global.num.index.tribe
	Global.num.index.tribe += 1
	
	init_leadership()
	reset()


func init_leadership() -> void:
	var input = {}
	input.tribe = self
	accountant = Global.scene.accountant.instantiate()
	sketch.economy.accountants.add_child(accountant)
	accountant.set_attributes(input)
	manager.set_attributes(input)
	warehouse.set_attributes(input)


func reset() -> void:
	for member in members.get_children():
		for dice in member.dices:
			dice.crush()
		#member.dice.member = null
		members.remove_child(member)
		member.queue_free()
	
	warehouse.reset()


func add_members(type_: String, specialization_: String, population_: int) -> void:
	for _i in population_:
		var input = {}
		input.tribe = self
		input.type = type_
		input.specialization = specialization_
		input.population = population_
		var member = Global.scene.member.instantiate()
		members.add_child(member)
		member.set_attributes(input)
	


func fill_carton() -> void:
	carton.tribe = self
	
	for member in members.get_children():
		carton.add_dice(member)


func fill_warehouse() -> void:
	for raw in Global.dict.endowment:
		var value = Global.dict.endowment[raw]
		warehouse.change_resource_value(raw, value)


func follow_phase() -> void:
	next_phase()
	var func_name = ""
	var words = phase.split(" ")
	
	for _i in words.size():
		var word = words[_i]
		func_name += word
		
		if _i < words.size() - 1:
			func_name += "_"
	
	match phase:
		"select dices":
			carton.call(func_name)
		"roll dices":
			carton.call(func_name)
		"active dices":
			carton.call(func_name)
		"discard dices":
			carton.call(func_name)


func next_phase() -> void:
	if phase == null:
		phase = Global.arr.phase.front()
	else:
		var index_ = (Global.arr.phase.find(phase) + 1) % Global.arr.phase.size()
		phase = Global.arr.phase[index_]


func prepare_squad() -> void:
	var input = {}
	input.tribe = self
	var squad = Global.scene.squad.instantiate()
	squads.add_child(squad)
	squad.set_attributes(input)
	
	choose_mercenaries()


func choose_mercenaries() -> void:
	var squad = squads.get_children().back()
	
	for member in members.get_children():
		if member.type == "mercenary":
			var troop = member.get_population()
			squad.add_member(member, troop)
			member.change_population(troop)
