extends MarginContainer


@onready var flaps = $Flaps
@onready var knobs = $Knobs
@onready var seams = $Seams
@onready var patchs = $Patchs
@onready var frontiers = $Frontiers
@onready var states = $States
@onready var earldoms = $States/Earldoms
@onready var dukedoms = $States/Dukedoms
@onready var kingdoms = $States/Kingdoms
@onready var empires = $States/Empires
@onready var settlements = $Settlements


var square = 0
var layer = null
var grid = {}
var couplers = {}
var selected = {}
var corners = {}
var liberty = null


func _ready() -> void:
	liberty = Node2D.new()
	init_knobs()
	init_flaps()
	add_new_seams()
	glue_flaps()
	calc_flap_squares()
	init_lairs()
	init_frontiers()
	init_flap_terrains()
	init_flap_abundances()
	init_states()
	init_state_hubs()
	init_state_capitals()
	init_settlement()
	shift_layer(0)
	#find_furthest_earldom_in_biggest_empire()
	
	
	selected.patch = 0
	
	for state in Global.arr.state:
		selected[state] = 0
	
	#shift_patch_with_neighbors(0)
	
#	var state = earldoms.get_child(0)#dukedom earldoms
#	if state != null:
#		state.paint_patchs(Color.BLACK)
#
#		for neighbor in state.neighbors:
#			neighbor.paint_patchs(Color.WHITE)


func reset() -> void:
	square = 0
	layer = null
	grid = {}
	couplers = {}
	selected = {}
	corners = {}
	
	for node in get_children():
		if node.get_class() == "Node2D":
			if node.name != "States":
				for child in node.get_children():
					node.remove_child(child)
					child.queue_free()
			else:
				for parent in node.get_children():
					for child in parent.get_children():
						node.remove_child(child)
						child.queue_free()


func init_knobs() -> void:
	custom_minimum_size = Vector2(Global.num.size.flap.row, Global.num.size.flap.col) * Global.num.size.flap.a
	grid.knob = {}
	grid.lair = {}
	grid.hub = {}
	
	for _i in Global.num.size.flap.row + 1:
		for _j in Global.num.size.flap.col + 1:
			var input = {}
			input.type = "corner"
			input.cloth = self
			input.position = Vector2(_i,_j) * Global.num.size.flap.a
			
			var knob = Global.scene.knob.instantiate()
			knobs.add_child(knob)
			knob.set_attributes(input)


func init_flaps() -> void:
	var border = Vector2(Global.num.size.flap.row, Global.num.size.flap.col) * Global.num.size.flap.a
	
	for vector in grid.knob:
		if vector.x < border.x && vector.y < border.y:
			var input = {}
			input.cloth = self
			input.type = "square"
			input.knobs = []
			
			for neighbor in Global.dict.neighbor.zero:
				var neighbor_vector = vector + neighbor * Global.num.size.flap.a
				input.knobs.append(grid.knob[neighbor_vector])
			
			var flap = Global.scene.flap.instantiate()
			flaps.add_child(flap)
			flap.set_attributes(input)
			flap.init_seams()
			#var a = null
	
	#set_flap_neighbors()


func set_flap_neighbors() -> void:
	for first_knob in couplers:
		for second_knob in couplers[first_knob]:
			var seam = couplers[first_knob][second_knob]
			
			if seam.flaps.size() > 1:
				var first_flap = seam.flaps.front()
				var second_flap = seam.flaps.back()
				first_flap.neighbors[seam] = second_flap
				second_flap.neighbors[seam] = first_flap


func add_new_seams() -> void:
	var unsliced_seams = []
	
	for first in couplers:
		for second in couplers[first]:
			var seam = couplers[first][second]
			
			if !unsliced_seams.has(seam):
				unsliced_seams.append(seam)
	
	for seam in unsliced_seams:
		seam.cut()

	rework_flaps()


