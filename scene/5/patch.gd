extends MarginContainer


var cloth = null
var lair = null
var element = null
var index = null
var square = 0
var knobs = []
var flaps = []
var neighbors = {}
var state = {}


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	flaps.append_array(input_.flaps)
	set_knobs()
	index = Global.num.index.patch
	Global.num.index.patch += 1
	
	for key in Global.arr.state:
		state[key] = null


func set_knobs() -> void:
	for flap in flaps:
		flap.patch = self
		
		for knob in flap.knobs:
			if !knobs.has(knob):
				knobs.append(knob)


func connect_flaps() -> void:
	var seams = {}
	
	for flap in flaps:
		for seam in flap.neighbors:
			if !seams.has(seam):
				seams[seam] = 1
			else:
				seams[seam] += 1
	
	for seam in seams:
		if seams[seam] == 1:
			for flap in flaps:
				if flap.neighbors.has(seam):
					var neighbor = flap.neighbors[seam].patch
					neighbors[seam] = neighbor
					neighbor.neighbors[seam] = self


func set_element_flaps() -> void:
	for flap in flaps:
		flap.element = element
		flap.paint_based_on_element()
		flap.paint_based_on_patch_index()


func init_polygon() -> void:
	for flap in flaps:
		flap.set_vertexs()


func init_lair() -> void:
	var lair_position = Vector2()
	
	var corner = true
	
	for flap in flaps:
		corner = flap.type == "corner" && corner
	
	if corner && flaps.size() == 4:
		for knob in knobs:
			if knob.type == "corner":
				lair = knob
				break
	else:
		var n = knobs.size()
		var xs = []
		var ys = []
		var corner_positions = []
		var same_axis = false
		
		for knob in knobs:
			lair_position += knob.position
			
			match knob.type:
				"corner":
					corner_positions.append(knob.position)
				"edge":
					if xs.has(knob.position.x):
						same_axis = true
					else:
						xs.append(knob.position.x)
					
					if ys.has(knob.position.y):
						same_axis = true
					else:
						ys.append(knob.position.y)
		
		if same_axis && corner_positions.size() == 1:
			lair_position -= corner_positions.front()
			n -= 1
		
		lair_position /= n
		
		var input = {}
		input.type = "lair"
		input.cloth = cloth
		input.position = lair_position
		
		var knob = Global.scene.knob.instantiate()
		cloth.knobs.add_child(knob)
		knob.set_attributes(input)
		#obj.cloth.knob[lair_position] = knob
		lair = knob
		knob.visible = true


func hide_flaps() -> void:
	for flap in flaps:
		flap.visible = false


func paint_flaps(color_: Color) -> void:
	for flap in flaps:
		flap.visible = true
		flap.set_color(color_)
