extends MarginContainer


@onready var terrains = $Terrains

var accountant = null
var proprietor = null
var workplaces = {}


func set_attributes(input_: Dictionary):
	accountant = input_.accountant
	proprietor = accountant.proprietor
	
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
	if accountant.type == "realm":
		for patch in proprietor.patchs:
			for flap in patch.flaps:
				if !workplaces.has(flap.terrain):
					workplaces[flap.terrain] = {}
				
				if !workplaces[flap.terrain].has(flap.abundance):
					workplaces[flap.terrain][flap.abundance] = {}
					workplaces[flap.terrain][flap.abundance].current = 0
					workplaces[flap.terrain][flap.abundance].max = 0
				
				if get_fieldwork(flap.terrain, flap.abundance) == null:
					var hbox = get_hbox(flap.terrain)
					var input = {}
					input.foreman = self
					input.hbox = hbox
					input.terrain = flap.terrain
					input.abundance = flap.abundance
					var fieldwork = Global.scene.fieldwork.instantiate()
					hbox.add_child(fieldwork)
					fieldwork.set_attributes(input)
				
				var fieldwork = get_fieldwork(flap.terrain, flap.abundance)
				var icon = fieldwork.get_icon("max")
				icon.change_number(flap.workplaces)
				workplaces[flap.terrain][flap.abundance].max += flap.workplaces
		
		init_comfortable()


func get_hbox(terrain_: String) -> Variant:
	for hbox in terrains.get_children():
		if hbox.name == terrain_.capitalize():
			return hbox
	
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
	
	if !workplaces.has(terrain):
		workplaces[terrain] = {}
	
	var abundance = 1
	
	if !workplaces[terrain].has(abundance):
		workplaces[terrain][abundance] = {}
		workplaces[terrain][abundance].current = 0
		workplaces[terrain][abundance].max = 0
	
		var hbox = get_hbox(terrain)
		var input = {}
		input.foreman = self
		input.hbox = hbox
		input.terrain = terrain
		input.abundance = abundance
		var fieldwork = Global.scene.fieldwork.instantiate()
		hbox.add_child(fieldwork)
		fieldwork.set_attributes(input)
	
	for settlement in proprietor.settlements.get_children():
		add_settlement_fieldworks(settlement)


func add_settlement_fieldworks(settlement_: MarginContainer) -> void:
	var terrain = "comfortable"
	var abundance = 1
	settlement_.fieldwork = get_fieldwork(terrain, abundance)
	var icon = settlement_.fieldwork.get_icon("max")
	icon.change_number(Global.num.settlement.workplace[settlement_.grade])
	settlement_.fieldwork.update_visible()
	workplaces[terrain][abundance].max += icon.get_number()


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
		
		for _i in datas.size():
			var data = datas[_i]
			hbox.add_child(data.fieldwork)
			data.fieldwork.upward = null
			data.fieldwork.downgrade = null
			
			if _i > 0:
				data.fieldwork.upward = datas[_i - 1].fieldwork
				
			if _i < datas.size() - 1:
				data.fieldwork.downgrade = datas[_i + 1].fieldwork


func fill_best_workplaces(specialization_: String, population_: int) -> void:
	var workplace = Global.dict.servant.workplace[specialization_]
	var hbox = get_hbox(workplace)
	
	for fieldwork in hbox.get_children():
		if fieldwork.get("abundance") != null:
			if population_ > 0:
				var freely = min(fieldwork.get_freely(), population_)
				var resupply = fieldwork.set_specialization_resupply(specialization_, freely)
				population_ -= resupply
				#var abundance = resupply * fieldwork.get_icon("abundance").get_number()
				accountant.change_specialization_population(specialization_, fieldwork, resupply)


func update_visible() -> void:
	for hbox in terrains.get_children():
		var freely = 0

		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				freely += fieldwork.get_freely()

		hbox.visible = freely > 0


func find_worst_nonempty_fieldwork(terrain_: String) -> Variant:
	var hbox = get_hbox(terrain_)
	
	for _i in range(hbox.get_child_count()-1,-1, -1):
		var fieldwork = hbox.get_child(_i)
		
		if fieldwork.get("abundance") != null:
			if fieldwork.get_icon("current").get_number() > 0:
				return fieldwork
	
	return null


func find_worst_incomplete_fieldwork(terrain_: String) -> Variant:
	var hbox = get_hbox(terrain_)
	
	for _i in range(hbox.get_child_count()-1,-1, -1):
		var fieldwork = hbox.get_child(_i)
		
		if fieldwork.get("abundance") != null:
			if fieldwork.get_freely() > 0:
				return fieldwork
	
	return null


func find_best_nonempty_fieldwork(terrain_: String) -> Variant:
	var hbox = get_hbox(terrain_)
	
	for fieldwork in hbox.get_children():
		if fieldwork.get("abundance") != null:
			if fieldwork.get_icon("current").get_number() > 0:
				return fieldwork
	
	return null


func find_best_incomplete_fieldwork(terrain_: String) -> Variant:
	var hbox = get_hbox(terrain_)
	
	for fieldwork in hbox.get_children():
		if fieldwork.get("abundance") != null:
			if fieldwork.get_freely() > 0:
				return fieldwork
	
	return null


func empty_worst_workplaces(specialization_: String, population_: int) -> void:
	var workplace = Global.dict.servant.workplace[specialization_]
	var unemployed = 0
	
	while population_ > 0:
		var fieldwork = find_worst_nonempty_fieldwork(workplace)
		
		if fieldwork != null:
			var current = -min(fieldwork.get_icon("current").get_number(), population_)
			var resupply = fieldwork.set_specialization_resupply(specialization_, current)
			population_ += resupply
			unemployed -= resupply
			accountant.change_specialization_population(specialization_, fieldwork, resupply)
		else:
			population_ = 0
			print("error: not enough population for empty_worst_workplaces")
	
	#if  proprietor.index == 0:
	#	print(["empty_worst_workplaces", specialization_, unemployed])
	
	
	var settlement = proprietor.get_settlement_for_unemployeds()
	settlement.fieldwork.set_specialization_resupply("unemployed", unemployed)


func give_prizes() -> void:
	for hbox in terrains.get_children():
		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				fieldwork.ladder.give_prizes()


func rotate_members() -> void:
	for hbox in terrains.get_children():
		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				fieldwork.ladder.rotate_members()
		
		for fieldwork in hbox.get_children():
			if fieldwork.get("abundance") != null:
				fieldwork.ladder.employ_newbies()
		
				fieldwork.ladder.reset_contributions()
