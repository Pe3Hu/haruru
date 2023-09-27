extends MarginContainer


@onready var title = $VBox/Title
@onready var purse = $VBox/Purse
@onready var warehouse = $VBox/Warehouse

var realm = null
var marketplace = null
var index = null
var goals = null
var performances = {}
var rooms = {}
var appraisals = {}
var correction = null


func set_attributes(input_: Dictionary):
	realm = input_.realm
	marketplace = realm.sketch.marketplace
	goals = input_.goals
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
				room.add_vendor(self)
			else:
				room.add_bidder(self)
