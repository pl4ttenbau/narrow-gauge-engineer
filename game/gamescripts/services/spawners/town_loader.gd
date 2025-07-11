@icon("res://assets/icons/icon_town_white.png")
class_name TownPlacer extends Node

const MAP_TOWNS_FILEPATH = "res://world/demmin/jsondata/towns.json"
const TOWN_ROOT_SCENE_PATH = "res://scenes/subscenes/town_root.tscn"

@export var towns: Array[TownData] = []
@export var town_centers: Array[TownCenter]
@export_storage var res_bld_loader: ResidentialBldTypeLoader

func _enter_tree() -> void:
	SignalBus.scene_root_ready.connect(Callable(self, "_on_scene_ready"))

func _on_scene_ready() -> void:
	load_towns()
	
func parse_towns_json(_json_str: String) -> Array[TownData]:
	var json_arr = JSON.parse_string(_json_str) as Array[Dictionary]
	if !json_arr:
		push_warning("Couldnt load Town from \"%s\"" % _json_str)
		return []
	var town_obj_arr: Array[TownData] = []
	for town_values_dict: Dictionary in json_arr:
		town_obj_arr.append(TownData.from_json(town_values_dict))
	return town_obj_arr
				
func load_towns():
	var town_json_str = FileAccess.get_file_as_string(MAP_TOWNS_FILEPATH)
	for parsed_town: TownData in parse_towns_json(town_json_str):
		var spawned_town: TownData = spawn_town(parsed_town)
		add_town(spawned_town)
	SignalBus.towns_loaded.emit()
	
func add_town(_town: TownData):
	self.towns.append(_town)
	GlobalState.towns.append(_town)
	
func spawn_town(_town: TownData) -> TownData:
	var sceneRes: Resource = ResourceLoader.load(TOWN_ROOT_SCENE_PATH) as PackedScene
	var town_container_node: TownCenter = sceneRes.instantiate()
	town_container_node.town = _town
	town_container_node.position = get_pos_on_terrain(_town.pos_xz)
	add_child(town_container_node)
	# emit signal
	SignalBus.town_spawned.emit(_town)
	return _town
	
func get_pos_on_terrain(posXZ: Vector2):
	var vec3: Vector3 = Vector3(posXZ.x, 0, posXZ.y)
	var terr_container: TerrainContainer = GlobalState.terrain
	return terr_container.get_pos_at_height(vec3)

func get_label_pos_at(posXZ: Vector2) -> Vector3:
	var offset: Vector3 = Vector3(0, 30, 0)
	var terrainPos: Vector3 = get_pos_on_terrain(posXZ)
	return terrainPos + offset
