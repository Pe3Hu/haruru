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
				input.hbox = hbox
				input.terrain = flap.terrain
				input.abundance = flap.abundance
				var fieldwork = Global.scene.fieldwork.instantiate()
				hbox.add_child(fieldwork)
				fieldwork.set_attributes(input)
			
			var fieldwork = get_fieldwork(flap.terrain, flap.abundance)
			var icon = fieldwork.get_icon("max")
			icon.change_number(flap.workplaces)
			workplace[flap.terrain][flap.abundance].max += flap.workplaces
	
	init_comfortable()


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


func init_comfortable() -> void:
	var terrain = "comfortable"
	if !workplace.has(terrain):
		workplace[terrain] = {}
	
	var abundance = 1
	
	if !workplace[terrain].has(abundance):
		workplace[terrain][abundance] = {}
		workplace[terrain][abundance].current = 0
		workplace[terrain][abundance].max = 0
	
		var hbox = get_hbox(terrain)
		var input = {}
		input.hbox = hbox
		input.terrain = terrain
		input.abundance = abundance
		var fieldwork = Global.scene.fieldwork.instantiate()
		hbox.add_child(fieldwork)
		fieldwork.set_attributes(input)
	
	for settlement in realm.settlements.get_children():
		add_settlement_fieldworks(settlement)


func add_settlement_fieldworks(settlement_: MarginContainer) -> void:
	var terrain = "comfortable"
	var abundance = 1
	var fieldwork = get_fieldwork(terrain, abundance)
	var icon = fieldwork.get_icon("max")
	icon.change_number(settlement_.workplace.total)
	fieldwork.update_visible()
	workplace[terrain][abundance].max += settlement_.workplace.total


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


func fill_best_workplaces(servant_: String, population_: int) -> int:
	var abundance = 0
	var workplace = Global.dict.servant.workplace[servant_]
	
	var hbox = get_hbox(workplace)

	if workplace == "comfortable":
		var b = hbox.get_children()
		var a = null
	
	for fieldwork in hbox.get_children():
		if fieldwork.get("abundance") != null:
			if population_ > 0:
				var freely = min(fieldwork.get_freely(), population_)
				fieldwork.set_servant_resupply(servant_, freely)
				population_ -= freely
				abundance += freely * fieldwork.get_icon("abundance").get_number()
			else:
				return abundance
	
	return abundance


func update_visible() -> void:
	for hbox in terrains.get_children():
		var freely = 0

		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				freely += fieldwork.get_freely()

		hbox.visible = freely > 0
