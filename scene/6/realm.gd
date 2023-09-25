extends MarginContainer


@onready var manager = $VBox/Manager
@onready var warehouse = $VBox/Warehouse
@onready var settlements = $VBox/Settlements

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
		var income = accountant.get_rss_icon_based_on_type_and_subtype("income", raw)
		warehouse.change_resource_value(raw, income.get_number())


func meal() -> void:
	accountant.barn.reduce_shelf_life()
	
	var food = {}
	food.output = 0
	
	for servant in accountant.specializations:
		var population = accountant.specializations[servant]
		food.output += population
	
	food.input = warehouse.get_value_of_resource("food")
	food.profit = food.input - food.output
	
	if food.profit > 0:
		accountant.barn.restock(food.profit)
	else:
		accountant.barn.absorption(-food.profit)
	
	warehouse.change_resource_value("food", -food.input)


func craft() -> void:
	for product in Global.dict.conversion.product:
		var income = accountant.get_rss_icon_based_on_type_and_subtype("income", product)
		warehouse.change_resource_value(product, income.get_number())


func migration() -> void:
	var population = accountant.get_rss_icon_based_on_type_and_subtype("profit", "population").get_number()
	var settlers = {}
	
	for key in Global.num.settlement.migration:
		settlers[key] = population * Global.num.settlement.migration[key]
	
	Global.rng.randomize()
	settlers.current = Global.rng.randi_range(settlers.min, settlers.max)
	var settlement = settlements.get_child(0)
	settlement.bring_settlers(settlers.current)
	accountant.update_population()


func education() -> void:
	for settlement in settlements.get_children():
		for structure in settlement.structures.get_children():
			if structure.type == "school":
				structure.enrollment()
				structure.graduation_check()