func rework_flaps() -> void:
	var new_flabs = Node2D.new()
	var edges = []
	var centers = {}
	
	for vector in grid.knob:
		var knob = grid.knob[vector]
		
		match knob.type:
			"corner":
				for _i in couplers[knob].keys().size():
					var first = couplers[knob].keys()[_i]
					
					for _j in range(_i,couplers[knob].size()):
						var second = couplers[knob].keys()[_j]
						
						if first.position.x != second.position.x && first.position.y != second.position.y:
							var input = {}
							input.cloth = self
							input.knobs = [knob, first, second]
							input.type = "corner"
							
							var flap = Global.scene.flap.instantiate()
							new_flabs.add_child(flap)
							flap.set_attributes(input)
			"edge":
				edges.append(knob)
	
	for _i in Global.num.size.flap.row:
		for _j in Global.num.size.flap.col:
			var center = Vector2(_i + 0.5 ,_j + 0.5) * Global.num.size.flap.a
			centers[center] = []
			
			for edge in edges:
				var d = abs(edge.position.x - center.x) + abs(edge.position.y - center.y)
				
				if d < Global.num.size.flap.a:
					centers[center].append(edge)
	
	
	for center in centers:
		var trios = [[],[]]
		trios[0].append_array(centers[center])
		trios[1].append_array(centers[center])
		var first = trios[0].pick_random()
		trios[0].erase(first)
		var second = null
		
		for knob in trios[0]:
			var x = abs(knob.position.x - first.position.x)
			var y = abs(knob.position.y - first.position.y)
			
			if x == Global.num.size.flap.a || y == Global.num.size.flap.a:
				second = knob
				break
		
		trios[1].erase(second)
		
		for trio in trios:
			var input = {}
			input.cloth = self
			input.knobs = trio
			input.type = "center"
			var flap = Global.scene.flap.instantiate()
			new_flabs.add_child(flap)
			flap.set_attributes(input)
	
	for flap in flaps.get_children():
		flaps.remove_child(flap)
		flap.queue_free()
	
	for flap in new_flabs.get_children():
		new_flabs.remove_child(flap)
		flaps.add_child(flap)
	
	set_flap_neighbors()


func glue_flaps() -> void:
	var unglueds = []
	var glueds = []
	unglueds.append_array(flaps.get_children())
	
	while unglueds.size() > 0:
		var available_flaps = []
		var current_flap = unglueds.pick_random()
		var options = []
		
		for component in Global.dict.flap.component:
			for types in Global.dict.flap.component[component]:
				if types.has(current_flap.type):
					for _i in Global.dict.flap.duplicate[component]:
						options.append(types)
		
		var types = []
		var origin_types = []
		types.append_array(options.pick_random())
		origin_types.append_array(types)
		available_flaps.append(current_flap)
		unglueds.erase(current_flap)
		types.erase(current_flap.type)
		
		while types.size() > 0:
			var neighbors = []
			
			for flap in available_flaps:
				for seam in flap.neighbors.keys():
					var neighbor = flap.neighbors[seam]
					
					if unglueds.has(neighbor) && types.has(neighbor.type):
						neighbors.append(neighbor)
			
			if neighbors.size() == 0:
				types = []
			else:
				current_flap = neighbors.pick_random()
				available_flaps.append(current_flap)
				unglueds.erase(current_flap)
				types.erase(current_flap.type)
		
		if origin_types == ["corner", "corner", "corner", "corner"] && available_flaps.size() != origin_types.size():
			unglueds.append_array(available_flaps)
		else:
			glueds.append(available_flaps)
	
	for glued in glueds:
		var input = {}
		input.cloth = self
		input.flaps = glued
		
		var patch = Global.scene.patch.instantiate()
		patchs.add_child(patch)
		patch.set_attributes(input)
	
	for patch in patchs.get_children():
		patch.connect_flaps()
	
	for seam in seams.get_children():
		for flap in seam.flaps:
			if flap.patch == null:
				seams.remove_child(seam)
				seam.queue_free()
				break
	
	set_patch_elements()


func set_patch_elements() -> void:
	var origin = patchs.get_child(0)
	var unpainted = [origin]
	
	while unpainted.size() > 0:
		var patch = unpainted.pop_front()
		var elements = []
		elements.append_array(Global.arr.element)
		
		for seam in patch.neighbors.keys():
			var neighbor = patch.neighbors[seam]
			elements.erase(neighbor.element)
			
			if neighbor.element == null && !unpainted.has(neighbor):
				unpainted.append(neighbor)
		
		if elements.is_empty():
			#reset()
			#_ready()
			#return
			unpainted = [origin]

			for patch_ in patchs.get_children():
				patch_.element = null
		else:
			patch.element = elements.pick_random()
			patch.set_element_flaps()
	
	for patch in patchs.get_children():
		patch.init_polygon()


func calc_flap_squares() -> void:
	square = pow(Global.num.size.flap.a, 2) * Global.num.size.flap.col * Global.num.size.flap.row
	#var square_area = pow(Global.num.size.flap.a, 2) / 4
	
	for flap in flaps.get_children():
		flap.calc_square()
		flap.patch.square += flap.square


