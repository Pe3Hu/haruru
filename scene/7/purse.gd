extends MarginContainer


@onready var label = $Label
@onready var businesses = $Businesses

var realm = null


func set_attributes(input_: Dictionary) -> void:
	realm = input_.realm
	init_resources()
	allocate_resources_for_bidding(input_.resources)
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
	
	label.visible = false


func allocate_resources_for_bidding(resources_: Dictionary) -> void:
	for resource in resources_:
		var value = resources_[resource]
		change_resource_value(resource, value)
		print([realm.index, resource, value])


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
	var value = get_icon_resource_number(resource_).get_number()
	return value + value_ >= 0


func change_resource_value(resource_: String, value_: int) -> void:
	var icon = get_icon_resource_number(resource_)
	icon.change_number(value_)
	#realm.accountant.change_rss_icon_number_based_on_type_and_subtype_value("stockpile", resource_, value_)
	#var icon = realm.accountant.get_rss_icon_based_on_type_and_subtype("stockpile", resource_)
	#label_.text = icon.number.text

	var hbox = get_resource_hbox(resource_)
	print([resource_, value_, icon.get_number()])
	if icon.get_number() > 0:
		hbox.visible = true
	else:
		hbox.visible = false


func get_value_of_resource_available_for_withdraw(resource_: String, value_: int) -> int:
	var icon = get_icon_resource_number(resource_)
	
	if check_resource_availability(resource_, value_):
		return -value_
	
	return icon.get_number()


func get_value_of_resource(resource_: String) -> int:
	var icon = get_icon_resource_number(resource_)
	return icon.get_number()


func reset() -> void:
	for business in businesses.get_children():
		for hbox in business.get_children():
			var icon = hbox.get_node("Icon")
			var value = get_value_of_resource(icon.subtype)
			change_resource_value(icon.subtype, -value)
