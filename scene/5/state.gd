extends MarginContainer


var cloth = null
var type = null
var patchs = []
var vassals = []
var neighbors = []
var senor = null
var limit = null
var index = null


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	type = input_.type
	limit = Global.arr.limit.pick_random()
	index = Global.num.index.state[type]
	Global.num.index.state[type] += 1
	
	if type == "earldom":
		take_patch(input_.patch)
	else:
		take_state(input_.state)
		
	fill_to_limit()


func take_patch(patch_: MarginContainer) -> void:
	if !patchs.has(patch_):
		patchs.append(patch_)
		patch_.state[type] = self
		
		if patchs.size() > limit:
			limit = patchs.size()
		
		if limit == 4:
			split_earldom()


func split_earldom() -> void:
	var union = {}
	union.cores = []
	union.deadends = []
	
	for patch in patchs:
		var connects = []
		
		for seam in patch.neighbors:
			var neighbor = patch.neighbors[seam]
			
			if patchs.has(neighbor):
				connects.append(neighbor)
		
		if connects.size() == 1:
			union.deadends.append(patch)
		else:
			union.cores.append(patch)
	
	if union.cores.size() == 1:
		var deadend = union.deadends.pick_random()
		detach_patch(deadend)


func split_earldom_old() -> void:
	var unions = {}
	
	for patch in patchs:
		unions[patch] = []
		
		for seam in patch.neighbors:
			var neighbor = patch.neighbors[seam]
			
			if patchs.has(neighbor):
				unions[patch].append(neighbor)
	
	var deadend = unions.keys().front()
	
	for patch in unions:
		if unions[deadend].size() > unions[patch].size():
			deadend = patch
	
	var deadend_neighbor = unions[deadend].pick_random()
	
	var leftovers = []
	
	detach_patch(deadend)
	detach_patch(deadend_neighbor)
	
	for seam in deadend.neighbors:
		var neighbor = deadend.neighbors[seam]
		
		if deadend_neighbor == neighbor:
			var input = {}
			input.type = type
			input.cloth = cloth
			input.patch = deadend
			var state = Global.scene.state.instantiate()
			cloth.states.add_child(state)
			state.set_attributes(input)

			state.take_patch(deadend_neighbor)
			state.limit = state.patchs.size()
			limit = patchs.size()
			return


func detach_patch(patch_: MarginContainer) -> void:
	patchs.erase(patch_)
	patch_.state[type] = null
	limit = patchs.size()


func take_state(state_: MarginContainer) -> void:
	if state_.senor == null:
		if !vassals.has(state_):
			vassals.append(state_)
			state_.senor = self
			
			for patch in state_.patchs:
				patchs.append(patch)
				patch.state[type] = self
			
			if vassals.size() > limit:
				limit = vassals.size()
			
			if limit == 4:
				split_senor()
	else:
		pass


func split_senor() -> void:
	var union = {}
	union.cores = []
	union.deadends = []
	
	for vassal in vassals:
		var connects = []
		
		for neighbor in vassal.neighbors:
			if vassals.has(neighbor):
				connects.append(neighbor)
		
		if connects.size() == 1:
			union.deadends.append(vassal)
		else:
			union.cores.append(vassal)
	
	if union.cores.size() == 1:
		var deadend = union.deadends.pick_random()
		detach_state(deadend)


func detach_state(state_: MarginContainer) -> void:
	vassals.erase(state_)
	state_.senor = null
	
	for patch in state_.patchs:
		patch.state[type] = null
	
	limit = vassals.size()


func split_senor_old() -> void:
	var unions = {}
	
	for vassal in vassals:
		unions[vassals] = []
		
		for neighbor in vassals.neighbors:
			if vassals.has(neighbor):
				unions[vassal].append(neighbor)
	
	var deadend = unions.keys().front()
	
	for vassal in unions:
		if unions[deadend].size() > unions[vassal].size():
			deadend = vassal
	
	var deadend_neighbor = unions[deadend].pick_random()
	detach_patch(deadend)
	detach_patch(deadend_neighbor)
	
	for neighbor in deadend.neighbors:
		if deadend_neighbor == neighbor:
			var input = {}
			input.type = type
			input.cloth = cloth
			input.state = deadend
			var state = Global.scene.state.instantiate()
			cloth.states.add_child(state)
			state.set_attributes(input)

			state.take_state(deadend_neighbor)
			state.limit = state.vassals.size()
			limit = vassals.size()
			return


func fill_to_limit() -> void:
	if type == "earldom":
		while patchs.size() < limit:
			encroach_patch()
	else:
		while vassals.size() < limit:
			encroach_state()


func encroach_patch() -> void:
	var accessible_patchs = get_accessible_patchs()
	
	if accessible_patchs.is_empty():
		limit = patchs.size()
	else:
		var patch = accessible_patchs.pick_random()
		take_patch(patch)


func get_accessible_patchs() -> Array:
	var accessible_patchs = []
	
	for patch in patchs:
		for seam in patch.neighbors:
			var neighbor = patch.neighbors[seam]
			
			if neighbor.state[type] == null and !accessible_patchs.has(neighbor):
				accessible_patchs.append(neighbor)
	
	return accessible_patchs


func encroach_state() -> void:
	var accessible_vassals = get_accessible_vassals()
	
	if accessible_vassals.is_empty():
		limit = vassals.size()
	else:
		var vassal = accessible_vassals.pick_random()
		take_state(vassal)


func get_accessible_vassals() -> Array:
	var accessible_vassals = []
	
	for vassal in vassals:
		for neighbor in vassal.neighbors:
			if neighbor.senor == null and !accessible_vassals.has(neighbor):
				accessible_vassals.append(neighbor)
	
	return accessible_vassals


func recolor_based_on_index() -> void:
	for patch in patchs:
		for flap in patch.flaps:
			flap.visible = false


func hide_patchs() -> void:
	for patch in patchs:
		patch.hide_flaps()


func paint_patchs(color_: Color) -> void:
	for patch in patchs:
		patch.paint_flaps(color_)


func take_state_old(patch_: MarginContainer) -> void:
	var index_ = Global.arr.state.find(type) - 1
	var vassal = Global.arr.state[index_]
	
	var state = patch_.state[vassal]
	
	if !vassals.has(state):
		vassals.append(state)
		state.senor = self
		
		print(state.patchs.size())
		for patch in state.patchs:
			patch.state[type] = self
			patchs.append(patch)
		
		if vassals.size() > limit:
			limit = vassals.size()
		
		#if limit == 4:
		#	split_states()
