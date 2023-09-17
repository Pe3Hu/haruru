extends Polygon2D


var cloth = null
var patch = null
var type = null
var element = null
var terrain = null
var index = null
var square = 0
var knobs = []
var seams = []
var neighbors = {}


func set_attributes(input_: Dictionary) -> void:
	cloth  = input_.cloth
	type  = input_.type
	knobs.append_array(input_.knobs)
	#position = input_.position
	index = Global.num.index.flap
	Global.num.index.flap += 1
	
	set_vertexs()
	update_color()
	init_seams()


func set_vertexs() -> void:
	var vertexs = []
	
	for knob in knobs:
		var vertex = knob.position
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func update_color() -> void:
	var max_h = 360.0
	var s = 0.75
	var v = 1
	var h = float(index) / Global.num.size.flap.row / Global.num.size.flap.col
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func paint_gray() -> void:
	var color_ = Color.GRAY
	set_color(color_)


func paint_element() -> void:
	set_color(Global.color.element[element])


func paint_patch_index() -> void:
	var max_h = 360.0
	var s = 0.75
	var v = 1
	var h = float(patch.index) / Global.num.index.patch
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func init_seams() -> void:
	for _i in knobs.size():
		var _j = (_i + 1) % knobs.size()
		var knobs_ = [knobs[_i],knobs[_j]]
		
		for _k in knobs_.size():
			var _l = (_k + 1) % knobs_.size()
			var first = knobs_[_k]
			var second = knobs_[_l]
			
			if !cloth.couplers.keys().has(first):
				cloth.couplers[first] = {}
			
			if !cloth.couplers.keys().has(second):
				cloth.couplers[second] = {}
			
			if !cloth.couplers[first].keys().has(second):
				var input = {}
				input.cloth = cloth
				input.knobs = knobs_
				var seam = Global.scene.seam.instantiate()
				cloth.seams.add_child(seam)
				seam.set_attributes(input)
				cloth.couplers[second][first] = seam
			
			cloth.couplers[second][first].add_flap(self)


func calc_square() -> void:
	var a = knobs[0].position
	var b = knobs[1].position
	var c = knobs[2].position
	square += abs((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) / 2
