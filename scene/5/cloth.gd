extends MarginContainer


@onready var flaps = $Flaps
@onready var knobs = $Knobs
@onready var seams = $Seams
@onready var patchs = $Patchs
@onready var frontiers = $Frontiers
@onready var states = $States

var square = 0
var layer = null
var grid = {}
var couplers = {}
var hierarchy = {}
var selected = {}


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
	#shift_patch_with_neighbors(0)



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
	lay_foundation_of_states()
	spread_states()
#
#	var type = Global.arr.state.front()
#
#	for state in hierarchy[type]:
#		if state.limit > 1:
#			state.hide_patchs()


func lay_foundation_of_states() -> void:
	for key in Global.arr.state:
		hierarchy[key] = []
		Global.num.index.state[key] = 0
	
	for flap in flaps.get_children():
		var counter = 0
		
		for seam in flap.seams:
			counter += seam.flaps.size()
		
		if counter == 4:
			var input = {}
			input.type = Global.arr.state.front()
			input.cloth = self
			input.patch = flap.patch
			
			var state = Global.scene.state.instantiate()
			states.add_child(state)
			state.set_attributes(input)


func add_states(type_: String) -> bool:
	var type = type_
	var undeveloped_patchs = []
	
	for state in hierarchy[type]:
		var accessible_patchs = state.get_accessible_patchs()
		undeveloped_patchs.append_array(accessible_patchs)
	
	if !undeveloped_patchs.is_empty():
		var input = {}
		input.type = type
		input.cloth = self
		input.patch = undeveloped_patchs.pick_random()
		
		var neighbors = {}
		neighbors.occupied = []
		neighbors.accessible = []
		
		for seam in input.patch.neighbors:
			var neighbor = input.patch.neighbors[seam]
			
			if neighbor.state[type] == null:
				neighbors.accessible.append(neighbor)
			else:
				neighbors.occupied.append(neighbor)
		
		if neighbors.accessible.is_empty():
			var occupied_patch = neighbors.occupied.pick_random()
			#occupied_patch.state[type].hide_patchs()
			occupied_patch.state[type].take_patch(input.patch)
			undeveloped_patchs.erase(input.patch)
			#input.patch.hide_flaps()
		else:
			var state = Global.scene.state.instantiate()
			states.add_child(state)
			state.set_attributes(input)
			
			for patch in state.patchs:
				undeveloped_patchs.erase(patch)
			
			var accessible_patchs = state.get_accessible_patchs()
			undeveloped_patchs.append_array(accessible_patchs)
		
		shift_layer(0)
		return false
	
	return true


func spread_states() -> void:
	var type = Global.arr.state.front()
	var end = add_states(type)
	
	while !end:
		end = add_states(type)


func spread_states_old() -> void:
	var type = Global.arr.state.front()
	var undeveloped_patchs = []
	
	for state in hierarchy[type]:
		var accessible_patchs = state.get_accessible_patchs()
		undeveloped_patchs.append_array(accessible_patchs)
		
	while !undeveloped_patchs.is_empty():
		var input = {}
		input.type = type
		input.cloth = self
		input.patch = undeveloped_patchs.pick_random()
		
		var neighbors = {}
		neighbors.occupied = []
		neighbors.accessible = []
		
		for seam in input.patch.neighbors:
			var neighbor = input.patch.neighbors[seam]
			
			if neighbor.state[type] == null:
				neighbors.accessible.append(neighbor)
			else:
				neighbors.occupied.append(neighbor)
		
		if neighbors.accessible.is_empty():
			var occupied_patch = neighbors.occupied.pick_random()
			#input.patch.hide_flaps()
			#occupied_patch.state[type].hide_patchs()
			occupied_patch.state[type].take_patch(input.patch)
			undeveloped_patchs.erase(input.patch)
		else:
			var state = Global.scene.state.instantiate()
			states.add_child(state)
			state.set_attributes(input)
			
			for patch in state.patchs:
				undeveloped_patchs.erase(patch)
			
			var accessible_patchs = state.get_accessible_patchs()
			undeveloped_patchs.append_array(accessible_patchs)


func init_settlements() -> void:
	pass


func shift_layer(shift_: int) -> void:
	var index = 5 
	
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
				flap.paint_based_on_earldom_index()
			"earldom 2":
				flap.paint_based_on_earldom_limit_2()
			"earldom 3":
				flap.paint_based_on_earldom_limit_3()


func shift_patch_with_neighbors(shift_) -> void:
	var patch = patchs.get_child(selected.patch)
	patch.hide_flaps()
	
	for seam in patch.neighbors:
		var neighbor = patch.neighbors[seam]
		neighbor.hide_flaps()
	
	selected.patch = (selected.patch + shift_ + patchs.get_child_count()) % patchs.get_child_count()
	patch = patchs.get_child(selected.patch)
	patch.paint_flaps(Color.BLACK)

	for seam in patch.neighbors:
		var neighbor = patch.neighbors[seam]
		neighbor.paint_flaps(Color.WHITE)

