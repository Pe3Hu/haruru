extends MarginContainer


@onready var diplomacy = $HBox/Diplomacy
@onready var structure = $HBox/Structure
@onready var encounters = $HBox/Encounters
@onready var cloth = $HBox/Cloth
@onready var day = $HBox/Day
@onready var economy = $HBox/Economy


func _ready() -> void:
	diplomacy.sketch = self
	economy.sketch = self
	economy.init_accountants()


func add_encounter(squads_: Array) -> void:
	var input = {}
	input.sketch = self
	input.squads = squads_
	var encounter = Global.scene.encounter.instantiate()
	encounters.add_child(encounter)
	#encounter.set_attributes(input)
