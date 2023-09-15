extends MarginContainer


@onready var icon = $HBox/Icon
@onready var population = $HBox/Population
@onready var facets = $HBox/Facets

var tribe = null
var dices = []
var type = null
var subtype = null


func set_attributes(input_: Dictionary) -> void:
	tribe = input_.tribe
	type = input_.type
	subtype = input_.subtype
	change_population(input_.population)
	
	icon.set_attributes(input_)
	init_facets()


func init_facets() -> void:
	var outcomes = Global.dict.facet.type[type][subtype]
	var index = 0
	
	for outcome in outcomes:
		for _i in outcomes[outcome].facets:
			var input = outcomes[outcome].duplicate()
			input.member = self
			input.outcome = outcome
			input.index = index
			index += 1
			input.erase("facets")
			var facet = Global.scene.facet.instantiate()
			facets.add_child(facet)
			facet.set_attributes(input)


func get_population() -> int:
	return int(population.text)


func change_population(value_: int) -> void:
	var value = get_population() + value_
	population.text = str(value)


func get_attributes() -> Dictionary:
	var input = {}
	input.tribe = tribe
	input.type = type
	input.subtype = subtype
	input.population = population.text
	
	return input


func extract_raw(raw_: String, value_: int) -> void:
	tribe.warehouse.change_resource_value(raw_, value_)


func produce_product(product_: String, value_: int) -> void:
	var raw = Global.dict.product[product_]
	var available = tribe.warehouse.get_value_of_resource_available_for_withdraw(raw, -value_)
	tribe.warehouse.change_resource_value(raw, -available)
	tribe.warehouse.change_resource_value(product_, available)
