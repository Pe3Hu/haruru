extends MarginContainer


@onready var index = $VBox/Index
@onready var pp = $VBox/PreferredPrice
@onready var lp = $VBox/LimitedPrice
@onready var stack = $VBox/Stack

var room = null
var mediator = null
var fails = {}
var greed = null


func set_attributes(input_: Dictionary):
	room = input_.room
	mediator = input_.mediator
	greed = input_.greed 
	index.text = str(mediator.index)
	mediator.rooms.vendor.append(room)
	
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
	var value = min(mediator.purse.get_stockpile_of_resource(resource), Global.num.marketplace.stack.limit)
	
	if value > 0:
		stack.set_number(value)
		mediator.purse.change_resource_value(resource, -value)
	else:
		leave_room()


func get_preferred_price() -> float:
	return pp.get_number()


func get_limited_price() -> float:
	return lp.get_number()


func get_stack_number() -> int:
	return stack.get_number()


func get_offer(bidder_: MarginContainer) -> void:
	var payment = ask_discount(bidder_)
	
	if payment!= null:
		accept_offer(bidder_, payment)
	else:
		reject_offer(bidder_)
	
	bidder_.check_room_conditions()
	check_room_conditions()


func ask_discount(bidder_: MarginContainer) -> Variant:
	if bidder_.get_preferred_price() > get_limited_price():
		var lot = {}
		lot.base = float(bidder_.get_preferred_price() * get_stack_number())
		var canned = {}
		canned.price = room.marketplace.bank.get_resource_price("canned")
		canned.base = lot.base / canned.price
		canned.discount = floor(canned.base)
		canned.surcharge = ceil(canned.base)
		
		if canned.discount == canned.surcharge:
			canned.surcharge += 1
		
		lot.discount = canned.price * canned.discount / get_stack_number()
		lot.surcharge = canned.price * canned.surcharge / get_stack_number()
		
		if lot.discount > get_limited_price() and lot.surcharge < bidder_.get_limited_price():
			var key = bidding()
			return canned[key] 
	
	return null


func bidding() -> String:
	var coin = {}
	Global.rng.randomize()
	coin.discount = Global.rng.randf_range(0, 1)
	Global.rng.randomize()
	coin.surcharge = Global.rng.randf_range(0, 1)
	
	if coin.discount > coin.surcharge:
		return "discount"
	else:
		return "surcharge"


func accept_offer(bidder_: MarginContainer, payment_: int) -> void:
	get_accept()
	bidder_.get_accept()
	
	var purchase = get_stack_number()
	pick_up_payment(bidder_, payment_)
	bidder_.pick_up_purchase(self, purchase)
	var resource = room.get_resource()
	mediator.marketplace.bank.seal_deal(resource, purchase, payment_)


func pick_up_payment(bidder_: MarginContainer, value_: int) -> void:
	var resource = "canned"
	#bidder_.mediator.performances[resource] -= value_
	#mediator.performances[resource] += value_
	mediator.purse.change_resource_value(resource, value_)
	bidder_.mediator.purse.change_resource_value(resource, -value_)


func reject_offer(bidder_: MarginContainer) -> void:
	get_reject()
	bidder_.get_reject()


func get_accept() -> void:
	change_preferred_price(1)
	fails.current = 0


func get_reject() -> void:
	change_preferred_price(-1)
	fails.current += 1
	
	if get_preferred_price() == get_limited_price():
		fails.current += 1


func change_preferred_price(step_: int) -> void:
	var resource = room.get_resource()
	Global.rng.randomize()
	var correction = Global.rng.randf_range(mediator.appraisals[resource].correction.min, mediator.appraisals[resource].correction.max)
	mediator.appraisals[resource].expectation += step_ * correction
	
	if mediator.appraisals[resource].limit.sell > mediator.appraisals[resource].expectation:
		mediator.appraisals[resource].expectation = mediator.appraisals[resource].limit.sell
	
	pp.set_number(mediator.appraisals[resource].expectation)


func keep_up_demand() -> bool:
	fails.current -= 1
	Global.rng.randomize()
	var insist = Global.rng.randf_range(0, 1)# + float(fails.current) / fails.limit
	return insist > 0.1


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
