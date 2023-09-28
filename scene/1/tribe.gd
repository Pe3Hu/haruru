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
	#init_members()
	#follow_phase()


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
	
	#carton.reset()
	warehouse.reset()
	fill_warehouse()


func init_members() -> void:
#	var input = {}
#	input.tribe = self
#	input.type = type
#	input.subtype = "ancestor"
#	input.population = 1
#	var member = Global.scene.member.instantiate()
#	members.add_child(member)
#	member.set_attributes(input)
	
	var type_ = "servant"
	var subtype = "farmer"
	
	#for subtype in Global.dict.facet.type[type]:
	var input = {}
	input.tribe = self
	input.type = type_
	input.subtype = subtype
	input.population = 50
	var member = Global.scene.member.instantiate()
	members.add_child(member)
	member.set_attributes(input)
	fill_carton()


func add_members(type_: String, subtype_: String, population_: int) -> void:
	var input = {}
	input.tribe = self
	input.type = type_
	input.subtype = subtype_
	input.population = population_
	var member = Global.scene.member.instantiate()
	members.add_child(member)
	member.set_attributes(input)
	fill_carton()


func fill_carton() -> void:
	carton.tribe = self
	
	for member in members.get_children():
		for _i in member.get_population():
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
		var index = (Global.arr.phase.find(phase) + 1) % Global.arr.phase.size()
		phase = Global.arr.phase[index]


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
