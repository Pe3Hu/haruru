extends Line2D


var cloth = null
var knobs = []
var flaps = []
var boundary = true


func set_attributes(input_: Dictionary) -> void:
	cloth  = input_.cloth
	knobs.append_array(input_.knobs)
	cloth.couplers[knobs.front()][knobs.back()] = self
	cloth.couplers[knobs.back()][knobs.front()] = self
	
	for knob in knobs:
		add_point(knob.position)


func add_flap(flap_: Polygon2D) -> void:
	if !flaps.has(flap_):
		flaps.append(flap_)
	
	if !flap_.seams.has(self):
		flap_.seams.append(self)


func cut():
	var delta = 1.0 / Global.num.size.delta * 2
	delta *= Global.arr.delta.pick_random()
	
	var points_ = []
	var first = knobs.front()
	var second = knobs.back()
	points_.append(first.position)
	points_.append(second.position)
	var dot = Global.split_two_point(points_, delta)
	
	var input = {}
	input.type = "edge"
	input.cloth = cloth
	input.position = Vector2(ceil(dot.x), ceil(dot.y))
	var knob = Global.scene.knob.instantiate()
	cloth.knobs.add_child(knob)
	knob.set_attributes(input)
	
	cloth.couplers[first].erase(second)
	cloth.couplers[second].erase(first)
	
	cloth.couplers[knob] = {}
	input = {}
	input.cloth = cloth
	input.knobs = [first, knob]
	var seam = Global.scene.seam.instantiate()
	cloth.seams.add_child(seam)
	seam.set_attributes(input)
	
	input.knobs = [second, knob]
	seam = Global.scene.seam.instantiate()
	cloth.seams.add_child(seam)
	seam.set_attributes(input)


func set_boundary() -> void:
	if flaps.size() > 1:
		boundary = flaps.front().patch != flaps.back().patch
	
	if !boundary:
		visible = false
