extends MarginContainer


@onready var manager = $VBox/Manager
@onready var warehouse = $VBox/Warehouse
@onready var settlements = $VBox/Settlements
@onready var tribes = $VBox/Tribes

var sketch = null
var capital = null
var accountant = null
var patchs = []
var boundaries = []
var states = {}
var index = null


func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	capital = input_.state.capital
	index = Global.num.index.realm
	Global.num.index.realm += 1
	
	set_states(input_.state)
	push_boundaries(input_.state)
	init_settlement(capital)
	init_leadership()
	call_tribes()
	manager.hold_fieldwork_tenders()


func set_states(state_: MarginContainer) -> void:
	states[state_.type] = [state_]
	var type = state_.type
	
	while type != null:
		for state in states[type]:
			for vassal in state.vassals:
				if !states.has(vassal.type):
					states[vassal.type] = []
				
				states[vassal.type].append(vassal)
				vassal.realm = self
		
		if states[type].front().vassals.is_empty():
			type = null
		else:
			type = states[type].front().vassals.front().type


func push_boundaries(state_: MarginContainer) -> void:
	var seams = {}
	
	for patch in state_.patchs:
		patch.realm = self
		patchs.append(patch)
		
		for flap in patch.flaps:
			for seam in flap.seams:
				if !seams.has(seam):
					seams[seam] = 0
				
				seams[seam] += 1
	
	for seam in seams:
		if seams[seam] == 1:
			boundaries.append(seam)
			seam.boundary.realms.append(self)


func init_leadership() -> void:
	var input = {}
	input.realm = self
	accountant = Global.scene.accountant.instantiate()
	sketch.economy.accountants.add_child(accountant)
	accountant.set_attributes(input)
	manager.set_attributes(input)
	warehouse.set_attributes(input)


func call_tribes() -> void:
	var workplaces = {}
	var contribution = {}
	contribution.total = 0
	contribution.tribe = 120
	
	for terrain in Global.arr.terrain:
		workplaces[terrain] = {}
		workplaces[terrain].total = accountant.get_tss_number_based_on_type_and_subtype(terrain, "workplace")
		
		if workplaces[terrain].total > 0:
			workplaces[terrain].current = 0
			contribution.total += Global.dict.servant.contribution[terrain] * workplaces[terrain].total
		else:
			workplaces.erase(terrain)
	
	while contribution.total > contribution.tribe:
		init_tribe(workplaces, contribution)


func init_tribe(workplaces_: Dictionary, contribution_: Dictionary) -> void:
	contribution_.current = 0
	var terrains = {}
	var servants = {}
	
	for terrain in workplaces_:
		if workplaces_[terrain].current < workplaces_[terrain].total:
			terrains[terrain] = workplaces_[terrain].total - workplaces_[terrain].current
	
	while contribution_.current < contribution_.tribe:
		var terrain = Global.get_random_key(terrains)
		var specializations = Global.get_specializations_based_on_workplace(terrain)
		var specialization = specializations.pick_random()
		
		if !servants.has(specialization):
			servants[specialization] = 0
		
		servants[specialization] += 1
		contribution_.current += Global.dict.servant.contribution[specialization]
		contribution_.total -= Global.dict.servant.contribution[terrain]
		workplaces_[terrain].current += 1
		terrains[terrain] -= 1
		
		if terrains[terrain] == 0:
			terrains.erase(terrain)
	
	var input = {}
	input.realm = self
	var tribe = Global.scene.tribe.instantiate()
	tribes.add_child(tribe)
	tribe.set_attributes(input)
	
	for resource in Global.arr.resource:
		manager.coupons[resource][tribe] = 0
		tribe.manager.coupons[resource] = 0
	
	for specialization in servants:
		tribe.add_members("servant", specialization, servants[specialization])


func init_settlement(knob_: Polygon2D) -> void:
	var input = {}
	input.grade = 1
	input.knob = knob_
	knob_.settlement = Global.scene.settlement.instantiate()
	settlements.add_child(knob_.settlement)
	knob_.settlement.set_attributes(input)
	knob_.update_color()


func harvest() -> void:
	for raw in Global.dict.conversion.raw:
		var income = accountant.get_rss_number_based_on_type_and_subtype("income", raw)
		warehouse.change_resource_value(raw, income)
		#print([raw, warehouse.get_resource_value(raw)])


func craft() -> void:
	for product in Global.dict.conversion.product:
		var income = accountant.get_rss_icon_based_on_type_and_subtype("income", product)
		warehouse.change_resource_value(product, income.get_number())


func migration() -> void:
	var fieldwork = accountant.foreman.find_worst_incomplete_fieldwork("comfortable")
	
	if fieldwork != null:
		var population = accountant.get_rss_icon_based_on_type_and_subtype("profit", "population").get_number()
		var settlers = {}
		
		for key in Global.num.settlement.migration:
			settlers[key] = population * Global.num.settlement.migration[key]
		
		settlers.min = min(fieldwork.get_freely(), settlers.min)
		settlers.max = min(fieldwork.get_freely(), settlers.max)
		Global.rng.randomize()
		settlers.current = Global.rng.randi_range(settlers.min, settlers.max)
		var settlement = get_settlement_for_unemployeds()
		settlement.bring_settlers(settlers.current)
		
		#if index == 0:
		#	print(["migration", settlers.current])
	else:
		print("error: no comfortable fieldworks")


func education() -> void:
	for settlement in settlements.get_children():
		for structure in settlement.structures.get_children():
			if structure.type == "school":
				structure.enrollment()
				structure.graduation_check()


func get_settlement_for_unemployeds() -> Variant:
	for settlement in settlements.get_children():
		if settlement.fieldwork.get_freely() > 0:
			return settlement
	
	return null
