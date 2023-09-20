extends MarginContainer


var cloth = null
var type = null
var patchs = []
var vassals = []
var neighbors = []
var senor = null
var hub = null
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


func detach_patch(patch_: MarginContainer) -> void:
	patchs.erase(patch_)
	patch_.state[type] = null
	limit = patchs.size()


func take_state(state_: MarginContainer) -> void:
	if !vassals.has(state_):
		vassals.append(state_)
		state_.senor = self
		
		for patch in state_.patchs:
			patchs.append(patch)
			patch.state[type] = self
		
		if vassals.size() > limit:
			limit = vassals.size()
		
		var notify_senor = senor
		
		while notify_senor != null:
			for patch in state_.patchs:
				senor.patchs.append(patch)
			
			notify_senor = notify_senor.senor
			
		if limit == 4 and type != "empire":
			split_senor()


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
	
	if union.cores.size() == 1 and  union.deadends.size() == 3:
		var deadend = union.deadends.pick_random()
		detach_state(deadend)


func detach_state(state_: MarginContainer) -> void:
	vassals.erase(state_)
	state_.senor = null
	
	for patch in state_.patchs:
		patch.state[type] = null
	
	limit = vassals.size()
	
	var notify_senor = senor
	
	while notify_senor != null:
		for patch in state_.patchs:
			senor.patchs.erase(patch)
		
		notify_senor = notify_senor.senor
 

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
		
		if limit == 1:
			var a = null
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


func absorb_neighbor_state(neighbor_state_: MarginContainer) -> void:
	if neighbors.has(neighbor_state_):
		neighbors.erase(neighbor_state_)
		
		for neighbor in neighbor_state_.neighbors:
			if neighbor != self:
				neighbor.neighbors.append(self)
				neighbors.append(neighbor)
		
		while !neighbor_state_.vassals.is_empty():
			var vassal = neighbor_state_.vassals.pop_front()
			take_state(vassal)
		
		var node = cloth.get(neighbor_state_.type + "s")
		
		#print([neighbor_state_.index])
		for state in node.get_children():
			if state.index > neighbor_state_.index:
				#print(state.index, " > ", state.index - 1)
				state.index -= 1
			
			if state.neighbors.has(neighbor_state_):
				state.neighbors.erase(neighbor_state_)
		
		node.remove_child(neighbor_state_)
		Global.num.index.state[neighbor_state_.type] = node.get_child_count() + 1
		neighbor_state_.queue_free()


func init_hub() -> void:
	var input = {}
	input.type = "hub"
	input.cloth = cloth
	input.position = Vector2()
	
	for patch in patchs:
		input.position += patch.lair.position
	
	input.position /= patchs.size()
	hub = Global.scene.knob.instantiate()
	cloth.knobs.add_child(hub)
	hub.set_attributes(input)


func find_nearest_empire() -> MarginContainer:
	var datas = []
	
	for empire in cloth.empires.get_children():
		if empire != patchs.front().state["empire"]:
			var data = {}
			data.empire = empire
			data.d = hub.position.distance_to(empire.hub.position)
			datas.append(data)
	
	datas.sort_custom(func(a, b): return a.d < b.d)
	return datas.front().empire


func repossess_earldom(recipient_: MarginContainer, earldom_: MarginContainer) -> void:
	earldom_.senor.detach_state(earldom_)
	
	for neighbor in earldom_.neighbors:
		var empire = neighbor.patchs.front().state["empire"]
		
		if empire == recipient_:
			neighbor.senor.take_state(earldom_)
	
	
	#earldom_.senor = cloth.liberty


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
