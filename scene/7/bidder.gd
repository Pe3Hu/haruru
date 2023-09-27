extends MarginContainer


@onready var index = $VBox/Index
@onready var pp = $VBox/PreferredPrice
@onready var lp = $VBox/LimitedPrice
@onready var canned = $VBox/Canned

var room = null
var mediator = null
var fails = {}


func set_attributes(input_: Dictionary):
	room = input_.room
	mediator = input_.mediator
	index.text = str(mediator.index)
	
	fails.current = 0
	fails.limit = 7
	
	fill_icons()


func fill_icons() -> void:
	var resource = room.get_resource()
	var input = {}
	input.type = "number"
	input.subtype = mediator.appraisals[resource].expectation
	pp.set_attributes(input)
	input.type = "number"
	input.subtype = mediator.appraisals[resource].limit.buy
	lp.set_attributes(input)
	input.type = "number"
	input.subtype = mediator.purse.get_stockpile_of_resource("canned")
	canned.set_attributes(input)


func pick_vendor() -> void:
	var vendors = []
	
	for vendor in room.vendors.get_children():
		if vendor.get_stack_number() > 0:
			vendors.append(vendor)
	
	
	if !vendors.is_empty():
		var vendor = vendors.pick_random()
		vendor.get_offer(self)
	else:
		get_reject()


func get_preferred_price() -> float:
	return pp.get_number()


func get_limited_price() -> float:
	return lp.get_number()


func get_accept() -> void:
	change_preferred_price(-1)
	fails.current = 0


func get_reject() -> void:
	change_preferred_price(1)
	fails.current += 1


func change_preferred_price(step_: int) -> void:
	var resource = room.get_resource()
	Global.rng.randomize()
	var correction = Global.rng.randf_range(mediator.appraisals[resource].correction.min, mediator.appraisals[resource].correction.max)
	mediator.appraisals[resource].expectation += step_ * correction
	
	if mediator.appraisals[resource].limit.buy < mediator.appraisals[resource].expectation:
		mediator.appraisals[resource].expectation = mediator.appraisals[resource].limit.buy
	
	pp.set_number(mediator.appraisals[resource].expectation)


func pick_up_purchase(value_: int) -> void:
	var resource = room.get_resource()
	mediator.purse.change_resource_value(resource, value_)


func check_room_conditions() -> void:
	var resource = room.get_resource()
	
	if fails.current >= fails.limit:
		leave_room()
		return
	
	if abs(mediator.goals[resource]) <= abs(mediator.performances[resource]):
		leave_room()
		return


func leave_room() -> void:
	room.bidders.remove_child(self)
	mediator.rooms.bidder.erase(room)
	queue_free()
