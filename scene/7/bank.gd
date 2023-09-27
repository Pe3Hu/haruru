extends MarginContainer


@onready var pss = $PriceSpreadsheet

var marketplace = null


func set_attributes(input_: Dictionary):
	marketplace = input_.marketplace
	init_pss()


func init_pss() -> void:
	var input = {}
	input.type = "blank"
	input.subtype = null
	var icon = Global.scene.icon.instantiate()
	pss.add_child(icon)
	
	var titles = ["price"]
	pss.columns = titles.size() + 1
	
	for title in titles:
		input.type = "economy"
		input.subtype = title
		icon = Global.scene.icon.instantiate()
		pss.add_child(icon)
		icon.set_attributes(input)
	
	for resource in Global.arr.commodity:
		input.type = "resource"
		input.subtype = resource
		icon = Global.scene.icon.instantiate()
		pss.add_child(icon)
		icon.set_attributes(input)
		
		for title in titles:
			input.type = "number"
			input.subtype = float(Global.dict.merchandise.price[resource])
			icon = Global.scene.icon.instantiate()
			pss.add_child(icon)
			icon.set_attributes(input)
			icon.name = title + " of " + resource


func get_resource_icon(resource_: String) -> MarginContainer:
	var name_ = "price of " + resource_
	var icon = pss.get_node(name_)
	return icon


func set_resource_price(resource_: String, value_: int) -> void:
	var icon = get_resource_icon(resource_)
	icon.set_number(value_)


func get_resource_price(resource_: String) -> float:
	var icon = get_resource_icon(resource_)
	return icon.get_number()
