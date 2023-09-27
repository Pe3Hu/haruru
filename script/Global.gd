extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var flag = {}
var node = {}
var scene = {}


func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_color()
	init_dict()
	init_node()
	init_scene()


func init_arr() -> void:
	arr.edge = [1, 2, 3, 4, 5, 6]
	#arr.token = ["food", "influence"]
	arr.delta = [3,4,5,6,7,8,9]#[2,3,4,5,6,7,8,9,10]
	arr.limit = [2, 3]
	arr.color = ["Red","Green","Blue","Yellow"]
	arr.element = ["aqua","wind","fire","earth"]
	arr.terrain = ["pond", "plain", "forest", "mountain"]
	arr.workplace = ["pond", "plain", "forest", "mountain", "comfortable"]
	arr.resource = ["food", "wood", "ore", "gem", "canned", "plank", "ingot", "jewel"]
	arr.commodity = ["wood", "plank", "ore", "ingot", "gem", "jewel"]
	
	arr.state = ["earldom", "dukedom", "kingdom", "empire"]
	
	arr.layer = {}
	arr.layer.cloth = ["flap", "patch", "terrain", "abundance", "element", "earldom", "dukedom", "kingdom", "empire", "realm"]
	
	arr.phase = [
		"select dices",
		"roll dices",
		"active dices",
		"discard dices"
	]


func init_num() -> void:
	num.index = {}
	num.index.flap = 0
	num.index.patch = 0
	num.index.frontier = 0
	num.index.realm = 0
	num.index.mediator = 0
	num.index.state = {}
	num.index.appellation = {}
	
	num.size = {}
	
	num.size = {}
	num.size.delta = 12
	
	num.size.flap = {}
	num.size.flap.col = 8
	num.size.flap.row = 8
	num.size.flap.a = 50#64
	num.size.flap.R = num.size.flap.a
	num.size.flap.r = num.size.flap.R * sqrt(3) / 2
	num.size.flap.terrain = 2
	num.size.flap.workplace = 36
	
	num.size.knob = {}
	num.size.knob.a = 4
	num.size.knob.R = num.size.knob.a
	num.size.knob.hub = 8
	
	num.size.empire = {}
	num.size.empire.limit = 4
	
	num.realm = {}
	num.realm.handler = 0.25
	
	num.settlement = {}
	num.settlement.workplace = {}
	num.settlement.workplace[0] = 100
	num.settlement.workplace[1] = 1000
	
	num.settlement.migration = {}
	num.settlement.migration.min = 0.01
	num.settlement.migration.max = 0.04
	
	num.structure = {}
	num.structure.school = {}
	num.structure.school.workplace = {}
	num.structure.school.workplace[0] = 9
	num.structure.school.workplace[1] = 16
	
	num.conversion = {}
	num.conversion.raw = 0.01
	num.conversion.product = 1
	num.conversion.food = 0.1
	num.conversion.wood = 0.2
	num.conversion.ore = 0.4
	num.conversion.gem = 0.8
	num.conversion.canned = 0.15
	num.conversion.plank = 0.3
	num.conversion.ingot = 0.45
	num.conversion.jewel = 0.9


func init_dict() -> void:
	init_neighbor()
	init_time()
	init_polygon()
	init_business()
	init_servant()
	#init_mercenary()
	init_abundance()
	init_appellation()
	
	dict.endowment = {}
	
