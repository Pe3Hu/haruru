extends Polygon2D


var cloth = null
var patch = null
var settlement = null
var type = null
var state = {}


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	type = input_.type
	position = input_.position
	
	if type != "lair" and type != "hub":
		cloth.grid.knob[position] = self
	else:
		match type:
			"lair":
				cloth.grid.lair[position] = self
			"hub":
				cloth.grid.hub[position] = self
	
	set_vertexs()
	update_color()


func set_vertexs() -> void:
	var order = "even"
	var corners = 4
	var r = Global.num.size.knob.R
	
	match type:
		"hub":
			r = Global.num.size.knob.hub
	
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
	
	if type == "hub":
		v = 0.25
	
	if settlement != null:
		v = 0
	
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func set_as_state_capital(state_: MarginContainer) -> void:
	state[state_.type] = state_
	state_.capital = self
	update_color()


func init_settlement() -> void:
	var input = {}
	input.knob = self
	input.cloth = cloth
	settlement = Global.scene.settlement.instantiate()
	cloth.settlements.add_child(settlement)
	settlement.set_attributes(input)
	update_color()
