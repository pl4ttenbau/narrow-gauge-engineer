class_name VehicleWheels extends Resource

@export_storage var vehicle: RailVehicle
@export var current_node_i: int
@export var current_track: RailTrackData
@export var current_section: TrackSectionData

@export_storage var target: RailNodeData:
	get: return self.current_section.target

func _init(_vehicle: RailVehicle, _track: RailTrackData, _start_index: int):
	self.vehicle = _vehicle
	self.current_track = _track
	self.current_node_i = _start_index
	# create section
	self.current_section = TrackSectionData.new()
	self.current_section.track = _track
	self.current_section.origin = _track.get_rail_node(_start_index)

func set_origin_point(_point_index: int):
	var start_node: RailNodeData = self.get_node_obj(_point_index)
	self.current_section.origin = start_node
	self.current_node_i = _point_index
	# self.rail_section.last_node = 
	self.vehicle.position = self.get_node_pos(_point_index)
	
func set_target_point(_point_index: int):
	var next_node: RailNodeData = self.get_node_obj(_point_index)
	self.current_section.target = next_node
	if next_node:
		self.vehicle.rotate_to(next_node.position)
		
func set_on_connected_track(end_node: RailNodeData):
	if end_node.fork && end_node.fork.setTo:
		var next_track_num = end_node.fork.setTo
		Loggie.info("Switching to track with num %d" % next_track_num)
		self.current_track = self.get_rail_by_num(next_track_num)
		self.current_node_i = 0
		self.put_on_track()
		self.vehicle.motor.start()

func put_on_track() -> void:
	self.set_origin_point(self.current_node_i)
	self.set_target_point(self.current_node_i +1)

#region Getters
func get_node_obj(_i: int) -> RailNodeData:
	return self.current_track.get_rail_node(_i)
	
func get_node_pos(_i: int) -> Vector3:
	return self.current_track.vertices[_i]
	
func get_rail_by_num(rail_num: int) -> RailTrackData:
	var index := rail_num -1
	var rail: RailTrackData = GlobalState.tracks[index]
	if ! rail:
		Loggie.warn("Cannot get track with num %d" % rail_num)
		return null
	return rail
#endregion
