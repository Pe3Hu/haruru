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
	
	arr.state = ["earldom", "dukedom", "kingdom", "empire"]
	
	arr.layer = {}
	arr.layer.cloth = ["flap", "patch", "terrain", "abundance", "element", "earldom", "dukedom", "kingdom", "empire"]
	
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
	num.index.state = {}
	
	num.size = {}
	
	num.size = {}
	num.size.delta = 12
	
	num.size.flap = {}
	num.size.flap.col = 8
	num.size.flap.row = 8
	num.size.flap.a = 64
	num.size.flap.R = num.size.flap.a
	num.size.flap.r = num.size.flap.R * sqrt(3) / 2
	
	num.size.knob = {}
	num.size.knob.a = 4
	num.size.knob.R = num.size.knob.a
	num.size.knob.hub = 8
	
	num.size.empire = {}
	num.size.empire.limit = 4


func init_dict() -> void:
	init_time()
	init_polygon()
	init_business()
	init_neighbor()
	#init_facet()
	init_servant()
	#init_mercenary()
	init_abundance()
	
	dict.endowment = {}
	
	for raw in dict.raw:
		var value = 1000
		dict.endowment[raw] = value
	
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
	


func init_time() -> void:
	dict.time = {}
	dict.time.day = 1
	dict.time.week = dict.time.day * 7
	dict.time.month = dict.time.week * 4
	dict.time.season = dict.time.month * 3
	dict.time.year = dict.time.season * 4


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
	dict.conversion["food"] = "canned"
	dict.conversion["wood"] = "plank"
	dict.conversion["ore"] = "ingot"
	dict.conversion["gem"] = "jewel"
	
	dict.raw = {}
	dict.raw["food"] = "canned"
	dict.raw["wood"] = "plank"
	dict.raw["ore"] = "ingot"
	dict.raw["gem"] = "jewel"
	
	dict.product = {}
	dict.product["canned"] = "food"
	dict.product["plank"] = "wood"
	dict.product["ingot"] = "ore"
	dict.product["jewel"] = "gem"


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
	dict.facet = {}
	dict.facet.type = {}
	var path = "res://asset/json/haruru_servant.json"
	var array = load_data(path)

	for facet in array:
		var data = {}
		
		if !dict.facet.type.has(facet.type):
			dict.facet.type[facet.type] = {}
		
		if !dict.facet.type[facet.type].has(facet.subtype):
			dict.facet.type[facet.type][facet.subtype] = {}
			dict.facet.type[facet.type][facet.subtype]["failure"] = {}
			dict.facet.type[facet.type][facet.subtype]["failure"]["facets"] = facet.dice
		
		for key in facet:
			match typeof(facet[key]):
				TYPE_FLOAT:
					data[key] = int(facet[key])
				TYPE_STRING:
					if !key.contains("type"):
						data[key] = facet[key]
		
		dict.facet.type[facet.type][facet.subtype][data.outcome] = data
		dict.facet.type[facet.type][facet.subtype][data.outcome].erase("dice")
		dict.facet.type[facet.type][facet.subtype][data.outcome].erase("outcome")
		dict.facet.type[facet.type][facet.subtype]["failure"]["facets"] -= data.facets
	
	#print(dict.facet.type["servant"])


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


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_scene() -> void:
	scene.sketch = load("res://scene/0/sketch.tscn")
	
	scene.diplomacy = load("res://scene/1/diplomacy.tscn")
	scene.tribe = load("res://scene/1/tribe.tscn")
	scene.member = load("res://scene/1/member.tscn")
	
	scene.structure = load("res://scene/2/structure.tscn")
	scene.storey = load("res://scene/2/storey.tscn")
	scene.chamber = load("res://scene/2/chamber.tscn")
	
	scene.dice = load("res://scene/3/dice.tscn")
	scene.facet = load("res://scene/3/facet.tscn")
	scene.icon = load("res://scene/3/icon.tscn")
	
	scene.encounter = load("res://scene/4/encounter.tscn")
	scene.squad = load("res://scene/4/squad.tscn")
	
	
	scene.flap = load("res://scene/5/flap.tscn")
	scene.knob = load("res://scene/5/knob.tscn")
	scene.seam = load("res://scene/5/seam.tscn")
	scene.patch = load("res://scene/5/patch.tscn")
	scene.frontier = load("res://scene/5/frontier.tscn")
	scene.state = load("res://scene/5/state.tscn")
	
	
	pass


func init_vec():
	vec.size = {}
	
	vec.size.letter = Vector2(20, 20)
	vec.size.resource = Vector2(32, 32)#Vector2(32, 32) Vector2(64, 64)
	vec.size.servant = Vector2(32, 32)
	vec.size.outcome = Vector2(32, 32)
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
				
#				var key = ""
#
#				if Global.dict.raw.has(resource_):
#					key = "Raw"
#				if Global.dict.product.has(resource_):
#					key = "Product"
				path.business = business
				path.key = key
				return path
	
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
