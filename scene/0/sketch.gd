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


func add_encounter(squads_: Array) -> void:
	var input = {}
	input.sketch = self
	input.squads = squads_
	var encounter = Global.scene.encounter.instantiate()
	encounters.add_child(encounter)
	#encounter.set_attributes(input)


func next_day() -> void:
	var value = int(day.text) + 1
	day.text = str(value)
	diplomacy.realms_are_harvesting()
	