#	for raw in dict.conversion.raw:
#		var value = 1000
#		dict.endowment[raw] = value

	dict.endowment["canned"] = 10000
	
	dict.flap = {}
	dict.flap.component = {
		1: [["corner"], ["center"]],
		2: [["corner", "corner"], ["corner", "center"], ["center", "center"]],
		3: [["corner", "corner", "center"], ["corner", "center", "center"]],
		4: [["corner", "corner", "corner", "corner"]]
	}
	dict.flap.duplicate = {
		1: 8,
		2: 4,
		3: 2,
		4: 1
	}
	
	dict.terrain = {}
	dict.terrain.prevalence = {}
	dict.terrain.prevalence["mountain"] = 3
	dict.terrain.prevalence["pond"] = 5
	dict.terrain.prevalence["forest"] = 7
	dict.terrain.prevalence["plain"] = 9
	
	dict.merchandise = {}
	dict.merchandise.price = {}
	dict.merchandise.price["food"] = 3
	dict.merchandise.price["wood"] = 5
	dict.merchandise.price["ore"] = 7
	dict.merchandise.price["gem"] = 9
	dict.merchandise.price["canned"] = 5
	dict.merchandise.price["plank"] = 9
	dict.merchandise.price["ingot"] = 14
	dict.merchandise.price["jewel"] = 20
	
	dict.thousand = {}
	dict.thousand[""] = "k"
	dict.thousand["k"] = "m"
	dict.thousand["m"] = "b"


func init_time() -> void:
	dict.time = {}
	dict.time.day = 1
	dict.time.week = dict.time.day * 7
	dict.time.month = dict.time.week * 4
	dict.time.season = dict.time.month * 3
	dict.time.year = dict.time.season * 4
	
	dict.period = {}
	dict.period.study = {}
	dict.period.study.withmentor = 3#dict.time.week
	dict.period.study.selftaught = dict.period.study.withmentor * 3


func init_neighbor() -> void:
	dict.neighbor = {}
	dict.neighbor.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.neighbor.linear2 = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	dict.neighbor.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	dict.neighbor.zero = [
		Vector2( 0, 0),
		Vector2( 1, 0),
		Vector2( 1, 1),
		Vector2( 0, 1)
	]
	dict.neighbor.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]


func init_polygon() -> void:
	dict.order = {}
	dict.pair = {}
	dict.pair["even"] = "odd"
	dict.pair["odd"] = "even"
	var polygons = [3,4,6]
	dict.polygon = {}
	
	for polygons_ in polygons:
		dict.polygon[polygons_] = {}
		dict.polygon[polygons_].even = {}
		
		for order_ in dict.pair.keys():
			dict.polygon[polygons_][order_] = {}
		
			for _i in polygons_:
				var angle = 2 * PI * _i / polygons_ - PI/2
				
				if order_ == "odd":
					angle += PI/polygons_
				
				var vertex = Vector2(1,0).rotated(angle)
				dict.polygon[polygons_][order_][_i] = vertex


func init_business() -> void:
	dict.business = {}
	dict.business["culinary"] = {}
	dict.business["culinary"].raw = "food"
	dict.business["culinary"].product = "canned"
	dict.business["carpentry"] = {}
	dict.business["carpentry"].raw = "wood"
	dict.business["carpentry"].product = "plank"
	dict.business["metallurgy"] = {}
	dict.business["metallurgy"].raw = "ore"
	dict.business["metallurgy"].product = "ingot"
	dict.business["jewelry"] = {}
	dict.business["jewelry"].raw = "gem"
	dict.business["jewelry"].product = "jewel"
	
	dict.conversion = {}
	dict.conversion.raw = {}
	dict.conversion.raw["food"] = "canned"
	dict.conversion.raw["wood"] = "plank"
	dict.conversion.raw["ore"] = "ingot"
	dict.conversion.raw["gem"] = "jewel"
	
	dict.conversion.product = {}
	dict.conversion.product["canned"] = "food"
	dict.conversion.product["plank"] = "wood"
	dict.conversion.product["ingot"] = "ore"
	dict.conversion.product["jewel"] = "gem"


func init_facet() -> void:
	dict.facet = {}
	dict.facet.type = {}
	var path = "res://asset/json/haruru_facet.json"
	var array = load_data(path)
	
	for facet in array:
		var data = {}
		
		if !dict.facet.type.has(facet.type):
			dict.facet.type[facet.type] = {}
		
		if !dict.facet.type[facet.type].has(facet.subtype):
			dict.facet.type[facet.type][facet.subtype] = []
		
		for key in facet:
			match typeof(facet[key]):
				TYPE_FLOAT:
					data[key] = int(facet[key])
				TYPE_STRING:
					if facet[key] != "no":
						if key != "type" and key != "subtype":
							data[key] = facet[key]
		
		dict.facet.type[facet.type][facet.subtype].append(data)


