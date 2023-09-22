extends MarginContainer


@onready var manager = $Manager
@onready var warehouse = $Warehouse

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
	manager.set_attributes(input)
	
	accountant = Global.scene.accountant.instantiate()
	sketch.economy.accountants.add_child(accountant)
	accountant.set_attributes(input)
	warehouse.set_attributes(input)


func harvest() -> void:
	for servant in accountant.servants:
		var population = accountant.servants[servant]
		
		if population > 0:
			for resource in Global.dict.raw:
				var data = Global.dict.facet.type["servant"][servant]
				
				if data.workout.has(resource):
					var avg = floor(float(data.workout[resource]) / data.dice * population)
					warehouse.change_resource_value(resource, avg)


func meal() -> void:
	accountant.barn.reduce_shelf_life()
	
	var food = {}
	food.output = 0
	
	for servant in accountant.servants:
		var population = accountant.servants[servant]
		food.output += population
	
	food.input = warehouse.get_value_of_resource("food")
	food.profit = food.input - food.output
	
	if food.profit > 0:
		accountant.barn.restock(food.profit)
	else:
		accountant.barn.absorption(-food.profit)
	
	warehouse.change_resource_value("food", -food.input)


func craft() -> void:
	for servant in accountant.servants:
		var population = accountant.servants[servant]
		
		if population > 0:
			for resource in Global.dict.product:
				var data = Global.dict.facet.type["servant"][servant]
				
				if data.workout.has(resource):
					var avg = floor(float(data.workout[resource]) / data.dice * population)
					warehouse.change_resource_value(resource, avg)