func init_lairs() -> void:
	for patch in patchs.get_children():
		patch.init_lair()


func init_frontiers() -> void:
	for patch in patchs.get_children():
		var available_seams = []
		
		for flap in patch.flaps:
			for seam in flap.seams:
				if seam.knobs.front().type != seam.knobs.back().type:
					if !available_seams.has(seam):
						available_seams.append(seam)
					else:
						available_seams.erase(seam)
		
		for seam in patch.neighbors:
			if !available_seams.has(seam):
				available_seams.append(seam)
		
		for seam in available_seams:
			var input = {}
			input.seam = seam
			input.lair = patch.lair
			input.cloth = self
			
			var frontier = Global.scene.frontier.instantiate()
			frontiers.add_child(frontier)
			frontier.set_attributes(input)
	
	for frontier in frontiers.get_children():
		frontier.paint_by_index()


func init_flap_terrains() -> void:
	var limit_square = square / 2 / Global.color.terrain.keys().size()
	var wastelands = []
	var datas = []
	var grands = {}
	var hegemony = {}
	var insulation = {}
	
	for flap in flaps.get_children():
		var data = {}
		data.square = flap.square
		data.flap = flap
		datas.append(data)
		wastelands.append(flap)
	
	datas.sort_custom(func(a, b): return a.square > b.square)
	
	for terrain in Global.color.terrain:
		var flap = datas.pop_front().flap
		wastelands.erase(flap)
		grands[terrain] = [flap]
		flap.set_terrain(terrain)
	
	for terrain in grands:
		var grand_square = grands[terrain].front().square
		
		while grand_square < limit_square:
			insulation[terrain] = []
			
			for flap in grands[terrain]:
				for seam in flap.neighbors:
					var neighbor = flap.neighbors[seam]
					
					if wastelands.has(neighbor) and !insulation[terrain].has(neighbor):
						insulation[terrain].append(neighbor)
			
			if insulation[terrain].is_empty():
				grand_square = limit_square
			else:
				var flap = insulation[terrain].pick_random()
				wastelands.erase(flap)
				grands[terrain].append(flap)
				flap.set_terrain(terrain)
				grand_square += flap.square
		
		hegemony[terrain] = grand_square
	
	var lobes = 0
	var remnants = {}
	
	for terrain in Global.dict.terrain.prevalence:
		lobes += Global.dict.terrain.prevalence[terrain]
	
	var weight = wastelands.size() / lobes
	
	for terrain in Global.dict.terrain.prevalence:
		remnants[terrain] = weight * Global.dict.terrain.prevalence[terrain]
		lobes -= Global.dict.terrain.prevalence[terrain]
	
	remnants["plain"] += lobes
	
#	while !insulation.is_empty():
#		refine_insulation(insulation, wastelands, remnants)
#
#	while !wastelands.is_empty():
#		refine_wasteland(wastelands, remnants)
	
	while !wastelands.is_empty():
		incentivize_minority(hegemony, insulation, wastelands)


func refine_insulation(insulation_: Dictionary, wastelands_: Array, remnants_: Dictionary) -> void:
	var terrain = {}
	terrain.grand = insulation_.keys().pick_random()
	
	var flap = insulation_[terrain.grand].pick_random()
	var weights = {}
	
	for terrain_ in Global.dict.terrain.prevalence:
		weights[terrain_] = Global.dict.terrain.prevalence[terrain_]
	
	for seam in flap.neighbors:
		var neighbor = flap.neighbors[seam]
		
		if neighbor.terrain != null:
			weights[neighbor.terrain] += Global.dict.terrain.prevalence[neighbor.terrain]
	
	weights.erase(terrain.grand)
	flap.set_terrain(Global.get_random_key(weights))
	remnants_[flap.terrain] -= 1
	wastelands_.erase(flap)
	
	for terrain_ in insulation_:
		if insulation_[terrain_].has(flap):
			insulation_[terrain_].erase(flap)
		
		if insulation_[terrain_].is_empty():
			insulation_.erase(terrain_)


func refine_wasteland(wastelands_: Array, remnants_: Dictionary) -> void:
	var flap = wastelands_.pick_random()
	var weights = {}
	
	for terrain_ in Global.dict.terrain.prevalence:
		weights[terrain_] = Global.dict.terrain.prevalence[terrain_]
	
	for seam in flap.neighbors:
		var neighbor = flap.neighbors[seam]
		
		if neighbor.terrain != null:
			weights[neighbor.terrain] += Global.dict.terrain.prevalence[neighbor.terrain]
	
	flap.set_terrain(Global.get_random_key(weights))
	remnants_[flap.terrain] -= 1
	wastelands_.erase(flap)


