extends MarginContainer


@onready var members = $Members

var tribe = null


func set_attributes(input_: Dictionary) -> void:
	tribe = input_.tribe
	


func add_member(member_: MarginContainer, troop_: int) -> void:
	var input = member_.get_attributes()
	input.population = troop_
	var member = Global.scene.member.instantiate()
	members.add_child(member)
	member.set_attributes(input)
