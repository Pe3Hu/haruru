extends MarginContainer


var cloth = null
var type = null
var patchs = []
var limit = null
var index = null


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	type = input_.type
	take_patch(input_.patch)
	limit = Global.arr.limit.pick_random()
	index = Global.num.index.state[type]
	Global.num.index.state[type] += 1
	cloth.hierarchy[type].append(self)
	
	fill_to_limit()


func fill_to_limit() -> void:
	while patchs.size() < limit:
		encroach()


func encroach() -> void:
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


func take_patch(patch_: MarginContainer) -> void:
	patchs.append(patch_)
	patch_.state[type] = self
	
	if patchs.size() == 4:
		split()


func split() -> void:
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
	detach_patch(deadend)
	detach_patch(deadend_neighbor)
	
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


func detach_patch(patch_: MarginContainer) -> void:
	patchs.erase(patch_)
	patch_.state[type] = null


func recolor_based_on_index() -> void:
	for patch in patchs:
		for flap in patch.flaps:
			flap.visible = false


func hide_patchs() -> void:
	for patch in patchs:
		patch.hide_flaps()
	
