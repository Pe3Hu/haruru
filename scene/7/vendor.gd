extends MarginContainer


@onready var index = $VBox/Index
@onready var pp = $VBox/PreferredPrice
@onready var lp = $VBox/LimitedPrice
@onready var stack = $VBox/Stack

var room = null
var mediator = null
var fails = {}


func set_attributes(input_: Dictionary):
	room = input_.room
	mediator = input_.mediator
	index.text = str(mediator.index)
	
	fails.current = 0
	fails.limit = 10
	
	fill_icons()


func fill_icons() -> void:
	var resource = room.get_resource()
	var input = {}
	input.type = "number"
	input.subtype = mediator.appraisals[resource].expectation
	pp.set_attributes(input)
	input.type = "number"
	input.subtype = mediator.appraisals[resource].limit.sell
	lp.set_attributes(input)
	input.type = "number"
	input.subtype = 0
	stack.set_attributes(input)
	refill_stack()


func refill_stack() -> void:
	var resource = room.get_resource()
	var limit = 10
	var value = min(mediator.purse.get_stockpile_of_resource(resource), limit)
	stack.set_number(value)
	mediator.purse.change_resource_value(resource, -value)


func get_preferred_price() -> float:
	return pp.get_number()


func get_limited_price() -> float:
	return lp.get_number()


func get_stack_number() -> int:
	return stack.get_number()


func get_offer(bidder_: MarginContainer) -> void:
	if bidder_.get_preferred_price() > get_limited_price():
		accept_offer(bidder_)
	else:
		reject_offer(bidder_)
	
	bidder_.check_room_conditions()
	check_room_conditions()


func accept_offer(bidder_: MarginContainer) -> void:
	var resource = room.get_resource()
	get_accept()
	bidder_.get_accept()
	
	var value = get_stack_number()
	mediator.performances[resource] -= value
	bidder_.mediator.performances[resource] += value
	bidder_.pick_up_purchase(value)
	stack.set_number(0)
	#print([room.get_resource(), "deal between", bidder_.index.text, index.text])


func reject_offer(bidder_: MarginContainer) -> void:
	get_reject()
	bidder_.get_reject()


func get_accept() -> void:
	change_preferred_price(1)
	fails.current = 0


func get_reject() -> void:
	change_preferred_price(-1)
	fails.current += 1


func change_preferred_price(step_: int) -> void:
	var resource = room.get_resource()
	Global.rng.randomize()
	var correction = Global.rng.randf_range(mediator.appraisals[resource].correction.min, mediator.appraisals[resource].correction.max)
	mediator.appraisals[resource].expectation += step_ * correction
	
	if mediator.appraisals[resource].limit.sell > mediator.appraisals[resource].expectation:
		mediator.appraisals[resource].expectation = mediator.appraisals[resource].limit.sell
	
	pp.set_number(mediator.appraisals[resource].expectation)


func check_room_conditions() -> void:
	var resource = room.get_resource()
	
	if fails.current >= fails.limit:
		leave_room()
		return
	
	if abs(mediator.goals[resource]) < abs(mediator.performances[resource]):
		leave_room()
		return


func leave_room() -> void:
	room.vendors.remove_child(self)
	var value = get_stack_number()
	var resource = room.get_resource()
	mediator.purse.change_resource_value(resource, value)
	stack.set_number(0)
	mediator.rooms.vendor.erase(room)
	queue_free()