func incentivize_minority(hegemony_: Dictionary, insulation_: Dictionary, wastelands_: Array) -> void:
	var datas = []
	
	for terrain in hegemony_:
		var data = {}
		data.square = hegemony_[terrain]
		data.terrain = terrain
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.square < b.square)
	var minority = datas.front().terrain
	
	var available_flaps = []
	
	for flap in wastelands_:
		if !insulation_.has(flap):
			available_flaps.append(flap)
	
	if !available_flaps.is_empty():
		var flap = available_flaps.pick_random()
		wastelands_.erase(flap)
		
		flap.set_terrain(minority)
		hegemony_[minority] += flap.square
	else:
		hegemony_[minority] += square


func init_flap_abundances() -> void:
	for flap in flaps.get_children():
		flap.set_abundance()


func init_states() -> void:
	corners.flap = []
	
	for flap in flaps.get_children():
		var counter = 0
		
		for seam in flap.seams:
			counter += seam.flaps.size()
		
		if counter == 4:
			corners.flap.append(flap)
	
	for key in Global.arr.state:
		Global.num.index.state[key] = 0
		
	var type = Global.arr.state.front()
	lay_foundation_of_states(type)
	spread_states(type)
	set_earldom_neighbors(type)
	
	for _i in range(1, Global.arr.state.size()):
		type = Global.arr.state[_i]
		lay_foundation_of_states(type)
		spread_states(type)
		set_state_neighbors(type)
	
	absorb_smaller_empires()
	update_seam_boundaries()


func do_dukedom():
	var type = Global.arr.state[1]
	add_new_senor(type)
	shift_layer(0)


func lay_foundation_of_states(type_: String) -> void:
	for flap in corners.flap:
		var input = {}
		input.type = type_
		input.cloth = self
		
		if type_ == "earldom":
			input.patch = flap.patch
		else:
			var index_ = Global.arr.state.find(type_) - 1
			var vassal = Global.arr.state[index_]
			input.state = flap.patch.state[vassal]
		
		var node = get(type_+"s")
		var state = Global.scene.state.instantiate()
		node.add_child(state)
		state.set_attributes(input)


func spread_states(type_: String) -> void:
	if type_ == "earldom":
		var end = add_new_earldom()
		
		while !end:
			end = add_new_earldom()
	else:
		var end = add_new_senor(type_)
		
		while !end:
			end = add_new_senor(type_)


func add_new_earldom() -> bool:
	var type = "earldom"
	var undeveloped = []
	var node = get(type+"s")
	
	for state in node.get_children():
		var accessible = state.get_accessible_patchs()
		undeveloped.append_array(accessible)
	
	if !undeveloped.is_empty():
		var input = {}
		input.type = type
		input.cloth = self
		var neighbors = {}
		neighbors.accessible = []
		neighbors.big = []
		neighbors.small = []
		input.patch = undeveloped.pick_random()
		
		for seam in input.patch.neighbors:
			var neighbor = input.patch.neighbors[seam]
			
			if neighbor.state[type] == null:
				neighbors.accessible.append(neighbor)
			else:
				match neighbor.state[type].limit:
					2:
						neighbors.small.append(neighbor)
					3:
						neighbors.big.append(neighbor)
		
		if neighbors.accessible.is_empty():
			var occupied_patch = null
			
			if neighbors.small.is_empty():
				if !neighbors.big.is_empty():
					occupied_patch = neighbors.big.pick_random()
				else:
					input.patch.state[type] = liberty
			else:
				occupied_patch = neighbors.small.pick_random()
			
			if occupied_patch != null:
				occupied_patch.state[type].take_patch(input.patch)
		else:
			var state = Global.scene.state.instantiate()
			node.add_child(state)
			state.set_attributes(input)
		return false
	
	return true


