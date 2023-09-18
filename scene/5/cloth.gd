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

var square = 0
var layer = null
var grid = {}
var couplers = {}
var selected = {}
var corners = {}


func _ready() -> void:
	init_knobs()
	init_flaps()
	add_new_seams()
	glue_flaps()
	calc_flap_squares()
	init_lairs()
	init_frontiers()
	update_seam_boundaries()
	init_patch_terrains()
	init_flap_abundances()
	init_states()
	shift_layer(0)
	
	
	selected.patch = 0
	selected.earldom = 0
	selected.dukedom = 0
	
	#shift_patch_with_neighbors(0)
	
#	var state = earldoms.get_child(0)#dukedom earldoms
#	if state != null:
#		state.paint_patchs(Color.BLACK)
#
#		for neighbor in state.neighbors:
#			neighbor.paint_patchs(Color.WHITE)



func init_knobs() -> void:
	custom_minimum_size = Vector2(Global.num.size.flap.row, Global.num.size.flap.col) * Global.num.size.flap.a
	grid.knob = {}
	
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
#
#	var n = 6
#	var counts = {}
#
#	for _i in range(2, n * 3):
#		counts[_i] = 0
#
#	for patch in patchs.get_children():
#		var area = patch.square / square_area * n
#
#		for count in counts:
#			if area < count:
#				counts[count] += 1
#				break
	pass


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


func update_seam_boundaries() -> void:
	for seam in seams.get_children():
		seam.set_boundary()


func init_patch_terrains() -> void:
	for patch in patchs.get_children():
		for flap in patch.flaps:
			flap.paint_gray()
	
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
		flap.terrain = terrain
		flap.paint_based_on_terrain()
	
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
				flap.terrain = terrain
				flap.paint_based_on_terrain()
				grand_square += flap.square
		
		
		hegemony[terrain] = grand_square
	
	while !wastelands.is_empty():
		incentivize_minority(hegemony, insulation, wastelands)


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
		
		flap.terrain = minority
		flap.paint_based_on_terrain()
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
		
#	var node = get("earldoms")
#
#	var indexs = []
#	for state in node.get_children():
#		if state.senor == null:
#			print([state.index, state.neighbors.size()])
#
#	for patch in patchs.get_children():
#		if patch.state["dukedom"] == null and !indexs.has(patch.state["earldom"].senor.index):
#			var senor = patch.state["earldom"].senor
#			indexs.append(senor.index)
#			#print([patch.state["earldom"].index, patch.state["earldom"].senor.index, patch.state["earldom"].neighbors.size()])
#	print(indexs.size())

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

#	for patch in patchs.get_children():
#		if patch.state[type] == null:
#			undeveloped.append(patch)
	
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
					pass
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
	
#	var index_ = Global.arr.state.find(type_) - 1
#	var vassal = Global.arr.state[index_]
#	var vassal_node = get(vassal+"s")
#
#	for state in vassal_node.get_children():
#		if state.senor == null and state.type == vassal:
#			undeveloped.append(state)
	
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
		
		if neighbors.accessible.is_empty():
			var occupied_state = null
			
			if neighbors.small.is_empty():
				if !neighbors.big.is_empty():
					occupied_state = neighbors.big.pick_random()
			else:
				occupied_state = neighbors.small.pick_random()
			
			if occupied_state != null:
				occupied_state.take_state(input.state)
			else:
				var a = null
				pass
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
				
				if !state.neighbors.has(neighbor_state) and neighbor_state != state:
					state.neighbors.append(neighbor_state)
					neighbor_state.neighbors.append(state)


func set_state_neighbors(type_: String) -> void:
	var node = get(type_+"s")
	
#	for patch in patchs.get_children():
#		if patch.state[type_] == null:
#			var index_ = Global.arr.state.find(type_) - 1
#			var vassal = Global.arr.state[index_]
#			var state = patch.state[vassal]
#			patch.state[type_] = patch.state[vassal].senor
#			state.senor.take_state(state)
	
	for state in node.get_children():
		for vassal in state.vassals:
			for neighbor in vassal.neighbors:
				if !state.neighbors.has(neighbor.senor) and neighbor.senor != state and neighbor.senor.type == state.type:
					state.neighbors.append(neighbor.senor)
		


func init_settlements() -> void:
	pass


func shift_layer(shift_: int) -> void:
	var index = 8 
	
	if layer != null:
		index = Global.arr.layer.cloth.find(layer)
		index = (index + shift_ + Global.arr.layer.cloth.size()) % Global.arr.layer.cloth.size()
	
	layer = Global.arr.layer.cloth[index]
	
	for flap in flaps.get_children():
		#flap.visible = false
		
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


func shift_earldom_with_neighbors(shift_) -> void:
	var earldom = earldoms.get_child(selected.earldom)
	earldom.paint_patchs(Color.GRAY)
	
	for neighbor in earldom.neighbors:
		neighbor.paint_patchs(Color.GRAY)
	
	selected.earldom = (selected.earldom + shift_ + earldoms.get_child_count()) % earldoms.get_child_count()
	earldom = earldoms.get_child(selected.earldom)
	earldom.paint_patchs(Color.BLACK)

	for neighbor in earldom.neighbors:
		neighbor.paint_patchs(Color.WHITE)


func shift_dukedom_with_neighbors(shift_) -> void:
	var dukedom = dukedoms.get_child(selected.dukedom)
	dukedom.paint_patchs(Color.GRAY)
	
	for neighbor in dukedom.neighbors:
		neighbor.paint_patchs(Color.GRAY)
	
	selected.dukedom = (selected.dukedom + shift_ + dukedoms.get_child_count()) % dukedoms.get_child_count()
	dukedom = dukedoms.get_child(selected.dukedom)
	dukedom.paint_patchs(Color.BLACK)

	for neighbor in dukedom.neighbors:
		neighbor.paint_patchs(Color.WHITE)

