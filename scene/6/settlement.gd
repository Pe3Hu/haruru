extends MarginContainer


var cloth = null
var knob = null


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	knob = input_.knob
