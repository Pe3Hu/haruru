extends MarginContainer


@onready var icon =$HBox/Icon
@onready var sl = $HBox/ShelfLife

var accountant = null


func set_attributes(input_: Dictionary):
	accountant = input_.accountant
	fill_sl()
	
	var input = {}
	input.type = "economy"
	input.subtype = "barn"
	icon.set_attributes(input)


func fill_sl() -> void:
	for _i in Global.dict.time.week:
		var input = {}
		input.type = "number"
		input.subtype = 0
		var icon = Global.scene.icon.instantiate()
		sl.add_child(icon)
		icon.set_attributes(input)
		icon.name = str(_i)
	
	var last = sl.get_child(0)
	last.number.set("theme_override_colors/font_color", Color.DARK_RED)


func restock(value_: int) -> void:
	var first = sl.get_child(sl.get_child_count()-1)
	first.number.text = str(value_)


func absorption(value_: int) -> void:
	for _i in sl.get_child_count():
		var icon = sl.get_child(_i)
		var value = min(int(icon.number.text), value_)
		
		if value > 0:
			value_ -= value
			icon.number.text = str(int(icon.number.text - value))
		
		if value_ == 0:
			return
	
	accountant.realm.warehouse.change_resource_value("canned", -value_)


func reduce_shelf_life() -> void:
	for _i in sl.get_child_count():
		var recipient = sl.get_child(_i)
		recipient.number.text = str(0)
		
		if _i != sl.get_child_count() - 1:
			var donor = sl.get_child(_i + 1)
			recipient.number.text = donor.number.text