func init_mercenary() -> void:
	var path = "res://asset/json/haruru_facet.json"
	var array = load_data(path)
	
	for facet in array:
		var data = {}
		
		if !dict.facet.type.has(facet.type):
			dict.facet.type[facet.type] = {}
		
		if !dict.facet.type[facet.type].has(facet.subtype):
			dict.facet.type[facet.type][facet.subtype] = []
		
		for key in facet:
			match typeof(facet[key]):
				TYPE_FLOAT:
					data[key] = int(facet[key])
				TYPE_STRING:
					if facet[key] != "no":
						if key != "type" and key != "subtype":
							data[key] = facet[key]
		
		dict.facet.type[facet.type][facet.subtype].append(data)


func init_servant() -> void:
	dict.servant = {}
	dict.servant.workplace = {}
	dict.facet = {}
	dict.facet.type = {}
	var path = "res://asset/json/haruru_servant.json"
	var array = load_data(path)
	var exceptions = ["workplace", "dice"]
	var outcomes = ["raw", "outcome", "resource", "value", "facets"]

	for facet in array:
		if !dict.servant.workplace.has(facet.subtype):
			dict.servant.workplace[facet.subtype] = facet.workplace
		
		var data = {}
		
		if !dict.facet.type.has(facet.type):
			dict.facet.type[facet.type] = {}
		
		if !dict.facet.type[facet.type].has(facet.subtype):
			dict.facet.type[facet.type][facet.subtype] = {}
			dict.facet.type[facet.type][facet.subtype].outcomes = {}
			dict.facet.type[facet.type][facet.subtype].outcomes["failure"] = {}
			dict.facet.type[facet.type][facet.subtype].outcomes["failure"]["facets"] = facet.dice
		
		for key in facet:
			match typeof(facet[key]):
				TYPE_FLOAT:
					data[key] = int(facet[key])
					
					if !dict.facet.type[facet.type][facet.subtype].has(key) and exceptions.has(key):
						dict.facet.type[facet.type][facet.subtype][key] = data[key]
				TYPE_STRING:
					if outcomes.has(key):
						data[key] = facet[key]
						
					elif !dict.facet.type[facet.type][facet.subtype].has(key) and exceptions.has(key):
						dict.facet.type[facet.type][facet.subtype][key] = facet[key]
		
		dict.facet.type[facet.type][facet.subtype].outcomes[data.outcome] = data
		dict.facet.type[facet.type][facet.subtype].outcomes[data.outcome].erase("dice")
		dict.facet.type[facet.type][facet.subtype].outcomes[data.outcome].erase("outcome")
		dict.facet.type[facet.type][facet.subtype].outcomes["failure"]["facets"] -= data.facets
	
	for type in dict.facet.type:
		for subtype in dict.facet.type[type]:
			var specialization = dict.facet.type[type][subtype]
			specialization.workouts = {}
			
			for outcome in specialization.outcomes:
				var data = specialization.outcomes[outcome]
				
				if data.has("resource"):
					if !specialization.workouts.has(data.resource):
						specialization.workouts[data.resource] = 0
					
					specialization.workouts[data.resource] += data.value * data.facets
					
					if data.resource != data.raw:
						if !specialization.workouts.has(data.raw):
							specialization.workouts[data.raw] = 0
						
						specialization.workouts[data.raw] -= data.facets


func init_abundance() -> void:
	dict.abundance = {}
	dict.abundance.limit = {}
	dict.abundance.limit.min = null
	dict.abundance.limit.max = 0
	dict.abundance.terrain = {}
	var path = "res://asset/json/haruru_abundance.json"
	var array = load_data(path)

	for abundance in array:
		dict.abundance.terrain[abundance.terrain] = {}
		
		if dict.abundance.limit.min == null:
			dict.abundance.limit.min = abundance[arr.element.front()]
		
		for element in arr.element:
			dict.abundance.terrain[abundance.terrain][element] = abundance[element]
			
			if abundance[element] < dict.abundance.limit.min:
				dict.abundance.limit.min = abundance[element]
			
			if abundance[element] > dict.abundance.limit.max:
				dict.abundance.limit.max = abundance[element]


