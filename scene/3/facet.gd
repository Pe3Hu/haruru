extends MarginContainer


@onready var bg = $BG
@onready var icon = $Icon

var member = null
var resource = null
var index = null
var fail = false
var outcome = {}
var buff = {}
var debuff = {}


func set_attributes(input_: Dictionary) -> void:
	for key in input_:
		if key != "outcome":
			set(key, input_[key])
	
	outcome.original = input_.outcome
	outcome.current = input_.outcome
	debuff.current = 0
	debuff.limit = Global.dict.outcome[input_.outcome].debuff
	buff.current = 0
	buff.limit = Global.dict.outcome[input_.outcome].buff
	set_icon_subtype(input_.outcome)
	
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
			match member.specialization:
				"farmer":
					h = 60.0 / 360.0
				"fisher":
					h = 180.0 / 360.0
				"diver":
					h = 210.0 / 360.0
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


func add_debuff(value_: int) -> void:
	var value = min(value_, debuff.limit - debuff.current)
	
	if value > 0:
		debuff.current += value
		buff.current -= value
		outcome.current = Global.dict.debuff[outcome.current]
		set_icon_subtype(outcome.current)


func add_buff(value_: int) -> void:
	var value = min(value_, buff.limit - buff.current)
	
	if value > 0:
		buff.current += value
		debuff.current -= value
		outcome.current = Global.dict.buff[outcome.current]
		set_icon_subtype(outcome.current)


func set_icon_subtype(outcome_: String) -> void:
	var input = {}
	input.type = "outcome"
	input.subtype = outcome_
	icon.set_attributes(input)