func add_new_senor(type_: String) -> bool:
	var node = get(type_+"s")
	var undeveloped = []
	
	for state in node.get_children():
		var accessible_vassals = state.get_accessible_vassals()
		undeveloped.append_array(accessible_vassals)
	
	if !undeveloped.is_empty():
		var input = {}
		input.type = type_
		input.cloth = self
		var neighbors = {}
		neighbors.accessible = []
		neighbors.big = []
		neighbors.small = []
		
		input.state = undeveloped.pick_random()
		
		for neighbor in input.state.neighbors:
			if neighbor.senor == null and neighbor.type == input.state.type:
				neighbors.accessible.append(neighbor)
			else:
				match neighbor.senor.limit:
					2:
						neighbors.small.append(neighbor.senor)
					3:
						neighbors.big.append(neighbor.senor)
		
		if neighbors.accessible.is_empty():# and (type_ != "empire" or empires.get_child_count() < Global.num.size.empire.limit):
			var occupied_state = null
			
			if neighbors.small.is_empty():
				if !neighbors.big.is_empty():
					occupied_state = neighbors.big.pick_random()
			else:
				occupied_state = neighbors.small.pick_random()
			
			if occupied_state != null:
				occupied_state.take_state(input.state)
			else:
				input.state.senor = liberty
		else:
			var state = Global.scene.state.instantiate()
			node.add_child(state)
			state.set_attributes(input)
		
		return false
	
	return true


func set_earldom_neighbors(type_: String) -> void:
	var node = get(type_+"s")
	
	for state in node.get_children():
		for patch in state.patchs:
			for seam in patch.neighbors:
				var neighbor = patch.neighbors[seam]
				var neighbor_state = neighbor.state[type_]
				
				if !state.neighbors.has(neighbor_state) and neighbor_state != state and neighbor_state != liberty:
					state.neighbors.append(neighbor_state)
					neighbor_state.neighbors.append(state)


func set_state_neighbors(type_: String) -> void:
	var node = get(type_+"s")
	
	for state in node.get_children():
		for vassal in state.vassals:
			for neighbor in vassal.neighbors:
				if neighbor.senor != null and neighbor.senor != liberty:
					if !state.neighbors.has(neighbor.senor) and neighbor.senor != state and neighbor.senor.type == state.type:
						state.neighbors.append(neighbor.senor)


func expand_empires() -> void:
	for empire in empires.get_children():
		empire.limit += 1
		empire.fill_to_limit()
		empire.limit = empire.vassals.size()


func absorb_smaller_empires() -> void:
	while empires.get_child_count() > Global.num.size.empire.limit:
		var datas = []
		
		for empire in empires.get_children():
			var data = {}
			data.empire = empire
			data.patchs = empire.patchs.size()
			datas.append(data)
		
		datas.sort_custom(func(a, b): return a.patchs < b.patchs)
		
		var smaller_empire = datas.front().empire
		
		for data in datas:
			if smaller_empire.neighbors.has(data.empire):
				data.empire.absorb_neighbor_state(smaller_empire)
				break


func update_seam_boundaries() -> void:
	for seam in seams.get_children():
		seam.set_boundary()


func init_state_hubs() -> void:
	for node in states.get_children():
		for state in node.get_children():
			state.init_hub()


func find_furthest_earldom_in_biggest_empire() -> void:
	var datas = []
	
	for empire in empires.get_children():
		var data = find_earldom_in_empire_based_on_remoteness(empire, "furthest")
		data.size = data.earldoms.size()
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.size > b.size)
	
	var furthest = {}
	furthest.earldom = datas.front().datas.front().earldom
	furthest.donor = datas.front().empire
	furthest.recipient = furthest.earldom.find_nearest_empire()
	#datas.front().empire.repossess_earldom(furthest)
	furthest.donor.repossess_earldom(furthest.recipient, furthest.earldom)
	furthest.earldom.paint_patchs(Color.DIM_GRAY)
	shift_layer(0)


func find_earldom_in_empire_based_on_remoteness(empire_: MarginContainer, remoteness_: String) -> Dictionary:
	var sign = 1
	
	match remoteness_:
		"nearest":
			sign = -1
		"furthest":
			sign = 1
	
	var datas = []
	var earldoms = []
	
	for patch in empire_.patchs:
		if !earldoms.has(patch.state["earldom"]):
			earldoms.append(patch.state["earldom"])
	
	for earldom in earldoms:
		var data = {}
		data.earldom = earldom
		data.d = earldom.hub.position.distance_to(empire_.hub.position) * sign
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.d > b.d)
	return datas.front()


func find_furthest_patch() -> void:
	var datas = []
	
	for empire in empires.get_children():
		var data = {}
		data.datas = []
		
		for patch in empire.patchs:
			var data_ = {}
			data_.patch = patch
			data_.d = patch.lair.position.distance_to(empire.hub.position)
			data.datas.append(data_)
		
		data.datas.sort_custom(func(a, b): return a.d > b.d)
		data.furthest = data.datas.front().d
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.furthest > b.furthest)
	
	var furthest = datas.front().datas.front().patch
	furthest.paint_flaps(Color.DIM_GRAY)


