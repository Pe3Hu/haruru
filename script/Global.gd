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
	arr.token = ["gold", "influence"]
	arr.phase = [
		"select dices",
		"roll dices",
		"active dices",
		"discard dices"
	]


func init_num() -> void:
	num.index = {}


func init_dict() -> void:
	init_neighbor()
	init_facet()


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
	
	pass


func init_vec():
	vec.size = {}
	
	vec.size.letter = Vector2(20, 20)
	vec.size.facet = vec.size.letter + Vector2(vec.size.letter.x, 0)
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	color.indicator = {}


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var parse_err = json_object.parse(text)
	return json_object.get_data()
