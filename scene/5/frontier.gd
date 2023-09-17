extends Polygon2D


var cloth = null
var seam = null
var lair = null
var index = null
var knobs = []


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	seam = input_.seam
	lair = input_.lair
	index = Global.num.index.frontier
	Global.num.index.frontier += 1
	set_vertexs()


func set_vertexs() -> void:
	knobs.append(lair)
	knobs.append_array(seam.knobs)
	var vertexs = []
	
	for knob in knobs:
		var vertex = knob.position
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func paint_by_index() -> void:
	var s = 0.75
	var v = 1
	var h = float(index) / Global.num.index.frontier
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)