func init_state_capitals() -> void:
	for node in states.get_children():
		for state in node.get_children():
			if state.type == "earldom":
				var data = find_patch_in_state_based_on_remoteness(state, "nearest")
				data.patch.lair.set_as_state_capital(state)
			else:
				var data = find_vassal_in_state_based_on_remoteness(state, "nearest")
				data.vassal.capital.set_as_state_capital(state)


func find_patch_in_state_based_on_remoteness(state_: MarginContainer, remoteness_: String) -> Dictionary:
	var sign = 1
	
	match remoteness_:
		"nearest":
			sign = -1
		"furthest":
			sign = 1
	
	var datas = []
	var earldoms = []
	
	for patch in state_.patchs:
		var data = {}
		data.patch = patch
		data.d = patch.lair.position.distance_to(state_.hub.position) * sign
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.d > b.d)
	return datas.front()


func find_vassal_in_state_based_on_remoteness(state_: MarginContainer, remoteness_: String) -> Dictionary:
	var sign = 1
	
	match remoteness_:
		"nearest":
			sign = -1
		"furthest":
			sign = 1
	
	var datas = []
	var vassals = []
	
	for vassal in state_.vassals:
		var data = {}
		data.vassal = vassal
		data.d = vassal.capital.position.distance_to(state_.hub.position) * sign
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.d > b.d)
	return datas.front()


func init_settlement() -> void:
	for empire in empires.get_children():
		empire.capital.init_settlement()


func shift_layer(shift_: int) -> void:
	var index = 9 
	
	if layer != null:
		index = Global.arr.layer.cloth.find(layer)
		index = (index + shift_ + Global.arr.layer.cloth.size()) % Global.arr.layer.cloth.size()
	
	layer = Global.arr.layer.cloth[index]
	
	for knob in knobs.get_children():
		if knob.type == "hub" :
			knob.visible = false
		else:
			if knob.type != "lair" and knob.type != "capital":
				knob.visible = false
	
	for flap in flaps.get_children():
		match layer:
			"flap":
				flap.paint_based_on_index()
			"patch":
				flap.paint_based_on_patch_index()
			"terrain":
				flap.paint_based_on_terrain()
			"element":
				flap.paint_based_on_element()
			"abundance":
				flap.paint_based_on_abundance()
			"earldom":
				flap.paint_based_on_state_type_index(layer)
			"dukedom":
				flap.paint_based_on_state_type_index(layer)
			"kingdom":
				flap.paint_based_on_state_type_index(layer)
			"empire":
				flap.paint_based_on_state_type_index(layer)
			"realm":
				flap.paint_based_on_terrain()
				#flap.paint_based_on_realm_terrain()
	
	for seam in seams.get_children():
		if Global.arr.state.has(layer):
			seam.visible = seam.boundary.state[layer]
		else:
#			if layer == "terrain":
#				seam.visible = !seam.boundary.realms.is_empty()
#			else:
			if layer == "realm":
				seam.visible = !seam.boundary.realms.is_empty()
			else:
				seam.visible = seam.boundary.patch


func shift_patch_with_neighbors(shift_) -> void:
	var patch = patchs.get_child(selected.patch)
	patch.paint_flaps(Color.GRAY)
	
	for seam in patch.neighbors:
		var neighbor = patch.neighbors[seam]
		neighbor.paint_flaps(Color.GRAY)
	
	selected.patch = (selected.patch + shift_ + patchs.get_child_count()) % patchs.get_child_count()
	patch = patchs.get_child(selected.patch)
	patch.paint_flaps(Color.BLACK)

	for seam in patch.neighbors:
		var neighbor = patch.neighbors[seam]
		neighbor.paint_flaps(Color.WHITE)


func shift_state_with_neighbors(type_: String, shift_: int) -> void:
	var node = get(type_+"s")
	var state = node.get_child(selected[type_])
	state.paint_patchs(Color.GRAY)
	
	for neighbor in state.neighbors:
		neighbor.paint_patchs(Color.GRAY)
	
	selected[type_] = (selected[type_] + shift_ + node.get_child_count()) % node.get_child_count()
	state = node.get_child(selected[type_])
	state.paint_patchs(Color.BLACK)

	for neighbor in state.neighbors:
		neighbor.paint_patchs(Color.WHITE)

