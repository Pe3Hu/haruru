extends MarginContainer


@onready var carton = $VBox/Carton
@onready var members = $VBox/Members

var diplomacy = null
var type = null
var phase = null


func set_attributes(input_: Dictionary) -> void:
	diplomacy = input_.diplomacy
	type = input_.type
	init_members()
	fill_carton()
	follow_phase()


func init_members() -> void:
	var input = {}
	input.tribe = self
	input.type = type
	input.subtype = "ancestor"
	input.population = 1
	var member = Global.scene.member.instantiate()
	members.add_child(member)
	member.set_attributes(input)
	
	input.type = "servant"
	input.subtype = "farmer"
	input.population = 8
	member = Global.scene.member.instantiate()
	members.add_child(member)
	member.set_attributes(input)


func fill_carton() -> void:
	carton.tribe = self
	
	for member in members.get_children():
		for _i in member.get_population():
			carton.add_dice(member)


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
