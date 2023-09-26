extends MarginContainer


@onready var label = $Label
@onready var businesses = $Businesses

var realm = null


func set_attributes(input_: Dictionary) -> void:
	realm = input_.realm
	init_resources()
	fill_resource_based_on_endowment()
	label.visible = false


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
			var input = {}
			input.type = "resource"
			input.subtype = Global.dict.business[business][key]
			var icon = Global.scene.icon.instantiate()
			hbox.add_child(icon)
			icon.name = "Icon"#Global.dict.business[business][key].capitalize()
			var label_ = label.duplicate()
			label_.name = "Value"
			hbox.add_child(label_)
			vbox.add_child(hbox)
			icon.set_attributes(input)
	
	label.visible = false


func fill_resource_based_on_endowment() -> void:
	for resource in Global.dict.endowment:
		var value = Global.dict.endowment[resource]
		change_resource_value(resource, value)


func get_resource_icon(resource_: String) -> MarginContainer:
	var path = Global.get_resource_path(resource_)
	var business = businesses.get_node(path.business.capitalize())
	var resource = business.get_node(path.key.capitalize())
	return resource.get_node("Icon")


func get_resource_value_label(resource_: String) -> Label:
	var path = Global.get_resource_path(resource_)
	var business = businesses.get_node(path.business.capitalize())
	var resource = business.get_node(path.key.capitalize())
	return resource.get_node("Value")


func check_resource_availability(resource_: String, value_: int) -> bool:
	var label_ = get_resource_value_label(resource_)
	return int(label_.text) + value_ >= 0


func change_resource_value(resource_: String, value_: int) -> void:
	var label_ = get_resource_value_label(resource_)
	realm.accountant.change_rss_icon_number_based_on_type_and_subtype_value("stockpile", resource_, value_)
	var icon = realm.accountant.get_rss_icon_based_on_type_and_subtype("stockpile", resource_)
	label_.text = icon.number.text


func get_value_of_resource_available_for_withdraw(resource_: String, value_: int) -> int:
	var label_ = get_resource_value_label(resource_)
	
	if check_resource_availability(resource_, value_):
		return -value_
	
	return int(label_.text)


func get_value_of_resource(resource_: String) -> int:
	var label_ = get_resource_value_label(resource_)
	return int(label_.text)


func reset() -> void:
	for business in businesses.get_children():
		for hbox in business.get_children():
			var icon = hbox.get_node("Icon")
			var value = get_value_of_resource(icon.subtype)
			change_resource_value(icon.subtype, -value)
