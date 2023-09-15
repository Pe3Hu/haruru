extends MarginContainer


@onready var bg = $BG
@onready var icons = $HBox/Icons
@onready var quantities = $HBox/Quantities
@onready var outcome = $HBox/Outcome

var member = null
var resource = null
var index = null
var fail = false


func set_attributes(input_: Dictionary) -> void:
	for key in input_:
		if key != "outcome":
			set(key, input_[key])
	
	var input = {}
	input.type = "outcome"
	input.subtype = input_.outcome
	outcome.set_attributes(input)
	
	paint_bg()
	custom_minimum_size = Vector2(Global.vec.size.facet)


func paint_bg() -> void:
	var style = StyleBoxFlat.new()
	bg.set("theme_override_styles/panel", style)
	var h = null
	var s = 1.0
	var v = 1.0
	
	match member.type:
		"servant":
			match member.subtype:
				"farmer":
					h = 60.0 / 360.0
				"fisher":
					h = 180.0 / 360.0
				"hunter":
					h = 120.0 / 360.0
				"cook":
					h = 240.0 / 360.0
				"logger":
					h = 30.0 / 360.0
				"carpenter":
					h = 150.0 / 360.0
				"miner":
					h = 320.0 / 360.0
				"blacksmith":
					h = 0.0 / 360.0
				"jeweler":
					h = 280.0 / 360.0
	
	
	var color = Color.from_hsv(h, s, v)
	
	
	if color == null:
		color = Color.DIM_GRAY
	
	style.bg_color = color


func get_attributes() -> Dictionary:
	var input = {}
	input.member = member
	input.index = index
	input.outcome = outcome.subtype
	
	return input
