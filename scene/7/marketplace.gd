extends MarginContainer


@onready var mediators = $HBox/Mediators
@onready var rooms = $HBox/Rooms
@onready var bank = $HBox/Bank

var sketch = null


func prepare_before_trading() -> void:
	var input = {}
	input.marketplace = self
	bank.set_attributes(input)
	
	init_rooms()


func init_rooms() -> void:
	for commodity in Global.arr.commodity:
		var input = {}
		input.marketplace = self
		input.commodity = commodity
		var room = Global.scene.room.instantiate()
		rooms.add_child(room)
		room.set_attributes(input)


func start_trading() -> void:
	for room in rooms.get_children():
		room.start_session()
	
	bank.update_prices()
