extends MarginContainer


var capital = null
var patchs = []
var boundaries = []
var states = {}
var index = null


func set_attributes(input_: Dictionary) -> void:
	capital = input_.state.capital
	index = Global.num.index.realm
	Global.num.index.realm += 1
	
	set_states(input_.state)
	push_boundaries(input_.state)


func set_states(state_: MarginContainer) -> void:
	states[state_.type] = [state_]
	var type = state_.type
	
	while type != null:
		for state in states[type]:
			for vassal in state.vassals:
				if !states.has(vassal.type):
					states[vassal.type] = []
				
				states[vassal.type].append(vassal)
		
		if states[type].front().vassals.is_empty():
			type = null
		else:
			type = states[type].front().vassals.front().type


func push_boundaries(state_: MarginContainer) -> void:
	var seams = {}
	
	for patch in state_.patchs:
		patch.realm = self
		patchs.append(patch)
		
		for flap in patch.flaps:
			for seam in flap.seams:
				if !seams.has(seam):
					seams[seam] = 0
				
				seams[seam] += 1
	
	for seam in seams:
		if seams[seam] == 1:
			boundaries.append(seam)
			seam.boundary.realms.append(self)
