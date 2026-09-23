class_name OrbitCamera
extends Camera3D

@export var target: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var distance: float = 0.6
@export var min_distance: float = 0.1
@export var max_distance: float = 20.0
@export var rotation_speed: float = 0.005
@export var pan_speed: float = 0.0015
@export var zoom_speed: float = 0.08
@export var enable_left_click_orbit: bool = true

var _yaw: float = 0.0
var _pitch: float = -0.5

var _ui_panel: Control = null

func _ready() -> void:
	_update_camera_transform()

func _is_mouse_over_ui(mouse_pos: Vector2) -> bool:
	if not is_instance_valid(_ui_panel):
		_ui_panel = get_node_or_null("/root/Main/UILayer/UIPanel") as Control
	if is_instance_valid(_ui_panel):
		if _ui_panel.get("is_minimized") == true:
			var btn_restore = _ui_panel.get("btn_restore_menu") as Control
			if is_instance_valid(btn_restore) and btn_restore.is_visible_in_tree():
				return btn_restore.get_global_rect().has_point(mouse_pos)
			return false
		if _ui_panel.is_visible_in_tree():
			return _ui_panel.get_global_rect().has_point(mouse_pos)
	return false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var mouse_pos = get_viewport().get_mouse_position()
		if _is_mouse_over_ui(mouse_pos):
			return

	if event is InputEventMouseMotion:
		if Input.is_key_pressed(KEY_SHIFT) and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			return # Let ui_controller handle the drag

		if enable_left_click_orbit and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			# Orbit rotation (left click drag)
			_yaw -= event.relative.x * rotation_speed
			_pitch -= event.relative.y * rotation_speed
			_pitch = clampf(_pitch, -deg_to_rad(85.0), deg_to_rad(85.0))
			_update_camera_transform()
			get_viewport().set_input_as_handled()
		elif (not enable_left_click_orbit and (event.button_mask & MOUSE_BUTTON_MASK_RIGHT)) or (enable_left_click_orbit and (event.button_mask & MOUSE_BUTTON_MASK_RIGHT)):
			if enable_left_click_orbit:
				# Panning (right click drag in normal mode)
				var right := transform.basis.x
				var up := transform.basis.y
				target -= right * event.relative.x * pan_speed * distance
				target += up * event.relative.y * pan_speed * distance
			else:
				# Orbit rotation (right click drag in Parts Mode)
				_yaw -= event.relative.x * rotation_speed
				_pitch -= event.relative.y * rotation_speed
				_pitch = clampf(_pitch, -deg_to_rad(85.0), deg_to_rad(85.0))
			_update_camera_transform()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if projection == Camera3D.PROJECTION_ORTHOGONAL:
				size = maxf(size * 0.9, 0.001)
			else:
				distance = clampf(distance - zoom_speed * distance, min_distance, max_distance)
			_update_camera_transform()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if projection == Camera3D.PROJECTION_ORTHOGONAL:
				size = size * 1.1
			else:
				distance = clampf(distance + zoom_speed * distance, min_distance, max_distance)
			_update_camera_transform()
			get_viewport().set_input_as_handled()

func _update_camera_transform() -> void:
	var rot_basis := Basis.IDENTITY
	rot_basis = rot_basis.rotated(Vector3.RIGHT, _pitch)
	rot_basis = Basis(Vector3.UP, _yaw) * rot_basis

	var offset := rot_basis * (Vector3.BACK * distance)
	global_position = target + offset
	transform.basis = rot_basis

func set_orthogonal_mode(is_ortho: bool) -> void:
	if is_ortho:
		projection = Camera3D.PROJECTION_ORTHOGONAL
	else:
		projection = Camera3D.PROJECTION_PERSPECTIVE

func reset_view() -> void:
	target = Vector3(0.0, 0.0, 0.0)
	distance = 0.6
	_yaw = 0.0
	_pitch = -0.5
	_update_camera_transform()

func set_view_axis(axis: Vector3, yaw_offset_deg: float = 0.0) -> void:
	if abs(axis.x) > 0.5:
		_yaw = (PI / 2.0) * sign(axis.x)
		_pitch = 0.0
	elif abs(axis.y) > 0.5:
		_yaw = 0.0
		# Negative pitch moves offset up (viewing from top)
		_pitch = (-PI / 2.0) * sign(axis.y)
	elif abs(axis.z) > 0.5:
		_yaw = 0.0 if axis.z > 0 else PI
		_pitch = 0.0
	_yaw += deg_to_rad(yaw_offset_deg)
	_update_camera_transform()

func focus_target_aabb(aabb: AABB, fill_ratio: float = 0.5) -> void:
	target = aabb.get_center()
	var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
	if max_dim < 0.0001:
		max_dim = 0.5
	
	if projection == Camera3D.PROJECTION_ORTHOGONAL:
		size = max_dim / max(fill_ratio, 0.01)
		var req_dist = max_dim * 3.0
		if req_dist > max_distance:
			max_distance = req_dist * 2.0
		distance = clampf(req_dist, 0.2, max_distance)
	else:
		var fov_rad = deg_to_rad(fov)
		var req_dist = (max_dim / max(fill_ratio, 0.01)) / (2.0 * tan(fov_rad / 2.0))
		if req_dist > max_distance:
			max_distance = req_dist * 2.0
		distance = clampf(req_dist, min_distance, max_distance)

	_update_camera_transform()


