extends MarginContainer


@onready var title = $VBox/Title
@onready var purse = $VBox/Purse
@onready var warehouse = $VBox/Warehouse

var realm = null
var marketplace = null
var index = null
var goals = null
var investments = {}
var performances = {}
var rooms = {}
var appraisals = {}
var correction = null


func set_attributes(input_: Dictionary):
	realm = input_.realm
	marketplace = realm.sketch.marketplace
	goals = input_.goals
	input_.mediator = self
	purse.set_attributes(input_)
	index = Global.num.index.mediator
	Global.num.index.mediator += 1
	title.text = "Realm " + str(realm.index) + " #"  + str(index)
	rooms.vendor = []
	rooms.bidder = []
	
	init_appraisalss()
	join_rooms()


func init_appraisalss() -> void:
	var discount = 0.6
	var surcharge = 0.8
	
	for resource in Global.arr.commodity:
		performances[resource] = 0
		appraisals[resource] = {}
		appraisals[resource].expectation = float(marketplace.bank.get_resource_price(resource))
		appraisals[resource].correction = {}
		appraisals[resource].correction.max = appraisals[resource].expectation * 0.04
		appraisals[resource].correction.min = appraisals[resource].expectation * 0.01
		appraisals[resource].limit = {}
		Global.rng.randomize()
		appraisals[resource].limit.sell = 1 - Global.rng.randf_range(0, discount)
		Global.rng.randomize()
		appraisals[resource].limit.buy = 1 + Global.rng.randf_range(0, surcharge)
		
		for key in appraisals[resource].limit:
			appraisals[resource].limit[key] *= appraisals[resource].expectation


func join_rooms() -> void:
	for room in marketplace.rooms.get_children():
		var resource = room.get_resource()
		
		if abs(goals[resource]) > abs(performances[resource]):
			if goals[resource] < 0:
				room.add_vendor(self, false)
			else:
				room.add_bidder(self, false)


func become_vendor(room_: MarginContainer, price_: float) -> void:
	if !rooms.bidder.has(room_):
		var resource = room_.get_resource()
		
		if purse.get_resource_value(resource) > 0:
			if price_ > appraisals[resource].limit.sell * 2:
				appraisals[resource].expectation = price_
				room_.add_vendor(self, true)
				
				for bidder in room_.bidders.get_children():
					bidder.fails.current = 0


func become_bidder(room_: MarginContainer, price_: float) -> void:
	if !rooms.vendor.has(room_):
		var resource = room_.get_resource()
		var budget = purse.get_resource_value("canned") * marketplace.bank.get_resource_price("canned")
		
		if budget > price_ * Global.num.marketplace.stack.limit:
			if price_ * 2 < appraisals[resource].limit.buy:
				appraisals[resource].expectation = price_
				room_.add_bidder(self, true)
				
				for vendor in room_.vendors.get_children():
					vendor.fails.current = 0


func comeback() -> void:
	for resource in investments:
		var profit = purse.get_resource_value(resource) - investments[resource]
		print(["realm", realm.index, resource, profit, investments[resource], purse.get_resource_value(resource)])
		var value = purse.get_resource_value(resource)
		purse.change_resource_value(resource, -value)
		realm.warehouse.change_resource_value(resource, value)
	
	marketplace.mediators.remove_child(self)
