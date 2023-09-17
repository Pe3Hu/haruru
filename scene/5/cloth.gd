extends MarginContainer


@onready var flaps = $Flaps
@onready var knobs = $Knobs
@onready var seams = $Seams
@onready var patchs = $Patchs
@onready var frontiers = $Frontiers


var grid = {}
var couplers = {}


func _ready() -> void:
	init_knobs()
	init_flaps()
	add_new_seams()
	glue_flaps()
	calc_flap_squares()
	init_lairs()
	init_frontiers()
	update_seam_boundaries()
	
#	var flap = flaps.get_child(1)
#	flap.paint_gray()
#
#	for seam in flap.neighbors:
#		var neighbor = flap.neighbors[seam]
#		neighbor.paint_gray()


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
			var a = null
	
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
		var flaps = []
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
		flaps.append(current_flap)
		unglueds.erase(current_flap)
		types.erase(current_flap.type)
		
		while types.size() > 0:
			var neighbors = []
			
			for flap in flaps:
				for seam in flap.neighbors.keys():
					var neighbor = flap.neighbors[seam]
					
					if unglueds.has(neighbor) && types.has(neighbor.type):
						neighbors.append(neighbor)
			
			if neighbors.size() == 0:
				types = []
			else:
				current_flap = neighbors.pick_random()
				flaps.append(current_flap)
				unglueds.erase(current_flap)
				types.erase(current_flap.type)
		
		if origin_types == ["corner", "corner", "corner", "corner"] && flaps.size() != origin_types.size():
			unglueds.append_array(flaps)
		else:
			glueds.append(flaps)
	
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
	var square_area = Global.num.size.flap.a * Global.num.size.flap.a / 4
	
	for flap in flaps.get_children():
		flap.calc_square()
		flap.patch.square += flap.square
	
	var n = 6
	var counts = {}
	
	for _i in range(2, n * 3):
		counts[_i] = 0
	
	for patch in patchs.get_children():
		var area = patch.square / square_area * n
		
		for count in counts:
			if area < count:
				counts[count] += 1
				break
	
	print("calc_flap_squares: ", counts)


func init_lairs() -> void:
	for patch in patchs.get_children():
		patch.init_lair()


func init_frontiers() -> void:
	for patch in patchs.get_children():
		var seams = []
		
		for flap in patch.flaps:
			for seam in flap.seams:
				if seam.knobs.front().type != seam.knobs.back().type:
					if !seams.has(seam):
						seams.append(seam)
					else:
						seams.erase(seam)
		
		for seam in patch.neighbors:
			if !seams.has(seam):
				seams.append(seam)
		
		for seam in seams:
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
