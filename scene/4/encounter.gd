extends MarginContainer


var sketch = null
var squads = {}


func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	for squad in input_.squads:
		var tribe = squad.front().tribe
		squads[tribe] = squad
		
