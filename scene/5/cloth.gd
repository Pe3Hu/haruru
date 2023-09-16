extends MarginContainer


@onready var flaps = $Flaps
@onready var knobs = $Knobs
@onready var seams = $Seams

var grid = {}
var couplers = {}


func _ready() -> void:
	init_knobs()
	init_flaps()
	add_new_seams()
	
	var flap = flaps.get_child(1)
	
	for seam in flap.neighbors:
		var neighbor = flap.neighbors[seam]
		neighbor.paint_gray()


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
			grid.knob[input.position] = knob


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
					
					for _j in range(_i,couplers[knob].keys().size()):
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
				var d = abs(edge.vec.position.x - center.x) + abs(edge.vec.position.y - center.y)
				
				if d < Global.num.size.flap.a:
					centers[center].append(edge)
	
	for key in centers.keys():
		var trios = [[],[]]
		trios[0].append_array(centers[key])
		trios[1].append_array(centers[key])
		var first = trios[0].pick_random()
		trios[0].erase(first)
		var second = null
		
		for knob in trios[0]:
			var x = abs(knob.vec.position.x - first.vec.position.x)
			var y = abs(knob.vec.position.y - first.vec.position.y)
			
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
			new_flabs.append(flap)
			flap.set_attributes(input)
	
	for flap in flaps.get_children():
		flaps.remove_child(flap)
		flap.queue_free()
	
	
	for flap in new_flabs.get_children():
		new_flabs.remove_child(flap)
		flaps.add_child(flap)
	
	set_flap_neighbors()
