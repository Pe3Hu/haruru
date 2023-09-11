extends MarginContainer


@onready var type = $HBox/Type
@onready var subtype = $HBox/Subtype
@onready var population = $HBox/Population
@onready var facets = $HBox/Facets

var tribe = null


func set_attributes(input_: Dictionary) -> void:
	tribe = input_.tribe
	
	for key in input_:
		if key != "tribe":
			var input = {}
			input.parent = self
			input.key = input_[key]
			get(key).set_attributes(input)
	
	init_facets()


func init_facets() -> void:
	var inputs = []
	var descriptions = Global.dict.facet.type[type.key][subtype.key]
	
	for description in descriptions:
		for _i in description.repeats:
			var input = Dictionary(description)
			input.erase("repeats")
			var facet = Global.scene.facet.instantiate()
			facets.add_child(facet)
			facet.set_attributes(input)
