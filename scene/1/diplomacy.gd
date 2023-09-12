extends MarginContainer


@onready var tribes = $Tribes


func _ready() -> void:
	init_tribes()


func init_tribes() -> void:
	var input = {}
	input.diplomacy = self
	input.type = "vampire"
	var tribe = Global.scene.tribe.instantiate()
	tribes.add_child(tribe)
	tribe.set_attributes(input)


func do_it() -> void:
	for tribe in tribes.get_children():
		tribe.follow_phase()