func init_appellation() -> void:
	dict.appellation = {}
	#dict.appellation.team = {}
	#dict.appellation.name = {}
	var path = "res://asset/json/haruru_appellation.json"
	var array = load_data(path)

	for appellation in array:
		for key in appellation:
			var words = key.split(" ")
			
			
			if !dict.appellation.has(words[1]):
				dict.appellation[words[1]] = {}
			
			if !dict.appellation[words[1]].has(words[0]):
				dict.appellation[words[1]][words[0]] = []
			
			var data = appellation[key]
			
			if words[0] == "forest":
				var words_ = data.split(" ")
				data = words_[0]
			
			dict.appellation[words[1]][words[0]].append(data)
	
	var titles = ["hill", "farm", "desert"]
	dict.appellation.terrain.plain = []
	
	for title in titles:
		dict.appellation.terrain.plain.append_array(dict.appellation.terrain[title])
	
	dict.appellation.temp = {}
	
	for terrain in arr.terrain:
		dict.appellation.temp[terrain] = []
		num.index.appellation[terrain] = 0
		fill_appellation_temp(terrain)
	
	dict.appellation.temp.city = []
	num.index.appellation.city = 0
	fill_appellation_temp("city")


func fill_appellation_temp(type_: String) -> void:
	num.index.appellation[type_] += 1
	
	if arr.terrain.has(type_):
		dict.appellation.temp[type_].append_array(dict.appellation.terrain[type_])
		
	if type_ == "city":
		dict.appellation.temp[type_].append_array(dict.appellation.state[type_])
	
	
	if num.index.appellation[type_] > 1:
		for _i in dict.appellation.temp[type_].size():
			dict.appellation.temp[type_][_i] = dict.appellation.temp[type_][_i] + " " + str(num.index.appellation[type_])


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_scene() -> void:
	scene.sketch = load("res://scene/0/sketch.tscn")
	scene.icon = load("res://scene/0/icon.tscn")
	
	scene.diplomacy = load("res://scene/1/diplomacy.tscn")
	scene.tribe = load("res://scene/1/tribe.tscn")
	scene.member = load("res://scene/1/member.tscn")
	
	scene.settlement = load("res://scene/2/settlement.tscn")
	scene.school = load("res://scene/2/school.tscn")
	scene.structure = load("res://scene/2/structure.tscn")
	scene.storey = load("res://scene/2/storey.tscn")
	scene.chamber = load("res://scene/2/chamber.tscn")
	
	scene.dice = load("res://scene/3/dice.tscn")
	scene.facet = load("res://scene/3/facet.tscn")
	
	scene.encounter = load("res://scene/4/encounter.tscn")
	scene.squad = load("res://scene/4/squad.tscn")
	
	
	scene.flap = load("res://scene/5/flap.tscn")
	scene.knob = load("res://scene/5/knob.tscn")
	scene.seam = load("res://scene/5/seam.tscn")
	scene.patch = load("res://scene/5/patch.tscn")
	scene.frontier = load("res://scene/5/frontier.tscn")
	scene.state = load("res://scene/5/state.tscn")
	
	scene.realm = load("res://scene/6/realm.tscn")
	scene.accountant = load("res://scene/6/accountant.tscn")
	#scene.manager = load("res://scene/6/manager.tscn")
	scene.fieldwork = load("res://scene/6/fieldwork.tscn")
	
	
	scene.marketplace = load("res://scene/7/marketplace.tscn")
	scene.room = load("res://scene/7/room.tscn")
	scene.mediator = load("res://scene/7/mediator.tscn")
	scene.vendor = load("res://scene/7/vendor.tscn")
	scene.bidder = load("res://scene/7/bidder.tscn")
	scene.purse = load("res://scene/7/purse.tscn")
	
	
	pass


