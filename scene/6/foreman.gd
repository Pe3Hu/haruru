extends MarginContainer


@onready var terrains = $Terrains

var accountant = null
var realm = null
var workplace = {}


func set_attributes(input_: Dictionary):
	accountant = input_.accountant
	realm = accountant.realm
	
	for box in terrains.get_children():
		var input = {}
		input.type = "terrain"
		input.subtype = box.name.to_lower()
		var icon = Global.scene.icon.instantiate()
		box.add_child(icon)
		icon.set_attributes(input)
	
	init_fieldwork()
	sort_by_abundance()
	update_visible()


func init_fieldwork():
	for patch in realm.patchs:
		for flap in patch.flaps:
			if !workplace.has(flap.terrain):
				workplace[flap.terrain] = {}
			
			if !workplace[flap.terrain].has(flap.abundance):
				workplace[flap.terrain][flap.abundance] = {}
				workplace[flap.terrain][flap.abundance].current = 0
				workplace[flap.terrain][flap.abundance].max = 0
			
			if get_fieldwork(flap.terrain, flap.abundance) == null:
				var hbox = get_hbox(flap.terrain)
				var input = {}
				input.terrain = flap.terrain
				input.abundance = flap.abundance
				var fieldwork = Global.scene.fieldwork.instantiate()
				hbox.add_child(fieldwork)
				fieldwork.set_attributes(input)
			
			var fieldwork = get_fieldwork(flap.terrain, flap.abundance)
			var icon = fieldwork.get_icon("max")
			icon.change_number(flap.workplaces)
			workplace[flap.terrain][flap.abundance].max += flap.workplaces
	


func get_hbox(terrain_: String) -> Variant:
	for hbox in terrains.get_children():
		if hbox.name == terrain_.capitalize():
			return hbox
	
	var a = terrains.get_children()
	return null


func get_fieldwork(terrain_: String, abundance_: int) -> Variant:
	var hbox = get_hbox(terrain_)
	
	for fieldwork in hbox.get_children():
		if fieldwork.get("abundance") != null:
			if fieldwork.abundance == abundance_:
				return fieldwork
	
	return null


func sort_by_abundance() -> void:
	for hbox in terrains.get_children():
		var datas = []
		
		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				var data = {}
				data.abundance = fieldwork.abundance
				data.fieldwork = fieldwork
				hbox.remove_child(fieldwork)
				datas.append(data)
		
		datas.sort_custom(func(a, b): return a.abundance > b.abundance)
		
		for data in datas:
			hbox.add_child(data.fieldwork)


func update_visible() -> void:
	for hbox in terrains.get_children():
		var freely = 0
		
		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				freely += fieldwork.get_icon("max").get_number() - fieldwork.get_icon("current").get_number()
	
		hbox.visible = freely > 0
