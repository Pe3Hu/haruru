extends MarginContainer


@onready var businesses = $Businesses

var proprietor = null
var tribe = null


func set_attributes(input_: Dictionary) -> void:
	init_resources()
	
	if input_.keys().has("realm"):
		proprietor = input_.realm
		fill_resource_based_on_endowment()
	if input_.keys().has("tribe"):
		proprietor = input_.tribe
	


func init_resources() -> void:
	for business in Global.dict.business:
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		businesses.add_child(vbox)
		vbox.name = business.capitalize()
		
		for key in Global.dict.business[business]:
			var hbox = HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			hbox.name = key.capitalize()
			vbox.add_child(hbox)
			var input = {}
			input.type = "resource"
			input.subtype = Global.dict.business[business][key]
			var icon = Global.scene.icon.instantiate()
			hbox.add_child(icon)
			icon.set_attributes(input)
			
			icon.name = "Icon"#Global.dict.business[business][key].capitalize()
			input.type = "number"
			input.subtype = 0
			icon = Global.scene.icon.instantiate()
			hbox.add_child(icon)
			icon.set_attributes(input)
			icon.name = "Value"


func fill_resource_based_on_endowment() -> void:
	for resource in Global.dict.endowment:
		var value = Global.dict.endowment[resource]
		change_resource_value(resource, value)


func get_icon_resource_icon(resource_: String) -> MarginContainer:
	var path = Global.get_resource_path(resource_)
	var business = businesses.get_node(path.business.capitalize())
	var resource = business.get_node(path.key.capitalize())
	return resource.get_node("Icon")


func get_icon_resource_number(resource_: String) -> MarginContainer:
	var path = Global.get_resource_path(resource_)
	var business = businesses.get_node(path.business.capitalize())
	var resource = business.get_node(path.key.capitalize())
	return resource.get_node("Value")


func get_resource_hbox(resource_: String) -> HBoxContainer:
	var path = Global.get_resource_path(resource_)
	var business = businesses.get_node(path.business.capitalize())
	var hbox = business.get_node(path.key.capitalize())
	return hbox


func check_resource_availability(resource_: String, value_: int) -> bool:
	var value = get_resource_value(resource_)
	return value + value_ >= 0


func change_resource_value(resource_: String, value_: int) -> void:
	var icon = get_icon_resource_number(resource_)
	icon.change_number(value_)
	proprietor.accountant.set_rss_number_based_on_type_and_subtype("stockpile", resource_,  icon.get_number())

	var hbox = get_resource_hbox(resource_)
	if icon.get_number() > 0:
		hbox.visible = true
	else:
		hbox.visible = false


func get_value_of_resource_available_for_withdraw(resource_: String, value_: int) -> int:
	var icon = get_icon_resource_number(resource_)
	
	if check_resource_availability(resource_, value_):
		return -value_
	
	return icon.get_number()


func get_resource_value(resource_: String) -> int:
	var icon = get_icon_resource_number(resource_)
	return icon.get_number()


func set_resource_value(resource_: String, value_: int) -> void:
	var icon = get_icon_resource_number(resource_)
	icon.set_number(value_)
	proprietor.accountant.set_rss_number_based_on_type_and_subtype("stockpile", resource_,  icon.get_number())

	var hbox = get_resource_hbox(resource_)
	
	if icon.get_number() > 0:
		hbox.visible = true
	else:
		hbox.visible = false


func reset() -> void:
	for business in businesses.get_children():
		for hbox in business.get_children():
			var icon = hbox.get_node("Icon")
			#var value = get_resource_value(icon.subtype)
			#change_resource_value(icon.subtype, -value)
			set_resource_value(icon.subtype, 0 )