func init_vec():
	vec.size = {}
	
	vec.size.letter = Vector2(20, 20)
	vec.size.resource = Vector2(32, 32)#Vector2(32, 32) Vector2(64, 64)
	vec.size.servant = Vector2(32, 32)
	vec.size.outcome = Vector2(32, 32)
	vec.size.terrain = Vector2(32, 32)
	vec.size.economy = Vector2(32, 32)
	
	vec.size.number = Vector2(32, 32)
	
	
	for key in vec.size:
		if key != "letter":
			vec.size[key] = Vector2(32, 32)
	
	vec.size.facet = vec.size.outcome#vec.size.letter + Vector2(vec.size.letter.x, 0)
	
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	color.indicator = {}
	
	var max_h = 360.0
	var s = 0.75
	var v = 1
	
	color.element = {}
	color.element["aqua"] = Color.from_hsv(240.0 / max_h, s, v)
	color.element["wind"] = Color.from_hsv(160.0 / max_h, s, v)
	color.element["fire"] = Color.from_hsv(0.0 / max_h, s, v)
	color.element["earth"] = Color.from_hsv(80.0 / max_h, s, v)
	
	color.terrain = {}
	color.terrain["pond"] = Color.from_hsv(200.0 / max_h, s, v)
	color.terrain["plain"] = Color.from_hsv(60.0 / max_h, s, v)
	color.terrain["forest"] = Color.from_hsv(120.0 / max_h, s, v)
	color.terrain["mountain"] = Color.from_hsv(280.0 / max_h, s, v)


func save(path_: String, data_: String):
	var file = FileAccess.open(path_, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var error = json_object.parse(text)
	
	if error == OK:
		return json_object.get_data()


func get_resource_path(resource_: String) -> Variant:
	for business in dict.business:
		for key in dict.business[business]:
			if resource_ == dict.business[business][key]:
				var path = {}
				path.business = business
				path.key = key
				return path
	
	return null


func get_handler_based_on_raw(raw_: String) -> Variant:
	for subtype in dict.facet.type["servant"]:
		for outcome in Global.dict.facet.type["servant"][subtype].outcomes:
			var data = Global.dict.facet.type["servant"][subtype].outcomes[outcome]
			
			if data.has("raw"):
				if data.raw != data.resource and raw_ == data.raw and dict.conversion.product.has(data.resource):
					return subtype
	
	return null


func save_statistics(statistics_: Dictionary) -> void:
	var time = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)
	var path = "res://asset/stat/stat.json"# + "stat" + ".json"
	var file_dict = load_data(path)
	file_dict[time] = statistics_
	var str_ = JSON.stringify(file_dict)
	save(path, str_)


func split_two_point(points_: Array, delta_: float):
	var a = points_.front()
	var b = points_.back()
	var x = (a.x+b.x*delta_)/(1+delta_)
	var y = (a.y+b.y*delta_)/(1+delta_)
	var point = Vector2(x, y)
	return point


func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null


func get_conversion(resource_: String) -> Variant:
	if num.conversion.has(resource_):
		return num.conversion[resource_]
	else:
		return null


func get_specializations_based_on_resource(resource_: String) -> Array:
	var specializations = []
	var type = "servant"
	
	for subtype in dict.facet.type[type]:
		for outcome in dict.facet.type[type][subtype].outcomes:
			var data = dict.facet.type[type][subtype].outcomes[outcome]
			
			if !specializations.has(subtype) and data.has("resource"):
				if resource_ == data.resource:
					specializations.append(subtype)
				else:
					break
	
	return specializations


func get_workplace_based_on_specialization(specialization_: String) -> Variant:
	var type = "servant"
	var data =  dict.facet.type[type][specialization_]
	return data.workplace


func get_specializations_based_on_workplace(workplace_: String) -> Array:
	var specializations = []
	var type = "servant"
	
	for specialization in dict.facet.type[type]:
		var data = dict.facet.type[type][specialization]
		
		if data.workplace == workplace_:
			specializations.append(specialization)
	
	return specializations


func get_workouts_based_on_specialization(specialization_: String) -> Dictionary:
	var type = "servant"
	var data =  dict.facet.type[type][specialization_]
	return data.workouts

