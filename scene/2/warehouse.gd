extends MarginContainer

@onready var label = $Label
@onready var resources = $Resources
@onready var businesses = $Businesses


func  _ready() -> void:
	init_resources()
	#update_icons()
	#label.visible = false
	pass


func  init_resources() -> void:
	for business in Global.dict.business:
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		businesses.add_child(vbox)
		
		for key in Global.dict.business[business]:
			var hbox = HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			vbox.name = key
			var input = {}
			input.type = "resource"
			input.subtype = Global.dict.business[business][key]
			var icon = Global.scene.icon.instantiate()
			hbox.add_child(icon)
			var label_ = label.duplicate()
			hbox.add_child(label_)
			vbox.add_child(hbox)
			icon.set_attributes(input)
	
	#update_icons()
	label.visible = false



func  update_icons() -> void:
	for business in businesses.get_children():
		for resource in business.get_children():
			var input = {}
			input.type = "resource"
			input.subtype = resource.name.to_lower()
			get_resource_icon(resource.name).set_attributes(input)


func get_resource_icon(title_: String) -> MarginContainer:
	var path = Global.get_resource_path(title_)
	var business = businesses.get_node(path.business.to_upper())
	var resource = business.get_node(path.resource.to_upper())
	return resource.get_node("Icon")
