extends Polygon2D


var cloth = null
var type = null


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	type = input_.type
	position = input_.position
	cloth.grid.knob[position] = self
	set_vertexs()
	update_color()


func set_vertexs() -> void:
	var order = "even"
	var corners = 4
	var r = Global.num.size.knob.R
	var vertexs = []
	
	for corner in corners:
		var vertex = Global.dict.polygon[corners][order][corner] * r
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func update_color() -> void:
	var max_h = 360.0
	var s = 0.0
	var v = 1
	var h = 0.0 / max_h
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)
