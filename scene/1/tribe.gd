extends MarginContainer


@onready var carton = $VBox/Carton
@onready var members = $VBox/Members

var diplomacy = null
var type = null


func set_attributes(input_: Dictionary) -> void:
	diplomacy = input_.diplomacy
	type = input_.type
	init_members()


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
