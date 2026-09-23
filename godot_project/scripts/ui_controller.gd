## ui_controller.gd - Central UI panel controller for runtime simulation configuration
extends Control

# VisualState の定数
const VS_OPAQUE      := 0
const VS_TRANSPARENT := 1
const VS_HIDDEN      := 2

# References
@onready var model_root: Node3D = _find_assembly_root()
@onready var camera: OrbitCamera = _find_camera()

# App Version
const APP_VERSION := "0.0.1"
@onready var version_label: Label = get_node_or_null("%VersionLabel") as Label

# Menu minimization controls
var is_minimized: bool = false
var _menu_tween: Tween = null
@onready var btn_minimize_menu: Button = get_node_or_null("%BtnMinimizeMenu") as Button
@onready var btn_restore_menu: Button = get_node_or_null("%BtnRestoreMenu") as Button


# Playback controls
@onready var btn_play: Button = %BtnPlay
@onready var btn_pause: Button = %BtnPause
@onready var btn_reset: Button = %BtnReset
@onready var lbl_status: Label = %LblStatus

# Model Loader
@onready var btn_load_model: Button = %BtnLoadModel
@onready var btn_add_model: Button = %BtnAddModel
@onready var btn_export_glb: Button = %BtnExportGLB
@onready var part_list: ItemList = %PartList
@onready var tscn_list: ItemList = %TscnList

# Part controls - Placement Transform Controls
@onready var lbl_selected_part_name: Label = %LblSelectedPartName
@onready var btn_part_opaque: Button = %BtnPartOpaque
@onready var btn_part_transparent: Button = %BtnPartTransparent
@onready var btn_part_hidden: Button = %BtnPartHidden

var spin_part_pos_x: SpinBox
var spin_part_pos_y: SpinBox
var spin_part_pos_z: SpinBox
var btn_reset_part_pos: Button

var spin_part_rot_x: SpinBox
var spin_part_rot_y: SpinBox
var spin_part_rot_z: SpinBox
var btn_reset_part_rot: Button

var spin_part_scale_x: SpinBox
var spin_part_scale_y: SpinBox
var spin_part_scale_z: SpinBox
var btn_reset_part_scale: Button
var btn_link_part_scale: Button

# Runtime Custom Motion Controls (Dynamically set behavior)
@onready var option_motion_type: OptionButton = %OptionMotionType
@onready var spin_motion_duration: SpinBox = %SpinMotionDuration
@onready var check_motion_ping_pong: CheckBox = %CheckMotionPingPong
@onready var spin_motion_param_min: SpinBox = %SpinMotionParamMin
@onready var spin_motion_param_max: SpinBox = %SpinMotionParamMax
@onready var btn_axis_x: Button = %BtnAxisX
@onready var btn_axis_y: Button = %BtnAxisY
@onready var btn_axis_z: Button = %BtnAxisZ

@onready var btn_pick_pivot: Button = %BtnPickPivot

@onready var spin_pivot_x: SpinBox = %SpinPivotX
@onready var spin_pivot_y: SpinBox = %SpinPivotY
@onready var spin_pivot_z: SpinBox = %SpinPivotZ


@onready var line_edit_save_name: LineEdit = %LineEditSaveName
@onready var option_load_config: OptionButton = get_node_or_null("%OptionLoadConfig") as OptionButton
@onready var btn_save_config: Button = %BtnSaveConfig
@onready var btn_rename_tscn: Button = get_node_or_null("%BtnRenameTscn") as Button
@onready var btn_delete_tscn: Button = get_node_or_null("%BtnDeleteTscn") as Button
@onready var btn_load_config: Button = get_node_or_null("%BtnLoadConfig") as Button
@onready var btn_all_reset: Button = %BtnAllReset

# File Tab Playback controls
@onready var btn_play2: Button = %BtnPlay2
@onready var btn_pause2: Button = %BtnPause2
@onready var btn_reset2: Button = %BtnReset2
@onready var btn_all_reset2: Button = %BtnAllReset2
@onready var btn_clear_all: Button = %BtnClearAll
@onready var lbl_status2: Label = %LblStatus2

# Creation Tab controls
@onready var btn_import_image: Button = %BtnImportImage
@onready var line_edit_create_name: LineEdit = %LineEditCreateName
@onready var color_picker_create: ColorPickerButton = %ColorPickerCreate
@onready var spin_create_depth: SpinBox = %SpinCreateDepth
@onready var spin_create_size: SpinBox = %SpinCreateSize
@onready var spin_create_tolerance: SpinBox = %SpinCreateTolerance
@onready var btn_reset_create_depth: Button = %BtnResetCreateDepth
@onready var btn_reset_create_size: Button = %BtnResetCreateSize
@onready var btn_reset_create_tolerance: Button = %BtnResetCreateTolerance
@onready var check_hide_existing: CheckBox = %CheckHideExisting
@onready var btn_insert_created_part: Button = %BtnInsertCreatedPart
@onready var created_part_list: ItemList = %CreatedPartList
@onready var btn_copy_created_part: Button = %BtnCopyCreatedPart
@onready var btn_delete_created_part: Button = %BtnDeleteCreatedPart
@onready var btn_undo_delete_created_part: Button = %BtnUndoDeleteCreatedPart
@onready var btn_rename_created_part: Button = %BtnRenameCreatedPart

var last_deleted_draft: Dictionary = {}
var last_deleted_draft_index: int = -1
var last_deleted_draft_node: Node3D = null

var spin_create_pos_x: SpinBox
var spin_create_pos_y: SpinBox
var spin_create_pos_z: SpinBox
var btn_create_reset_pos: Button

var spin_create_rot_x: SpinBox
var spin_create_rot_y: SpinBox
var spin_create_rot_z: SpinBox
var btn_create_reset_rot: Button

var spin_create_scale_x: SpinBox
var spin_create_scale_y: SpinBox
var spin_create_scale_z: SpinBox
var btn_create_reset_scale: Button
var btn_create_link_scale: Button

@onready var option_create_parent: OptionButton = %OptionCreateParent
@onready var image_file_dialog: FileDialog = %ImageFileDialog
@onready var btn_copy_part: Button = %BtnCopyPart
@onready var btn_delete_part: Button = %BtnDeletePart
@onready var btn_undo_delete_part: Button = %BtnUndoDeletePart
@onready var line_edit_part_name: LineEdit = %LineEditPartName
@onready var btn_rename_part: Button = %BtnRenamePart
@onready var color_picker_part: ColorPickerButton = %ColorPickerPart

var last_deleted_part: Node3D = null
var last_deleted_parent: Node = null
var last_deleted_index: int = -1

var check_show_motion_range: CheckBox = null
var range_mesh_instances: Dictionary = {}

var btn_deselect_model: Button = null
var _mouse_selection_locked: bool = false
var _updating_scale_spinboxes: bool = false
var _running_confirm_dialog: ConfirmationDialog = null
var _pending_confirm_callback: Callable
var _pending_cancel_callback: Callable
var _is_restoring_ui_state: bool = false

var current_raw_img: Image = null
var current_contour_points: Array[Vector2] = []
var draft_mesh_instance: MeshInstance3D = null
var draft_preview_container: Node3D = null

# Multi-contour draft parts management: Array of Dictionaries
var draft_parts: Array[Dictionary] = []
var selected_draft_index: int = -1
var selected_is_group: bool = false
var selected_group_name: String = ""
var created_parent_groups: Array[String] = []


## Currently selected top-level child part inside the GLB
var selected_part: Node3D = null
var selected_parts: Array[Node3D] = []
var _last_synced_position: Vector3 = Vector3.ZERO
var _clear_all_confirm_dialog: ConfirmationDialog = null
var is_picking_pivot: bool = false
@onready var tab_container: TabContainer = %TabContainer
@onready var btn_export_viewer: Button = %BtnExportViewer
var orig_scale := {}
var highlight_material: StandardMaterial3D

var _spin_drag_start_pos := Vector2.ZERO
var _spin_drag_start_val := 0.0
var _spin_is_dragging := false
var _active_drag_spinbox: SpinBox = null

var _is_dragging_part := false
var _drag_plane := Plane()
var _drag_start_intersection := Vector3.ZERO
var _drag_start_part_pos := Vector3.ZERO
var _drag_start_all_pos: Dictionary = {}

# 作成タブドラフト专用のドラッグ状態
var _is_dragging_draft := false
var _draft_drag_start_intersection := Vector3.ZERO
# draft_index -> 開始時点の位置
var _draft_drag_start_positions: Dictionary = {}

# Shift+クリック範囲選択用のアンカーインデックス
var _part_list_last_selected_idx: int = -1
var _created_part_list_last_selected_idx: int = -1

func _configure_drag_spinbox(spin: SpinBox) -> void:
	if not spin: return
	spin.add_theme_icon_override("updown", ImageTexture.new())
	spin.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	spin.custom_minimum_size = Vector2(30, 0)
	var line_edit = spin.get_line_edit()
	if line_edit:
		line_edit.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		line_edit.custom_minimum_size = Vector2(25, 0)
		line_edit.add_theme_font_size_override("font_size", 12)
		line_edit.add_theme_constant_override("minimum_character_width", 0)
		
		# Set compact margins on LineEdit styleboxes so values never get clipped
		for sb_name in ["normal", "focus"]:
			var orig_sb = line_edit.get_theme_stylebox(sb_name)
			var sb: StyleBoxFlat
			if orig_sb is StyleBoxFlat:
				sb = orig_sb.duplicate() as StyleBoxFlat
			else:
				sb = StyleBoxFlat.new()
				sb.bg_color = Color(0.12, 0.13, 0.16, 0.9)
				sb.border_width_left = 1
				sb.border_width_top = 1
				sb.border_width_right = 1
				sb.border_width_bottom = 1
				sb.border_color = Color(0.24, 0.27, 0.32, 1.0)
				sb.corner_radius_top_left = 3
				sb.corner_radius_top_right = 3
				sb.corner_radius_bottom_left = 3
				sb.corner_radius_bottom_right = 3
			sb.content_margin_left = 3
			sb.content_margin_right = 3
			sb.content_margin_top = 2
			sb.content_margin_bottom = 2
			line_edit.add_theme_stylebox_override(sb_name, sb)

		line_edit.gui_input.connect(func(event: InputEvent):
			_handle_spinbox_gui_input(spin, event)
		)

func _handle_spinbox_gui_input(spin: SpinBox, event: InputEvent) -> void:
	if not spin.editable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_spin_drag_start_pos = event.global_position
			_spin_drag_start_val = spin.value
			_spin_is_dragging = false
			_active_drag_spinbox = spin
		else:
			if _spin_is_dragging:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				spin.get_viewport().set_input_as_handled()
			_spin_is_dragging = false
			_active_drag_spinbox = null

	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) and _active_drag_spinbox == spin:
		var mouse_delta = event.relative.x
		if abs(event.global_position.x - _spin_drag_start_pos.x) > 2.0 or _spin_is_dragging:
			if not _spin_is_dragging:
				_spin_is_dragging = true

			var step = spin.step if spin.step > 0.0 else 0.01
			if Input.is_key_pressed(KEY_SHIFT):
				step *= 10.0
			elif Input.is_key_pressed(KEY_CTRL):
				step *= 0.1

			spin.value += mouse_delta * step
			spin.get_viewport().set_input_as_handled()

func _build_transform_section(parent: Control, title: String, is_rotation: bool, is_scale: bool) -> Dictionary:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 2)
	parent.add_child(container)

	# Header HBox: Title on left, Action Buttons (👁, ↺, 🔗) on right
	var header_hbox = HBoxContainer.new()
	header_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_theme_constant_override("separation", 4)
	container.add_child(header_hbox)

	var lbl_title = Label.new()
	lbl_title.text = title
	header_hbox.add_child(lbl_title)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	var reset_btn = Button.new()
	reset_btn.text = "↺"
	if is_scale:
		reset_btn.tooltip_text = "初期スケールにリセット (1.0)"
	elif is_rotation:
		reset_btn.tooltip_text = "モデル初期回転にリセット"
	else:
		reset_btn.tooltip_text = "開始時の位置にリセット"
	header_hbox.add_child(reset_btn)

	var link_btn: Button = null
	if is_scale:
		link_btn = Button.new()
		link_btn.text = "🔗"
		link_btn.toggle_mode = true
		link_btn.button_pressed = true
		link_btn.tooltip_text = "連動スケール"
		header_hbox.add_child(link_btn)

	# Values HBox: 1 line for X, Y, Z
	var row_hbox = HBoxContainer.new()
	row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_hbox.add_theme_constant_override("separation", 4)
	container.add_child(row_hbox)

	var colors = [Color("#ff6666"), Color("#66ff66"), Color("#6699ff")]
	var axes = ["x", "y", "z"]
	var axis_vectors: Array[Vector3] = []
	var yaw_offsets: Array[float] = []
	var view_names: Array[String] = []

	if is_rotation or is_scale:
		axis_vectors = [Vector3.RIGHT, Vector3.UP, Vector3.BACK]
		yaw_offsets = [0.0, 0.0, 0.0]
		view_names = ["+X", "+Y", "+Z"]
	else:
		axis_vectors = [Vector3.BACK, Vector3.RIGHT, Vector3.UP]
		yaw_offsets = [0.0, 0.0, -90.0]
		view_names = ["+Z", "+X", "+Y (右: +Z)"]

	var spins: Array[SpinBox] = []

	var min_val = -180.0 if is_rotation else (0.1 if is_scale else -100.0)
	var max_val = 180.0 if is_rotation else (10.0 if is_scale else 100.0)
	var step_val = 0.001 if not is_rotation else 0.1
	var default_val = 0.0 if not is_scale else 1.0
	var suffix_str = "m" if (not is_rotation and not is_scale) else ("°" if is_rotation else "")

	for i in range(3):
		var sub_hbox = HBoxContainer.new()
		sub_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sub_hbox.add_theme_constant_override("separation", 1)
		row_hbox.add_child(sub_hbox)

		var btn_axis = Button.new()
		btn_axis.text = axes[i]
		btn_axis.flat = true
		btn_axis.custom_minimum_size = Vector2(14, 0)
		btn_axis.add_theme_color_override("font_color", colors[i])
		btn_axis.add_theme_color_override("font_hover_color", colors[i].lightened(0.3))
		btn_axis.add_theme_color_override("font_pressed_color", colors[i])
		btn_axis.add_theme_color_override("font_focus_color", colors[i])
		btn_axis.tooltip_text = view_names[i] + " 方向からの視点に合わせる"
		
		var target_axis = axis_vectors[i]
		var target_yaw_offset = yaw_offsets[i]
		btn_axis.pressed.connect(func():
			if camera and camera.has_method("set_view_axis"):
				camera.set_view_axis(target_axis, target_yaw_offset)
				if is_instance_valid(selected_part) and camera.has_method("focus_target_aabb"):
					camera.focus_target_aabb(_get_node_aabb(selected_part), 0.5)
		)
		sub_hbox.add_child(btn_axis)

		var spin = SpinBox.new()
		spin.min_value = min_val
		spin.max_value = max_val
		spin.step = step_val
		spin.value = default_val
		spin.suffix = suffix_str
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not is_rotation and not is_scale:
			spin.tooltip_text = "%s 軸位置 (m)\n※ 1m = 1000mm (ドラッグまたは数値入力)" % axes[i].to_upper()
		_configure_drag_spinbox(spin)
		sub_hbox.add_child(spin)
		spins.append(spin)

	return {
		"spin_x": spins[0],
		"spin_y": spins[1],
		"spin_z": spins[2],
		"reset_btn": reset_btn,
		"link_btn": link_btn
	}

func fit_view_to_all_parts() -> void:
	if not camera or not camera.has_method("focus_target_aabb"):
		return
	
	# 作成タブが開かれており、ドラフトプレビューが存在する場合はドラフト全体にフィット
	var is_creation_tab = false
	if is_instance_valid(tab_container) and tab_container.get_child_count() > tab_container.current_tab:
		var cur_tab = tab_container.get_child(tab_container.current_tab)
		if cur_tab and cur_tab.name == "作成":
			is_creation_tab = true
	
	if is_creation_tab and is_instance_valid(draft_preview_container) and draft_preview_container.get_child_count() > 0:
		var aabb = _get_node_aabb(draft_preview_container, true)
		camera.focus_target_aabb(aabb, 0.5)
		return

	if is_instance_valid(model_root):
		var aabb = _get_node_aabb(model_root, true)
		camera.focus_target_aabb(aabb, 0.5)

func create_ground_node(at_y: float = 0.0) -> Node3D:
	var ground_part = Node3D.new()
	ground_part.name = "GroundPlane"
	ground_part.set_meta("generated_by_importer", true)
	
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = "GroundMesh"
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(10.0, 10.0)
	mesh_inst.mesh = plane_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.75, 0.78, 0.82, 1.0)
	mat.roughness = 0.7
	mesh_inst.material_override = mat
	
	if not Engine.is_editor_hint():
		mesh_inst.create_convex_collision(true, true)
	ground_part.add_child(mesh_inst)
	
	ground_part.position = Vector3(0.0, at_y, 0.0)
	ground_part.set_meta("initial_transform", ground_part.transform)
	ground_part.set_meta("initial_position", ground_part.position)
	ground_part.set_meta("initial_rotation", ground_part.rotation_degrees)
	ground_part.set_meta("glb_original_transform", ground_part.transform)
	ground_part.set_meta("glb_original_position", ground_part.position)
	ground_part.set_meta("glb_original_rotation", ground_part.rotation_degrees)
	return ground_part

func get_all_ground_nodes() -> Array[Node3D]:
	var grounds: Array[Node3D] = []
	var main_ground = get_node_or_null("/root/Main/GroundPlane")
	if main_ground is Node3D:
		grounds.append(main_ground as Node3D)
	if is_instance_valid(model_root):
		for child in model_root.get_children():
			if child is Node3D and child.name == "GroundPlane":
				grounds.append(child as Node3D)
	return grounds

func set_ground_visible(is_visible: bool, at_y: float = 0.0) -> void:
	var grounds = get_all_ground_nodes()
	if is_visible:
		if grounds.is_empty() and is_instance_valid(model_root):
			var new_g = create_ground_node(at_y)
			model_root.add_child(new_g)
			grounds.append(new_g)
		for g in grounds:
			g.visible = true
			g.position.y = at_y
			g.set_meta("visual_state", VS_OPAQUE)
			g.set_meta("is_deleted", false)
			_set_node_collision_enabled_recursive(g, true)
			# main.tscn 等に直接配置された地面はリセット用メタが未設定なので補完する
			if not g.has_meta("glb_original_transform"):
				g.set_meta("glb_original_transform", g.transform)
				g.set_meta("glb_original_position", g.position)
				g.set_meta("glb_original_rotation", g.rotation_degrees)
				g.set_meta("initial_transform", g.transform)
				g.set_meta("initial_position", g.position)
				g.set_meta("initial_rotation", g.rotation_degrees)
	else:
		for g in grounds:
			g.visible = false
			g.set_meta("visual_state", VS_HIDDEN)
			_set_node_collision_enabled_recursive(g, false)

func _get_ground_y() -> float:
	var grounds = get_all_ground_nodes()
	if not grounds.is_empty() and is_instance_valid(grounds[0]):
		return grounds[0].position.y
	return 0.0

func _on_view_fit_clicked() -> void:
	if camera and camera.has_method("focus_target_aabb"):
		var is_creation_tab = false
		if is_instance_valid(tab_container) and tab_container.get_child_count() > tab_container.current_tab:
			var cur_tab = tab_container.get_child(tab_container.current_tab)
			if cur_tab and cur_tab.name == "作成":
				is_creation_tab = true

		if is_creation_tab:
			if selected_draft_index >= 0 and is_instance_valid(draft_preview_container):
				for child in draft_preview_container.get_children():
					if child is MeshInstance3D and child.get_meta("draft_index", -1) == selected_draft_index:
						var aabb = _get_node_aabb(child, true)
						camera.focus_target_aabb(aabb, 0.5)
						return
			if is_instance_valid(draft_preview_container) and draft_preview_container.get_child_count() > 0:
				var aabb = _get_node_aabb(draft_preview_container, true)
				camera.focus_target_aabb(aabb, 0.5)
				return

		if is_instance_valid(selected_part):
			var is_ground = (selected_part.name == "GroundPlane" or selected_part.name == "GroundMesh")
			var aabb = _get_node_aabb(selected_part, not is_ground)
			camera.focus_target_aabb(aabb, 0.5)
		elif is_instance_valid(model_root):
			var aabb = _get_node_aabb(model_root, true)
			camera.focus_target_aabb(aabb, 0.5)

func _get_node_aabb(node: Node3D, exclude_ground: bool = true) -> AABB:
	var combined_aabb := AABB()
	var has_mesh = false
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var curr = stack.pop_back()
		if curr != node and curr is Node3D and not curr.visible:
			continue
		if exclude_ground and (curr.name == "GroundPlane" or curr.name == "GroundMesh" or (curr.get_parent() and curr.get_parent().name == "GroundPlane")):
			continue
		if curr is MeshInstance3D and curr.mesh:
			var local_aabb = curr.get_aabb()
			var global_trans = curr.global_transform
			for i in range(8):
				var corner = global_trans * local_aabb.get_endpoint(i)
				if not has_mesh:
					combined_aabb = AABB(corner, Vector3.ZERO)
					has_mesh = true
				else:
					combined_aabb = combined_aabb.expand(corner)
		for child in curr.get_children():
			if child is Node3D:
				stack.append(child)
	if not has_mesh:
		combined_aabb = AABB(node.global_position - Vector3(0.1, 0.1, 0.1), Vector3(0.2, 0.2, 0.2))
	return combined_aabb

func _cleanup_before_quit() -> void:
	# 1. プレビューコンテナの即時完全解放
	if is_instance_valid(draft_preview_container):
		for c in draft_preview_container.get_children():
			draft_preview_container.remove_child(c)
			c.free()
		if draft_preview_container.get_parent():
			draft_preview_container.get_parent().remove_child(draft_preview_container)
		draft_preview_container.free()
		draft_preview_container = null

	# 2. ドラフトパーツ内のノード参照を解除
	for draft in draft_parts:
		if draft is Dictionary:
			draft["node"] = null

	# 3. 削除バッファノードの解放
	if is_instance_valid(last_deleted_part) and last_deleted_part.get_parent() == null:
		last_deleted_part.free()
	last_deleted_part = null

	if is_instance_valid(last_deleted_draft_node) and last_deleted_draft_node.get_parent() == null:
		last_deleted_draft_node.free()
	last_deleted_draft_node = null

	# 4. 辞書参照・選択のクリア
	orig_scale.clear()
	selected_parts.clear()
	selected_part = null


func _quit_app() -> void:
	_cleanup_before_quit()
	get_tree().quit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _is_modified:
			_show_quit_confirm_dialog()
		elif _was_just_cleared:
			_show_quit_cleared_confirm_dialog()
		else:
			_quit_app()
	elif what == NOTIFICATION_PREDELETE:
		_cleanup_before_quit()

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	var app_ver = ProjectSettings.get_setting("application/config/version", APP_VERSION)
	DisplayServer.window_set_title("HGNN-Parts v" + app_ver)
	if is_instance_valid(version_label):
		version_label.text = "v" + app_ver
	if FileAccess.file_exists("res://icon.png"):
		var icon_img = Image.load_from_file(ProjectSettings.globalize_path("res://icon.png"))
		if icon_img:
			DisplayServer.window_set_icon(icon_img)

	model_root = _find_assembly_root()
	camera = _find_camera()

	# Create top-right model deselect button
	btn_deselect_model = Button.new()
	btn_deselect_model.name = "BtnDeselectModel"
	btn_deselect_model.text = "✕ 選択解除"
	btn_deselect_model.anchor_left = 1.0
	btn_deselect_model.anchor_top = 0.0
	btn_deselect_model.anchor_right = 1.0
	btn_deselect_model.anchor_bottom = 0.0
	btn_deselect_model.offset_left = -140.0
	btn_deselect_model.offset_top = 16.0
	btn_deselect_model.offset_right = -16.0
	btn_deselect_model.offset_bottom = 46.0
	btn_deselect_model.visible = false
	btn_deselect_model.pressed.connect(_on_deselect_model_pressed)
	var ui_layer = get_node_or_null("/root/Main/UILayer")
	if ui_layer:
		ui_layer.add_child.call_deferred(btn_deselect_model)

	_setup_menu_minimize_controls()

	# Build Placement Tab Transform Controls
	var container_part_pos = get_node_or_null("%ContainerPartPos")
	if container_part_pos:
		var pos_sec = _build_transform_section(container_part_pos, "位置", false, false)
		spin_part_pos_x = pos_sec["spin_x"]
		spin_part_pos_y = pos_sec["spin_y"]
		spin_part_pos_z = pos_sec["spin_z"]
		btn_reset_part_pos = pos_sec["reset_btn"]

	var container_part_rot = get_node_or_null("%ContainerPartRot")
	if container_part_rot:
		var rot_sec = _build_transform_section(container_part_rot, "回転", true, false)
		spin_part_rot_x = rot_sec["spin_x"]
		spin_part_rot_y = rot_sec["spin_y"]
		spin_part_rot_z = rot_sec["spin_z"]
		btn_reset_part_rot = rot_sec["reset_btn"]

	var container_part_scale = get_node_or_null("%ContainerPartScale")
	if container_part_scale:
		var scale_sec = _build_transform_section(container_part_scale, "スケール", false, true)
		spin_part_scale_x = scale_sec["spin_x"]
		spin_part_scale_y = scale_sec["spin_y"]
		spin_part_scale_z = scale_sec["spin_z"]
		btn_reset_part_scale = scale_sec["reset_btn"]
		btn_link_part_scale = scale_sec["link_btn"]
		btn_reset_part_scale.pressed.connect(_on_reset_part_scale_clicked)

	# Build Creation Tab Transform Controls
	var container_create_pos = get_node_or_null("%ContainerCreatePos")
	if container_create_pos:
		var c_pos_sec = _build_transform_section(container_create_pos, "位置", false, false)
		spin_create_pos_x = c_pos_sec["spin_x"]
		spin_create_pos_y = c_pos_sec["spin_y"]
		spin_create_pos_z = c_pos_sec["spin_z"]
		btn_create_reset_pos = c_pos_sec["reset_btn"]

	var container_create_rot = get_node_or_null("%ContainerCreateRot")
	if container_create_rot:
		var c_rot_sec = _build_transform_section(container_create_rot, "回転", true, false)
		spin_create_rot_x = c_rot_sec["spin_x"]
		spin_create_rot_y = c_rot_sec["spin_y"]
		spin_create_rot_z = c_rot_sec["spin_z"]
		btn_create_reset_rot = c_rot_sec["reset_btn"]

	var container_create_scale = get_node_or_null("%ContainerCreateScale")
	if container_create_scale:
		var c_scale_sec = _build_transform_section(container_create_scale, "スケール", false, true)
		spin_create_scale_x = c_scale_sec["spin_x"]
		spin_create_scale_y = c_scale_sec["spin_y"]
		spin_create_scale_z = c_scale_sec["spin_z"]
		btn_create_reset_scale = c_scale_sec["reset_btn"]
		btn_create_link_scale = c_scale_sec["link_btn"]
		btn_create_reset_scale.pressed.connect(_on_reset_create_scale_clicked)

	# Load parts into the Create Tab
	_update_created_part_list()

	# Playback connections
	if btn_play:
		btn_play.pressed.connect(_on_play_pressed)
	if btn_pause:
		btn_pause.pressed.connect(_on_pause_pressed)
	if btn_reset:
		btn_reset.pressed.connect(_on_simulation_reset_pressed)
	if btn_play2:
		btn_play2.pressed.connect(_on_play_pressed)
	if btn_pause2:
		btn_pause2.pressed.connect(_on_pause_pressed)
	if btn_reset2:
		btn_reset2.pressed.connect(_on_simulation_reset_pressed)
	
	highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = Color(1.0, 0.2, 0.2, 0.4)
	highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	if btn_all_reset:
		btn_all_reset.pressed.connect(_on_all_reset_pressed)
	if btn_all_reset2:
		btn_all_reset2.pressed.connect(_on_all_reset_pressed)
	if btn_clear_all:
		btn_clear_all.pressed.connect(_on_clear_all_pressed)

	# Model Loader connection
	btn_load_model.pressed.connect(_on_load_model_pressed)
	btn_add_model.pressed.connect(_on_add_model_pressed)
	btn_export_glb.pressed.connect(_on_export_glb_pressed)
	
	if part_list:
		part_list.select_mode = ItemList.SELECT_MULTI
		part_list.item_selected.connect(_on_part_list_item_selected)
		if part_list.has_signal("multi_selected"):
			part_list.multi_selected.connect(func(_idx, _sel): _on_part_list_item_selected(_idx))
		part_list.gui_input.connect(_on_part_list_gui_input)
	if created_part_list:
		created_part_list.select_mode = ItemList.SELECT_MULTI
		created_part_list.item_selected.connect(_on_created_part_list_item_selected)
		if created_part_list.has_signal("multi_selected"):
			created_part_list.multi_selected.connect(func(_idx, _sel): _on_created_part_list_item_selected(_idx))
		created_part_list.gui_input.connect(_on_created_part_list_gui_input)
	btn_export_viewer.pressed.connect(_on_export_viewer_pressed)
	tab_container.tab_changed.connect(_on_tab_changed)

	# Placement SpinBox value change connections
	if spin_part_pos_x: spin_part_pos_x.value_changed.connect(_on_part_position_spinbox_changed)
	if spin_part_pos_y: spin_part_pos_y.value_changed.connect(_on_part_position_spinbox_changed)
	if spin_part_pos_z: spin_part_pos_z.value_changed.connect(_on_part_position_spinbox_changed)
	if btn_reset_part_pos: btn_reset_part_pos.pressed.connect(_on_reset_part_pos_clicked)

	if spin_part_rot_x: spin_part_rot_x.value_changed.connect(_on_part_rotation_spinbox_changed)
	if spin_part_rot_y: spin_part_rot_y.value_changed.connect(_on_part_rotation_spinbox_changed)
	if spin_part_rot_z: spin_part_rot_z.value_changed.connect(_on_part_rotation_spinbox_changed)
	if btn_reset_part_rot: btn_reset_part_rot.pressed.connect(_on_reset_part_rot_clicked)

	if spin_part_scale_x: spin_part_scale_x.value_changed.connect(func(v): _on_part_scale_spinbox_changed(spin_part_scale_x, v))
	if spin_part_scale_y: spin_part_scale_y.value_changed.connect(func(v): _on_part_scale_spinbox_changed(spin_part_scale_y, v))
	if spin_part_scale_z: spin_part_scale_z.value_changed.connect(func(v): _on_part_scale_spinbox_changed(spin_part_scale_z, v))

	# Creation Tab Connections
	if btn_import_image:
		btn_import_image.pressed.connect(_on_import_image_pressed)
	if image_file_dialog:
		image_file_dialog.file_selected.connect(_on_image_file_selected)
	if spin_create_depth:
		spin_create_depth.value_changed.connect(func(_val): _on_create_param_changed())
	if spin_create_size:
		spin_create_size.value_changed.connect(func(_val): _on_create_param_changed())
	if spin_create_tolerance:
		spin_create_tolerance.value_changed.connect(func(_val): _on_tolerance_changed())
	if check_hide_existing:
		check_hide_existing.toggled.connect(_on_check_hide_existing_toggled)
	if color_picker_create:
		color_picker_create.color_changed.connect(func(_col): _on_create_param_changed())

	if spin_create_pos_x: spin_create_pos_x.value_changed.connect(func(_val): _on_create_param_changed())
	if spin_create_pos_y: spin_create_pos_y.value_changed.connect(func(_val): _on_create_param_changed())
	if spin_create_pos_z: spin_create_pos_z.value_changed.connect(func(_val): _on_create_param_changed())
	if btn_create_reset_pos: btn_create_reset_pos.pressed.connect(func(): _on_reset_create_pos_clicked())

	if spin_create_rot_x: spin_create_rot_x.value_changed.connect(func(_val): _on_create_param_changed())
	if spin_create_rot_y: spin_create_rot_y.value_changed.connect(func(_val): _on_create_param_changed())
	if spin_create_rot_z: spin_create_rot_z.value_changed.connect(func(_val): _on_create_param_changed())
	if btn_create_reset_rot: btn_create_reset_rot.pressed.connect(func(): _on_reset_create_rot_clicked())

	if spin_create_scale_x: spin_create_scale_x.value_changed.connect(func(v): _on_create_scale_spinbox_changed(spin_create_scale_x, v))
	if spin_create_scale_y: spin_create_scale_y.value_changed.connect(func(v): _on_create_scale_spinbox_changed(spin_create_scale_y, v))
	if spin_create_scale_z: spin_create_scale_z.value_changed.connect(func(v): _on_create_scale_spinbox_changed(spin_create_scale_z, v))

	if btn_reset_create_depth:
		btn_reset_create_depth.pressed.connect(func():
			if spin_create_depth: spin_create_depth.value = 0.1
			_on_create_param_changed()
		)
	if btn_reset_create_size:
		btn_reset_create_size.pressed.connect(func():
			var reset_size = 1.0
			if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
				reset_size = draft_parts[selected_draft_index].get("initial_size", 1.0)
			if spin_create_size: spin_create_size.value = reset_size
			_on_create_param_changed()
		)
	if btn_reset_create_tolerance:
		btn_reset_create_tolerance.pressed.connect(func():
			if spin_create_tolerance: spin_create_tolerance.value = 1.0
			_on_create_param_changed()
		)

	# Configure static scene SpinBoxes for drag behavior & hidden arrows
	_configure_drag_spinbox(spin_motion_duration)
	_configure_drag_spinbox(spin_motion_param_min)
	_configure_drag_spinbox(spin_motion_param_max)
	_configure_drag_spinbox(spin_pivot_x)
	_configure_drag_spinbox(spin_pivot_y)
	_configure_drag_spinbox(spin_pivot_z)
	_configure_drag_spinbox(spin_create_depth)
	_configure_drag_spinbox(spin_create_size)
	_configure_drag_spinbox(spin_create_tolerance)

	if option_create_parent:
		option_create_parent.item_selected.connect(func(_idx): _on_create_parent_option_selected(_idx))
	if btn_insert_created_part:
		btn_insert_created_part.pressed.connect(_on_insert_created_part_pressed)
	if btn_copy_created_part:
		btn_copy_created_part.pressed.connect(_on_copy_created_part_pressed)
	if btn_delete_created_part:
		btn_delete_created_part.pressed.connect(_on_delete_created_part_pressed)
	if btn_undo_delete_created_part:
		btn_undo_delete_created_part.pressed.connect(_on_undo_delete_created_part_pressed)
	if btn_rename_created_part:
		btn_rename_created_part.pressed.connect(_on_rename_created_part_pressed)
	if is_instance_valid(line_edit_create_name):
		line_edit_create_name.text_submitted.connect(func(_text): _on_rename_created_part_pressed())
	if tscn_list:
		tscn_list.item_selected.connect(_on_tscn_list_item_selected)
	
	_on_tab_changed(0) # initialize visibility

	# Part Mode connections
	btn_part_opaque.pressed.connect(func(): _set_selected_part_visual_state(VS_OPAQUE))
	btn_part_transparent.pressed.connect(func(): _set_selected_part_visual_state(VS_TRANSPARENT))
	btn_part_hidden.pressed.connect(func(): _set_selected_part_visual_state(VS_HIDDEN))

	if is_instance_valid(btn_copy_part):
		btn_copy_part.pressed.connect(_on_copy_part_pressed)
	if is_instance_valid(btn_delete_part):
		btn_delete_part.pressed.connect(_on_delete_part_pressed)
	if is_instance_valid(btn_undo_delete_part):
		btn_undo_delete_part.pressed.connect(_on_undo_delete_part_pressed)
	if is_instance_valid(btn_rename_part):
		btn_rename_part.pressed.connect(_on_rename_part_pressed)
	if is_instance_valid(line_edit_part_name):
		line_edit_part_name.text_submitted.connect(func(_text): _on_rename_part_pressed())
	if is_instance_valid(color_picker_part):
		color_picker_part.color_changed.connect(_on_part_color_changed)


	# Motion Configuration connections
	option_motion_type.item_selected.connect(_on_motion_type_selected)
	spin_motion_duration.value_changed.connect(_on_motion_param_changed)
	check_motion_ping_pong.toggled.connect(func(b):
		check_motion_ping_pong.text = "往復動作（あり）" if b else "往復動作（なし）"
		_on_motion_param_changed(0.0)
	)
	spin_motion_param_min.value_changed.connect(_on_motion_param_changed)
	spin_motion_param_max.value_changed.connect(_on_motion_param_changed)
	btn_axis_x.pressed.connect(func(): _cycle_axis_btn(btn_axis_x, "X"))
	btn_axis_y.pressed.connect(func(): _cycle_axis_btn(btn_axis_y, "Y"))
	btn_axis_z.pressed.connect(func(): _cycle_axis_btn(btn_axis_z, "Z"))
	
	btn_pick_pivot.toggled.connect(_on_pick_pivot_toggled)
	btn_pick_pivot.disabled = true

	for sp in [spin_pivot_x, spin_pivot_y, spin_pivot_z]:
		if is_instance_valid(sp):
			sp.min_value = -100.0
			sp.max_value = 100.0
			sp.step = 0.001
			sp.suffix = "m"
			sp.editable = false
			sp.value_changed.connect(_on_motion_param_changed)
			var le = sp.get_line_edit()
			if le:
				le.text_changed.connect(func(new_text: String):
					if _is_restoring_ui_state: return
					if new_text.is_valid_float():
						sp.set_value_no_signal(new_text.to_float())
						_on_motion_param_changed(0.0)
				)
				le.text_submitted.connect(func(new_text: String):
					if new_text.is_valid_float():
						sp.value = new_text.to_float()
					le.release_focus()
				)
	if spin_motion_param_min:
		spin_motion_param_min.min_value = -100000.0
		spin_motion_param_min.max_value = 100000.0
	if spin_motion_param_max:
		spin_motion_param_max.min_value = -100000.0
		spin_motion_param_max.max_value = 100000.0

	if is_instance_valid(btn_save_config):
		btn_save_config.pressed.connect(_on_save_config_pressed)
	if is_instance_valid(btn_rename_tscn):
		btn_rename_tscn.pressed.connect(_on_rename_tscn_pressed)
	if is_instance_valid(btn_delete_tscn):
		btn_delete_tscn.pressed.connect(_on_delete_tscn_pressed)
	if is_instance_valid(btn_load_config):
		btn_load_config.pressed.connect(_on_load_config_pressed)
	if is_instance_valid(option_load_config):
		option_load_config.pressed.connect(_update_load_options)

	_update_load_options()

	# Auto-load logic:
	# 1. Previous session's scene (e.g. sample.tscn)
	# 2. base.tscn if exists
	# 3. Any available .tscn in save_dir
	# 4. If nothing exists, create an empty base.tscn with ground and load it
	var auto_target = ""
	var last_scene = _get_last_scene_path()
	if last_scene != "" and FileAccess.file_exists(last_scene):
		auto_target = last_scene
	
	if auto_target.is_empty():
		var save_dir = _get_save_dir()
		var base_path = save_dir + "/base.tscn"
		if FileAccess.file_exists(base_path):
			auto_target = base_path
	
	if auto_target.is_empty():
		auto_target = _find_first_available_tscn()

	if auto_target.is_empty():
		var new_base_path = _get_save_dir() + "/base.tscn"
		if _create_empty_base_scene(new_base_path):
			auto_target = new_base_path
			_update_load_options()

	if not auto_target.is_empty():
		call_deferred("load_simulation_config", auto_target)

	_update_ui()
	call_deferred("_update_part_list")
	call_deferred("fit_view_to_all_parts")

func _setup_menu_minimize_controls() -> void:
	if not is_instance_valid(btn_minimize_menu):
		btn_minimize_menu = get_node_or_null("%BtnMinimizeMenu") as Button
	if not is_instance_valid(btn_restore_menu):
		btn_restore_menu = get_node_or_null("%BtnRestoreMenu") as Button

	# 動的フォールバック（シーンにない場合）
	if not is_instance_valid(btn_minimize_menu):
		var vbox = get_node_or_null("MarginContainer/ScrollContainer/VBoxOuter")
		if vbox:
			var orig_title = vbox.get_node_or_null("TitleLabel")
			var hbox = HBoxContainer.new()
			hbox.name = "TitleHBox"
			if orig_title:
				vbox.remove_child(orig_title)
				hbox.add_child(orig_title)
				orig_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_minimize_menu = Button.new()
			btn_minimize_menu.name = "BtnMinimizeMenu"
			btn_minimize_menu.text = "◀ 最小化"
			btn_minimize_menu.tooltip_text = "メニューを最小化 (M)"
			hbox.add_child(btn_minimize_menu)
			vbox.add_child(hbox)
			vbox.move_child(hbox, 0)

	if not is_instance_valid(btn_restore_menu):
		var ui_layer = get_node_or_null("/root/Main/UILayer")
		if ui_layer:
			btn_restore_menu = Button.new()
			btn_restore_menu.name = "BtnRestoreMenu"
			btn_restore_menu.text = "▶ メニュー表示"
			btn_restore_menu.tooltip_text = "メニューを展開 (M)"
			btn_restore_menu.offset_left = 12.0
			btn_restore_menu.offset_top = 12.0
			btn_restore_menu.offset_right = 142.0
			btn_restore_menu.offset_bottom = 44.0
			btn_restore_menu.visible = false
			ui_layer.add_child(btn_restore_menu)

	# 復元ボタンのスタイル設定
	if is_instance_valid(btn_restore_menu):
		var sb_norm = StyleBoxFlat.new()
		sb_norm.bg_color = Color(0.12, 0.14, 0.18, 0.9)
		sb_norm.border_width_left = 1
		sb_norm.border_width_top = 1
		sb_norm.border_width_right = 1
		sb_norm.border_width_bottom = 1
		sb_norm.border_color = Color(0.35, 0.45, 0.65, 0.8)
		sb_norm.corner_radius_top_left = 4
		sb_norm.corner_radius_top_right = 4
		sb_norm.corner_radius_bottom_left = 4
		sb_norm.corner_radius_bottom_right = 4
		sb_norm.content_margin_left = 10
		sb_norm.content_margin_right = 10
		sb_norm.content_margin_top = 6
		sb_norm.content_margin_bottom = 6

		var sb_hover = sb_norm.duplicate() as StyleBoxFlat
		sb_hover.bg_color = Color(0.20, 0.25, 0.35, 0.95)
		sb_hover.border_color = Color(0.5, 0.65, 0.9, 1.0)

		var sb_pressed = sb_norm.duplicate() as StyleBoxFlat
		sb_pressed.bg_color = Color(0.08, 0.10, 0.14, 0.95)

		btn_restore_menu.add_theme_stylebox_override("normal", sb_norm)
		btn_restore_menu.add_theme_stylebox_override("hover", sb_hover)
		btn_restore_menu.add_theme_stylebox_override("pressed", sb_pressed)
		btn_restore_menu.pressed.connect(func(): set_menu_minimized(false))

	# 最小化ボタンのスタイル設定
	if is_instance_valid(btn_minimize_menu):
		var sb_min_norm = StyleBoxFlat.new()
		sb_min_norm.bg_color = Color(0.18, 0.20, 0.25, 0.8)
		sb_min_norm.border_width_left = 1
		sb_min_norm.border_width_top = 1
		sb_min_norm.border_width_right = 1
		sb_min_norm.border_width_bottom = 1
		sb_min_norm.border_color = Color(0.3, 0.35, 0.45, 0.7)
		sb_min_norm.corner_radius_top_left = 4
		sb_min_norm.corner_radius_top_right = 4
		sb_min_norm.corner_radius_bottom_left = 4
		sb_min_norm.corner_radius_bottom_right = 4
		sb_min_norm.content_margin_left = 8
		sb_min_norm.content_margin_right = 8
		sb_min_norm.content_margin_top = 3
		sb_min_norm.content_margin_bottom = 3

		var sb_min_hover = sb_min_norm.duplicate() as StyleBoxFlat
		sb_min_hover.bg_color = Color(0.25, 0.28, 0.36, 0.9)
		sb_min_hover.border_color = Color(0.45, 0.55, 0.75, 0.9)

		btn_minimize_menu.add_theme_stylebox_override("normal", sb_min_norm)
		btn_minimize_menu.add_theme_stylebox_override("hover", sb_min_hover)
		btn_minimize_menu.pressed.connect(func(): set_menu_minimized(true))

func toggle_menu_minimized() -> void:
	set_menu_minimized(not is_minimized)

func set_menu_minimized(minimized: bool) -> void:
	if is_minimized == minimized:
		return
	is_minimized = minimized

	if _menu_tween and _menu_tween.is_running():
		_menu_tween.kill()

	_menu_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var panel_width = size.x if size.x > 0.0 else 340.0
	var target_x = -panel_width if is_minimized else 0.0
	_menu_tween.tween_property(self, "position:x", target_x, 0.2)

	if is_minimized:
		if is_instance_valid(btn_restore_menu):
			btn_restore_menu.visible = true
			btn_restore_menu.modulate.a = 0.0
			_menu_tween.tween_property(btn_restore_menu, "modulate:a", 1.0, 0.2)
	else:
		if is_instance_valid(btn_restore_menu):
			_menu_tween.tween_property(btn_restore_menu, "modulate:a", 0.0, 0.15)
			_menu_tween.chain().tween_callback(func():
				if not is_minimized and is_instance_valid(btn_restore_menu):
					btn_restore_menu.visible = false
			)

func _on_deselect_model_pressed() -> void:
	_cancel_pivot_picking()
	_set_selected_parts([])
	_sync_list_selection_from_parts()
	_mouse_selection_locked = false
	
	# 作成タブの選択状態もリセット
	selected_draft_index = -1
	selected_is_group = false
	selected_group_name = ""
	if is_instance_valid(created_part_list):
		created_part_list.deselect_all()
	_update_created_selection_label()
	_update_created_mesh_preview()
	_update_ui()

func _on_copy_part_pressed() -> void:
	if not is_instance_valid(selected_part) or not is_instance_valid(model_root):
		return
	var parent = selected_part.get_parent()
	if not parent:
		return
	var unique_name = AssemblyImporter.get_unique_name(parent, selected_part.name + "_copy")
	var copy = selected_part.duplicate(Node.DUPLICATE_USE_INSTANTIATION | Node.DUPLICATE_SIGNALS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS)
	copy.name = unique_name
	for child in copy.get_children():
		if child is MeshInstance3D:
			child.name = unique_name + "_mesh"
			break
	parent.add_child(copy)
	copy.set_meta("generated_by_importer", true)
	copy.set_meta("glb_original_transform", copy.transform)
	copy.set_meta("glb_original_position", copy.position)
	copy.set_meta("glb_original_rotation", copy.rotation_degrees)
	_sync_part_transform_meta(copy)
	
	_set_highlight(selected_part, false)
	selected_part = copy
	_set_highlight(selected_part, true)
	_sync_part_sliders(selected_part)
	_sync_motion_ui_from_selected_part()
	_update_part_list()
	_update_ui()
	_mark_modified()

func _find_draft_index_for_node(node: Node3D) -> int:
	"""作成タブのドラフトの中から、指定ノードに対応するものを探す。"""
	if not is_instance_valid(node):
		return -1
	for i in range(draft_parts.size()):
		var dn = draft_parts[i].get("node")
		if dn == node:
			return i
		if is_instance_valid(dn) and (node.is_ancestor_of(dn) or dn.is_ancestor_of(node)):
			return i
	# フォールバック: 名前での一致
	for i in range(draft_parts.size()):
		if draft_parts[i].get("name") == node.name:
			return i
	return -1


func _sync_created_state_on_part_removed(node: Node3D, permanently_freed: bool, is_root_call: bool = true) -> void:
	"""作業空間から作成タブ由来のパーツ／グループが削除された際、作成タブ側の状態を追従させる。
	permanently_freed が true の場合はノード参照が無効になるため draft の node を破棄する。"""
	if not is_instance_valid(node):
		return

	# 1. node 自体が作成パーツの場合
	if node.has_meta("is_created_part"):
		var idx = _find_draft_index_for_node(node)
		if idx != -1:
			draft_parts[idx]["inserted"] = false
			if permanently_freed:
				draft_parts[idx]["node"] = null

	# 2. node 自体が親グループの場合（配下の全パーツを未挿入に戻す。グループ自体の定義は作成タブで維持する）
	if node.has_meta("is_created_parent"):
		var g_name = node.name
		for draft in draft_parts:
			if draft.get("parent_name", "") == g_name:
				draft["inserted"] = false
				if permanently_freed:
					draft["node"] = null

	# 3. node の子孫ノードも再帰的に走査（グループ削除時に配下のパーツノードも確実に未挿入へ戻す）
	for child in node.get_children():
		if child is Node3D:
			_sync_created_state_on_part_removed(child, permanently_freed, false)

	# ルート呼び出し時のみUI・プレビューをまとめて更新
	if is_root_call:
		_update_created_part_list()
		_update_parent_options()
		_update_created_mesh_preview()
		_update_created_selection_label()
		_update_ui()


func _sync_created_state_on_part_restored(node: Node3D, is_root_call: bool = true) -> void:
	"""元に戻す操作で作成タブ由来のパーツ／グループが作業空間へ復元された際に、作成タブ側の状態も戻す。"""
	if not is_instance_valid(node):
		return

	# 1. node 自体が作成パーツの場合
	if node.has_meta("is_created_part"):
		var idx = _find_draft_index_for_node(node)
		if idx != -1:
			draft_parts[idx]["inserted"] = true
			draft_parts[idx]["node"] = node

	# 2. node 自体が親グループの場合
	if node.has_meta("is_created_parent"):
		var g_name = node.name
		if not created_parent_groups.has(g_name):
			created_parent_groups.append(g_name)
		for draft in draft_parts:
			if draft.get("parent_name", "") == g_name:
				draft["inserted"] = true
				var child_node = node.get_node_or_null(draft.get("name", ""))
				if child_node and child_node is Node3D:
					draft["node"] = child_node

	# 3. node の子孫ノードも再帰的に走査
	for child in node.get_children():
		if child is Node3D:
			_sync_created_state_on_part_restored(child, false)

	if is_root_call:
		_update_created_part_list()
		_update_parent_options()
		_update_created_mesh_preview()
		_update_created_selection_label()
		_update_ui()


func _on_delete_part_pressed() -> void:
	var targets = selected_parts if not selected_parts.is_empty() else ([selected_part] if selected_part else [])
	if targets.is_empty():
		return
	if is_instance_valid(last_deleted_part) and last_deleted_part.get_parent() == null:
		_sync_created_state_on_part_removed(last_deleted_part, true)
		last_deleted_part.queue_free()
		last_deleted_part = null
	
	if targets.size() == 1:
		var p = targets[0]
		last_deleted_part = p
		last_deleted_parent = p.get_parent()
		if p.name == "GroundPlane" or p.name == "GroundMesh":
			p.visible = false
			p.set_meta("is_deleted", true)
			_set_node_collision_enabled_recursive(p, false)
		else:
			if last_deleted_parent:
				last_deleted_index = last_deleted_parent.get_children().find(p)
				last_deleted_parent.remove_child(p)
			_sync_created_state_on_part_removed(p, false)
	else:
		for p in targets:
			if not is_instance_valid(p): continue
			if p.name == "GroundPlane" or p.name == "GroundMesh":
				p.visible = false
				p.set_meta("is_deleted", true)
				_set_node_collision_enabled_recursive(p, false)
			else:
				var par = p.get_parent()
				if par:
					par.remove_child(p)
					_sync_created_state_on_part_removed(p, true)
					p.queue_free()
	
	_set_selected_parts([])
	_update_part_list()
	_update_ui()
	_mark_modified()


func _on_undo_delete_part_pressed() -> void:
	if not is_instance_valid(last_deleted_part):
		return
	if last_deleted_part.name == "GroundPlane" or last_deleted_part.name == "GroundMesh":
		last_deleted_part.visible = true
		last_deleted_part.set_meta("is_deleted", false)
		last_deleted_part.set_meta("visual_state", VS_OPAQUE)
		_set_node_collision_enabled_recursive(last_deleted_part, true)
	elif is_instance_valid(last_deleted_parent):
		last_deleted_parent.add_child(last_deleted_part)
		if last_deleted_index >= 0 and last_deleted_index < last_deleted_parent.get_child_count():
			last_deleted_parent.move_child(last_deleted_part, last_deleted_index)
		_sync_created_state_on_part_restored(last_deleted_part)
	
	selected_part = last_deleted_part
	_set_highlight(selected_part, true)
	last_deleted_part = null
	last_deleted_parent = null
	last_deleted_index = -1
	
	_sync_part_sliders(selected_part)
	_sync_motion_ui_from_selected_part()
	_update_part_list()
	_update_ui()
	_mark_modified()

func _on_rename_part_pressed() -> void:
	if not is_instance_valid(selected_part) or not is_instance_valid(line_edit_part_name):
		return
	var new_name = line_edit_part_name.text.strip_edges()
	if new_name.is_empty() or new_name == selected_part.name:
		return
	selected_part.name = new_name
	for child in selected_part.get_children():
		if child is MeshInstance3D:
			child.name = new_name + "_mesh"
			break
	_update_part_list()
	_update_ui()
	_mark_modified()

func _on_part_color_changed(color: Color) -> void:
	if not is_instance_valid(selected_part):
		return
	_set_part_color_recursive(selected_part, color)
	_mark_modified()

func _set_part_color_recursive(node: Node, color: Color) -> void:
	if node is MeshInstance3D:
		var mesh_inst = node as MeshInstance3D
		if mesh_inst.mesh:
			for i in range(mesh_inst.mesh.get_surface_count()):
				var mat = mesh_inst.get_surface_override_material(i)
				if not mat:
					mat = mesh_inst.mesh.surface_get_material(i)
				var new_mat: StandardMaterial3D
				if mat is StandardMaterial3D:
					new_mat = mat.duplicate() as StandardMaterial3D
					new_mat.albedo_color = Color(color.r, color.g, color.b, new_mat.albedo_color.a)
				else:
					new_mat = StandardMaterial3D.new()
					new_mat.albedo_color = color
				mesh_inst.set_surface_override_material(i, new_mat)
	for child in node.get_children():
		_set_part_color_recursive(child, color)

func _get_part_primary_color(node: Node) -> Color:
	if node is MeshInstance3D:
		var mesh_inst = node as MeshInstance3D
		if mesh_inst.mesh:
			for i in range(mesh_inst.mesh.get_surface_count()):
				var mat = mesh_inst.get_surface_override_material(i)
				if not mat:
					mat = mesh_inst.mesh.surface_get_material(i)
				if mat is StandardMaterial3D or mat is BaseMaterial3D:
					return (mat as BaseMaterial3D).albedo_color
	for child in node.get_children():
		var col = _get_part_primary_color(child)
		if col != Color(0.8, 0.8, 0.8, 1.0):
			return col
	return Color(0.8, 0.8, 0.8, 1.0)

var _pivot_pick_mat: StandardMaterial3D = null

func _get_pivot_pick_mat() -> StandardMaterial3D:
	if not _pivot_pick_mat:
		_pivot_pick_mat = StandardMaterial3D.new()
		_pivot_pick_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_pivot_pick_mat.albedo_color = Color(0.4, 0.7, 1.0, 0.3)
		_pivot_pick_mat.roughness = 0.5
		_pivot_pick_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _pivot_pick_mat

func _apply_material_override_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		_apply_material_override_recursive(child, mat)

func _cancel_pivot_picking() -> void:
	if not is_picking_pivot and (not is_instance_valid(btn_pick_pivot) or not btn_pick_pivot.button_pressed):
		return
	is_picking_pivot = false
	if is_instance_valid(btn_pick_pivot):
		btn_pick_pivot.set_block_signals(true)
		btn_pick_pivot.button_pressed = false
		btn_pick_pivot.set_block_signals(false)
	if camera and camera.has_method("set_orthogonal_mode"):
		camera.set_orthogonal_mode(false)
	if is_instance_valid(model_root):
		for child in model_root.get_children():
			if child is Node3D and child.has_meta("generated_by_importer") and _has_mesh_recursive(child):
				var state = VS_OPAQUE
				if model_root.has_method("get_child_visual_state"):
					state = model_root.call("get_child_visual_state", child)
				if model_root.has_method("_apply_visual_state_recursive"):
					model_root.call("_apply_visual_state_recursive", child, state)
				else:
					_apply_material_override_recursive(child, null)
				child.visible = (state != VS_HIDDEN)

func _on_pick_pivot_toggled(toggled_on: bool) -> void:
	if not toggled_on or not selected_part:
		_cancel_pivot_picking()
		return

	is_picking_pivot = true
	
	if camera and camera.has_method("set_orthogonal_mode"):
		camera.set_orthogonal_mode(true)
		
	if is_instance_valid(model_root):
		var trans_mat = _get_pivot_pick_mat()
		for child in model_root.get_children():
			if child is Node3D and child.has_meta("generated_by_importer") and _has_mesh_recursive(child):
				if child != selected_part:
					_apply_material_override_recursive(child, trans_mat)
					child.visible = true

	if is_instance_valid(model_root) and camera and camera.has_method("focus_target_aabb"):
		var aabb = _get_node_aabb(model_root, true)
		camera.focus_target_aabb(aabb, 0.5)

	var vx = abs(_get_axis_val(btn_axis_x))
	var vy = abs(_get_axis_val(btn_axis_y))
	var vz = abs(_get_axis_val(btn_axis_z))
	if vx + vy + vz == 1.0:
		var axis = Vector3(_get_axis_val(btn_axis_x), _get_axis_val(btn_axis_y), _get_axis_val(btn_axis_z))
		if camera and camera.has_method("set_view_axis"):
			camera.set_view_axis(axis)
	else:
		# Not a single axis, so we shouldn't allow picking
		_cancel_pivot_picking()

func _set_selected_parts(parts: Array) -> void:
	for p in selected_parts:
		if is_instance_valid(p):
			_set_highlight(p, false)
	selected_parts.clear()
	
	for p in parts:
		if is_instance_valid(p) and not selected_parts.has(p):
			selected_parts.append(p)
			_set_highlight(p, true)
			
	if selected_parts.is_empty():
		selected_part = null
		_mouse_selection_locked = false
	else:
		selected_part = selected_parts[-1]
		
	_sync_part_sliders(selected_part)
	_sync_motion_ui_from_selected_part()
	_update_ui()

func _sync_list_selection_from_parts() -> void:
	if is_instance_valid(part_list) and part_list.visible:
		part_list.deselect_all()
		for i in range(part_list.item_count):
			var raw = part_list.get_item_metadata(i)
			if is_instance_valid(raw) and raw is Node3D:
				var p: Node3D = raw
				if selected_parts.has(p):
					part_list.select(i, false)
					part_list.ensure_current_is_visible()
	if is_instance_valid(created_part_list) and created_part_list.visible:
		created_part_list.deselect_all()
		for i in range(created_part_list.item_count):
			var meta = created_part_list.get_item_metadata(i)
			if meta is Dictionary:
				var is_sel = false
				if meta.get("is_group", false):
					var g_name = meta.get("name", "")
					if is_instance_valid(model_root):
						var g_node = model_root.get_node_or_null(g_name)
						if g_node and selected_parts.has(g_node):
							is_sel = true
				else:
					var d_idx = meta.get("index", -1) as int
					if d_idx >= 0 and d_idx < draft_parts.size():
						var d_node = draft_parts[d_idx].get("node") as Node3D
						if d_node and selected_parts.has(d_node):
							is_sel = true
				if is_sel:
					created_part_list.select(i, false)
					created_part_list.ensure_current_is_visible()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M and not event.ctrl_pressed and not event.alt_pressed:
			var focus_owner = get_viewport().gui_get_focus_owner()
			if not (focus_owner is LineEdit or focus_owner is TextEdit):
				toggle_menu_minimized()
				get_viewport().set_input_as_handled()
				return

	var current_tab_name = ""
	if tab_container and tab_container.get_child_count() > tab_container.current_tab:
		var cur_tab = tab_container.get_child(tab_container.current_tab)
		if cur_tab:
			current_tab_name = cur_tab.name

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_minimized:
			if is_instance_valid(btn_restore_menu) and btn_restore_menu.is_visible_in_tree():
				if btn_restore_menu.get_global_rect().has_point(event.position):
					return
		else:
			var panel_w = 340.0
			if is_instance_valid(tab_container):
				panel_w = maxf(panel_w, tab_container.global_position.x + tab_container.size.x)
			elif size.x > 0.0:
				panel_w = maxf(panel_w, size.x)
			if event.position.x < panel_w:
				return
		
		if current_tab_name == "ファイル":
			return
		
		if event.pressed:
			if Input.is_key_pressed(KEY_SHIFT):
				# 作成タブ：ドラフトパーツのドラッグ
				if current_tab_name == "作成":
					var draft_indices = _get_selected_draft_indices()
					
					# マウス位置にドラフトパーツがあるかレイキャスト
					var hit_result = _perform_raycast_full(event.position)
					var hit_draft_idx = -1
					if hit_result and hit_result.has("collider"):
						var col_node: Node = hit_result["collider"]
						while col_node and col_node != get_tree().root:
							if col_node.has_meta("draft_index"):
								hit_draft_idx = col_node.get_meta("draft_index") as int
								break
							col_node = col_node.get_parent()
					if hit_draft_idx == -1 and hit_result:
						var hit_part = _get_part_from_collider(hit_result.get("collider"))
						if hit_part and hit_part.has_meta("is_created_part"):
							for i in range(draft_parts.size()):
								var d = draft_parts[i]
								if d.get("node") == hit_part or (is_instance_valid(d.get("node")) and (hit_part.is_ancestor_of(d["node"]) or d["node"].is_ancestor_of(hit_part))):
									hit_draft_idx = i
									break
					
					# ヒットしたパーツがあり、現在の選択に含まれていなければそれを選択
					if hit_draft_idx >= 0 and not draft_indices.has(hit_draft_idx):
						var found_item = -1
						if is_instance_valid(created_part_list):
							for i in range(created_part_list.item_count):
								var m = created_part_list.get_item_metadata(i)
								if m is Dictionary and not m.get("is_group", false) and m.get("index", -1) == hit_draft_idx:
									found_item = i
									break
						if found_item != -1:
							created_part_list.deselect_all()
							created_part_list.select(found_item)
							_on_created_part_list_item_selected(found_item)
						else:
							selected_draft_index = hit_draft_idx
							selected_is_group = false
							_update_created_selection_label()
							_update_created_mesh_preview()
						draft_indices = _get_selected_draft_indices()
					
					if not draft_indices.is_empty():
						var ref_idx = selected_draft_index if (selected_draft_index >= 0 and selected_draft_index < draft_parts.size()) else draft_indices[0]
						var ref_pos: Vector3 = draft_parts[ref_idx].get("position", Vector3.ZERO)
						
						var cam_forward = -camera.global_transform.basis.z.normalized()
						_drag_plane = Plane(cam_forward, ref_pos)
						
						var from = camera.project_ray_origin(event.position)
						var intersection = _drag_plane.intersects_ray(from, camera.project_ray_normal(event.position))
						if intersection != null:
							_is_dragging_draft = true
							_draft_drag_start_intersection = intersection
							_draft_drag_start_positions.clear()
							for di in draft_indices:
								if di < draft_parts.size():
									_draft_drag_start_positions[di] = draft_parts[di].get("position", Vector3.ZERO)
						
						get_viewport().set_input_as_handled()
						return
				
				# 配置タブ等の場合
				elif selected_part:
					_is_dragging_part = true
					var cam_forward = -camera.global_transform.basis.z.normalized()
					_drag_plane = Plane(cam_forward, selected_part.global_position)
					
					var from = camera.project_ray_origin(event.position)
					var intersection = _drag_plane.intersects_ray(from, camera.project_ray_normal(event.position))
					if intersection != null:
						_drag_start_intersection = intersection
						_drag_start_part_pos = selected_part.global_position
						_drag_start_all_pos.clear()
						var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
						for p in targets:
							if is_instance_valid(p):
								_drag_start_all_pos[p] = p.global_position
					
					get_viewport().set_input_as_handled()
					return

			# Perform raycast
			var hit_result = _perform_raycast_full(event.position)
			var hit_part = _get_part_from_collider(hit_result.get("collider")) if hit_result else null
			
			if is_picking_pivot:
				if hit_result and hit_result.has("position") and selected_part:
					var hit_world = hit_result["position"]
					var parent_node = selected_part.get_parent() as Node3D
					var hit_parent = parent_node.to_local(hit_world) if parent_node else hit_world
					spin_pivot_x.value = hit_parent.x
					spin_pivot_y.value = hit_parent.y
					spin_pivot_z.value = hit_parent.z
					btn_pick_pivot.button_pressed = false
				return

			if current_tab_name == "作成":
				# ロック中は他の選択操作を一切受け付けない
				if _mouse_selection_locked:
					get_viewport().set_input_as_handled()
					return

				var picked_draft_idx = -1
				var picked_group_name = ""

				# Check if collider belongs to a draft preview
				if hit_result and hit_result.has("collider"):
					var col_node: Node = hit_result["collider"]
					while col_node and col_node != get_tree().root:
						if col_node.has_meta("draft_index"):
							picked_draft_idx = col_node.get_meta("draft_index") as int
							break
						col_node = col_node.get_parent()

				# If not draft preview, check if hit_part is an inserted draft or created group
				if picked_draft_idx == -1 and hit_part:
					if hit_part.has_meta("is_created_parent"):
						picked_group_name = hit_part.name
					elif hit_part.has_meta("is_created_part"):
						for i in range(draft_parts.size()):
							var d = draft_parts[i]
							if d.get("node") == hit_part:
								picked_draft_idx = i
								break
							if d.get("node") and is_instance_valid(d["node"]) and (hit_part.is_ancestor_of(d["node"]) or d["node"].is_ancestor_of(hit_part)):
								picked_draft_idx = i
								break
						if picked_draft_idx == -1 and hit_part.get_parent() and hit_part.get_parent().has_meta("is_created_parent"):
							picked_group_name = hit_part.get_parent().name

				if picked_draft_idx != -1:
					var found_item = -1
					if is_instance_valid(created_part_list):
						for i in range(created_part_list.item_count):
							var m = created_part_list.get_item_metadata(i)
							if m is Dictionary and not m.get("is_group", false) and m.get("index", -1) == picked_draft_idx:
								found_item = i
								break
					if found_item != -1:
						created_part_list.deselect_all()
						created_part_list.select(found_item)
						created_part_list.ensure_current_is_visible()
						_on_created_part_list_item_selected(found_item)
					else:
						selected_draft_index = picked_draft_idx
						selected_is_group = false
						_update_created_selection_label()
						_update_created_mesh_preview()
					_mouse_selection_locked = true
					_update_ui()
				elif not picked_group_name.is_empty():
					var found_item = -1
					if is_instance_valid(created_part_list):
						for i in range(created_part_list.item_count):
							var m = created_part_list.get_item_metadata(i)
							if m is Dictionary and m.get("is_group", false) and m.get("name", "") == picked_group_name:
								found_item = i
								break
					if found_item != -1:
						created_part_list.deselect_all()
						created_part_list.select(found_item)
						created_part_list.ensure_current_is_visible()
						_on_created_part_list_item_selected(found_item)
					_mouse_selection_locked = true
					_update_ui()
				elif hit_part and hit_part.name != "GroundPlane" and hit_part.name != "GroundMesh":
					# 既存モデルは作成タブの操作対象外なので選択しない（クリックを無視）
					pass
				else:
					# 空白や地面をクリックした場合は作成タブの選択を解除
					if not Input.is_key_pressed(KEY_CTRL) and not Input.is_key_pressed(KEY_SHIFT):
						selected_draft_index = -1
						selected_is_group = false
						selected_group_name = ""
						if is_instance_valid(created_part_list):
							created_part_list.deselect_all()
						_set_selected_parts([])
						_update_created_selection_label()
						_update_created_mesh_preview()
						_mouse_selection_locked = false
						_update_ui()
			else:
				# Placement or Motion tab
				if _mouse_selection_locked:
					get_viewport().set_input_as_handled()
					return

				if hit_part and hit_part.name != "GroundPlane" and hit_part.name != "GroundMesh":
					_set_selected_parts([hit_part])
					_sync_list_selection_from_parts()
					_mouse_selection_locked = true
					_update_ui()
				else:
					if not Input.is_key_pressed(KEY_CTRL) and not Input.is_key_pressed(KEY_SHIFT):
						_set_selected_parts([])
						_sync_list_selection_from_parts()
						_mouse_selection_locked = false
						_update_ui()
		else:
			if _is_dragging_draft:
				_is_dragging_draft = false
				# ドラッグ終了後はスピンボックスに反映
				if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
					var d = draft_parts[selected_draft_index]
					var dp: Vector3 = d.get("position", Vector3.ZERO)
					_set_creation_controls_blocked(true)
					if spin_create_pos_x: spin_create_pos_x.value = dp.x
					if spin_create_pos_y: spin_create_pos_y.value = dp.y
					if spin_create_pos_z: spin_create_pos_z.value = dp.z
					_set_creation_controls_blocked(false)
				_draft_drag_start_positions.clear()
				_update_created_mesh_preview()
				_mark_modified()
				get_viewport().set_input_as_handled()
				return
			if _is_dragging_part:
				_is_dragging_part = false
				for p in _drag_start_all_pos.keys():
					if is_instance_valid(p):
						_sync_part_transform_meta(p)
				if current_tab_name == "作成" and selected_part and selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
					draft_parts[selected_draft_index]["position"] = selected_part.position
					_set_creation_controls_blocked(true)
					if spin_create_pos_x: spin_create_pos_x.value = selected_part.position.x
					if spin_create_pos_y: spin_create_pos_y.value = selected_part.position.y
					if spin_create_pos_z: spin_create_pos_z.value = selected_part.position.z
					_set_creation_controls_blocked(false)
				_drag_start_all_pos.clear()
				_mark_modified()
				get_viewport().set_input_as_handled()
				return

	elif event is InputEventMouseMotion:
		# 作成タブドラフトドラッグ
		if _is_dragging_draft:
			var from = camera.project_ray_origin(event.position)
			var intersection = _drag_plane.intersects_ray(from, camera.project_ray_normal(event.position))
			if intersection != null:
				var drag_delta = intersection - _draft_drag_start_intersection
				# 全選択ドラフトの位置を更新
				for di in _draft_drag_start_positions.keys():
					if di < draft_parts.size():
						var new_pos: Vector3 = _draft_drag_start_positions[di] + drag_delta
						draft_parts[di]["position"] = new_pos
						# 挿入済みノード / 未挿入プレビューノードに即時反映
						var d = draft_parts[di]
						if d.get("inserted", false) and is_instance_valid(d.get("node")):
							(d["node"] as Node3D).position = new_pos
						else:
							var prev_node = _get_draft_preview_node(di)
							if is_instance_valid(prev_node):
								prev_node.position = new_pos
				# 主選択の位置をスピンボックスに反映
				if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
					var dp: Vector3 = draft_parts[selected_draft_index].get("position", Vector3.ZERO)
					_set_creation_controls_blocked(true)
					if spin_create_pos_x: spin_create_pos_x.value = dp.x
					if spin_create_pos_y: spin_create_pos_y.value = dp.y
					if spin_create_pos_z: spin_create_pos_z.value = dp.z
					_set_creation_controls_blocked(false)
			get_viewport().set_input_as_handled()
			return
		# 配置タブノードドラッグ
		if _is_dragging_part and selected_part:
			var from = camera.project_ray_origin(event.position)
			var intersection = _drag_plane.intersects_ray(from, camera.project_ray_normal(event.position))
			if intersection != null:
				var drag_delta = intersection - _drag_start_intersection
				var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
				for p in targets:
					if is_instance_valid(p) and _drag_start_all_pos.has(p):
						p.global_position = _drag_start_all_pos[p] + drag_delta
						_sync_part_transform_meta(p)
				
				_block_transform_signals(true)
				_sync_part_sliders(selected_part)
				_block_transform_signals(false)

				if current_tab_name == "作成" and selected_part and selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
					_set_creation_controls_blocked(true)
					if spin_create_pos_x: spin_create_pos_x.value = selected_part.position.x
					if spin_create_pos_y: spin_create_pos_y.value = selected_part.position.y
					if spin_create_pos_z: spin_create_pos_z.value = selected_part.position.z
					_set_creation_controls_blocked(false)
				
			get_viewport().set_input_as_handled()
			return


func _confirm_running_action(on_confirm: Callable, on_cancel: Callable = Callable()) -> void:
	if _is_restoring_ui_state:
		return

	if SimulationManager.state == SimulationManager.State.RUNNING:
		_pending_confirm_callback = on_confirm
		_pending_cancel_callback = on_cancel

		if not is_instance_valid(_running_confirm_dialog):
			_running_confirm_dialog = ConfirmationDialog.new()
			_running_confirm_dialog.title = "動作中の変更確認"
			_running_confirm_dialog.dialog_text = "動作中のため一度初期状態に戻してから変更を適用します。\nよろしいですか？"
			_running_confirm_dialog.get_ok_button().text = "はい"
			_running_confirm_dialog.get_cancel_button().text = "いいえ"
			_running_confirm_dialog.confirmed.connect(func():
				SimulationManager.reset_simulation()
				if _pending_confirm_callback.is_valid():
					_pending_confirm_callback.call()
					_mark_modified()
			)
			_running_confirm_dialog.canceled.connect(func():
				if _pending_cancel_callback.is_valid():
					_pending_cancel_callback.call()
			)
			add_child(_running_confirm_dialog)

		if not _running_confirm_dialog.visible:
			_running_confirm_dialog.popup_centered()
	else:
		if on_confirm.is_valid():
			on_confirm.call()
			_mark_modified()

func _set_highlight(part: Node3D, enable: bool) -> void:
	if not part: return
	_apply_overlay_recursive(part, highlight_material if enable else null)

func _apply_overlay_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_overlay = mat
	for child in node.get_children():
		_apply_overlay_recursive(child, mat)

func _apply_transparent_override_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D and node.mesh:
		for i in range(node.mesh.get_surface_count()):
			node.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_transparent_override_recursive(child, mat)

func _collect_collision_rids_recursive(node: Node, out_rids: Array[RID]) -> void:
	if not is_instance_valid(node):
		return
	if node is CollisionObject3D:
		out_rids.append((node as CollisionObject3D).get_rid())
	for child in node.get_children():
		_collect_collision_rids_recursive(child, out_rids)

func _perform_raycast_full(mouse_pos: Vector2) -> Dictionary:
	if not camera:
		return {}
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)

	# 作成タブ以外では、ドラフトプレビューコンテナのコライダーを物理レイキャストから完全に除外する
	var cur_tab_name = ""
	if is_instance_valid(tab_container) and tab_container.get_child_count() > tab_container.current_tab:
		var cur_t = tab_container.get_child(tab_container.current_tab)
		if cur_t: cur_tab_name = cur_t.name
	if cur_tab_name != "作成" and is_instance_valid(draft_preview_container):
		var excludes: Array[RID] = []
		_collect_collision_rids_recursive(draft_preview_container, excludes)
		query.exclude = excludes

	return space_state.intersect_ray(query)

func _get_part_from_collider(collider: Node) -> Node3D:
	var curr: Node = collider
	var cur_tab_name = ""
	if is_instance_valid(tab_container) and tab_container.get_child_count() > tab_container.current_tab:
		var cur_t = tab_container.get_child(tab_container.current_tab)
		if cur_t: cur_tab_name = cur_t.name

	while curr and curr != get_tree().root:
		if curr is Node3D:
			if (curr.name == "GroundPlane" or curr.name == "GroundMesh") and curr.visible:
				var p = curr if curr.name == "GroundPlane" else curr.get_parent()
				if p is Node3D: return p as Node3D
			if curr.has_meta("is_draft_preview"):
				if cur_tab_name == "作成":
					return curr as Node3D
				return null
			if curr.get_parent() == model_root:
				return curr as Node3D
			if curr.has_meta("generated_by_importer") or curr.has_meta("is_created_part"):
				var p_node = curr
				while p_node.get_parent() and p_node.get_parent() != model_root and p_node.get_parent() != get_tree().root:
					p_node = p_node.get_parent()
				if p_node.get_parent() == model_root:
					return p_node as Node3D
				return curr as Node3D
		curr = curr.get_parent()
	return null

func _ensure_collision_bodies_recursive(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if node is MeshInstance3D and node.mesh:
		var has_trimesh = false
		var convex_bodies: Array[StaticBody3D] = []
		for c in node.get_children():
			if c is StaticBody3D:
				var is_convex = false
				for sc in c.get_children():
					if sc is CollisionShape3D and sc.shape is ConvexPolygonShape3D:
						is_convex = true
						break
				if is_convex:
					convex_bodies.append(c)
				else:
					has_trimesh = true
		if not has_trimesh:
			for cb in convex_bodies:
				cb.free()
			node.create_trimesh_collision()
	for child in node.get_children():
		_ensure_collision_bodies_recursive(child)

func _perform_raycast(mouse_pos: Vector2) -> Node3D:
	var result = _perform_raycast_full(mouse_pos)
	if result and result.has("collider"):
		return _get_part_from_collider(result["collider"])
	return null

## パーツの Transform を全系統（node.transform, metadata, ModelBehavior, initial_transforms辞書）へ完全同期する
func _sync_part_transform_meta(part: Node3D) -> void:
	if not is_instance_valid(part):
		return
	part.set_meta("initial_transform", part.transform)
	part.set_meta("initial_position", part.position)
	part.set_meta("initial_rotation", part.rotation_degrees)
	
	var behavior = _get_part_behavior(part)
	if behavior:
		behavior._initial_parent_transform = part.transform
		
	if is_instance_valid(model_root) and ("initial_transforms" in model_root) and model_root.initial_transforms is Dictionary:
		model_root.initial_transforms[part.name] = part.transform

func _get_original_position(node: Node3D) -> Vector3:
	if is_instance_valid(node):
		if node.has_meta("glb_original_position"):
			return node.get_meta("glb_original_position")
		if node.has_meta("glb_original_transform"):
			return (node.get_meta("glb_original_transform") as Transform3D).origin
	if is_instance_valid(model_root) and model_root.has_method("get_original_transform"):
		return model_root.call("get_original_transform", node).origin
	if is_instance_valid(node) and node.has_meta("initial_position"):
		return node.get_meta("initial_position")
	return Vector3.ZERO

func _get_original_rotation(node: Node3D) -> Vector3:
	if is_instance_valid(node):
		if node.has_meta("glb_original_rotation"):
			return node.get_meta("glb_original_rotation")
		if node.has_meta("glb_original_transform"):
			return (node.get_meta("glb_original_transform") as Transform3D).basis.get_euler() * (180.0 / PI)
	if is_instance_valid(model_root) and model_root.has_method("get_original_rotation_deg"):
		return model_root.call("get_original_rotation_deg", node)
	if is_instance_valid(node) and node.has_meta("initial_rotation"):
		return node.get_meta("initial_rotation")
	return Vector3.ZERO

func _on_play_pressed() -> void:
	SimulationManager.start_simulation()
	_update_ui()

func _on_pause_pressed() -> void:
	SimulationManager.pause_simulation()
	_update_ui()

func _on_simulation_reset_pressed() -> void:
	SimulationManager.reset_simulation()
	_update_ui()

## 作成タブにパーツが存在するか判定（挿入済み・未挿入を問わず）
func _has_any_draft_parts() -> bool:
	return not draft_parts.is_empty()

## オールリセットの実際の処理（確認後に呼ぶ）
func _do_all_reset() -> void:
	_set_highlight(selected_part, false)
	selected_part = null
	selected_parts.clear()
	SimulationManager.reset_simulation()

	var glb_path: String = ""
	if is_instance_valid(model_root) and model_root.get("glb_file") != null:
		glb_path = str(model_root.get("glb_file"))

	var target_tscn = _current_tscn_path
	if target_tscn == "" and _last_loaded_scene_path != "" and FileAccess.file_exists(_last_loaded_scene_path):
		target_tscn = _last_loaded_scene_path

	if target_tscn != "" and FileAccess.file_exists(target_tscn):
		# TSCN起点：TSCNを再ロードして開始時点に戻す
		load_simulation_config(target_tscn)
	elif glb_path != "" and FileAccess.file_exists(glb_path) and is_instance_valid(model_root) and model_root.has_method("_unpack"):
		# GLB起点：GLBを再展開して開始時点に戻す
		model_root.call("_unpack")
		_reset_workspace_state(false)
		
		# 開いたときに地面があった場合は戻す
		if _opened_ground_visible:
			var gy = _opened_ground_y
			if gy == 0.0:
				var model_aabb = _get_node_aabb(model_root, true)
				if model_aabb.size != Vector3.ZERO:
					gy = model_aabb.position.y
			set_ground_visible(true, gy)
		else:
			set_ground_visible(false)

		await get_tree().process_frame
		fit_view_to_all_parts()
		_update_part_list()
		_update_ui()
	else:
		# フォールバック：パーツのtransformをglb_original_transformに戻す
		if is_instance_valid(model_root):
			_reset_all_parts_recursive(model_root)
		# 開いたときに地面があった場合は戻す
		if _opened_ground_visible:
			set_ground_visible(true, _opened_ground_y)
		else:
			set_ground_visible(false)
		_was_just_cleared = false
		if camera:
			camera.reset_view()
			fit_view_to_all_parts()
		_update_part_list()
		_update_ui()

func _on_all_reset_pressed() -> void:
	# 作成タブにパーツが1つでもある場合は警告ダイアログを表示
	if _has_any_draft_parts():
		if not is_instance_valid(_all_reset_confirm_dialog):
			_all_reset_confirm_dialog = ConfirmationDialog.new()
			_all_reset_confirm_dialog.title = "オールリセットの確認"
			_all_reset_confirm_dialog.get_ok_button().text = "リセットする"
			_all_reset_confirm_dialog.get_cancel_button().text = "キャンセル"
			_all_reset_confirm_dialog.confirmed.connect(func(): _do_all_reset())
			add_child(_all_reset_confirm_dialog)

		# 挿入済み・未挿入に分けてパーツ名を列挙
		var inserted_names: Array[String] = []
		var not_inserted_names: Array[String] = []
		for draft in draft_parts:
			var n = draft.get("name", "?")
			if draft.get("inserted", false):
				inserted_names.append(n)
			else:
				not_inserted_names.append(n)

		var msg = "オールリセットを実行すると、開始時点の状態に戻ります。\n作成タブのパーツはすべて消えます。\n\n"
		if not inserted_names.is_empty():
			msg += "● 作業空間に挿入済み（削除されます）:\n　" + ", ".join(inserted_names) + "\n\n"
		if not not_inserted_names.is_empty():
			msg += "● 未挿入（リストから消えます）:\n　" + ", ".join(not_inserted_names) + "\n\n"
		msg += "続行しますか？"

		_all_reset_confirm_dialog.dialog_text = msg
		_all_reset_confirm_dialog.popup_centered()
		return

	_do_all_reset()

func _reset_all_parts_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is Node3D:
			var n3d := child as Node3D
			if n3d.has_meta("glb_original_transform"):
				n3d.transform = n3d.get_meta("glb_original_transform")
			elif n3d.has_meta("initial_transform"):
				n3d.transform = n3d.get_meta("initial_transform")
			else:
				var orig_pos = _get_original_position(n3d)
				var orig_rot = _get_original_rotation(n3d)
				n3d.position = orig_pos
				n3d.rotation_degrees = orig_rot
			# glb_original_transform へ戻した後、initial_transform と各メタを同期する
			# （_sync_part_transform_meta は initial_transform を現在値で上書きするため使わない）
			n3d.set_meta("initial_transform", n3d.transform)
			n3d.set_meta("initial_position", n3d.position)
			n3d.set_meta("initial_rotation", n3d.rotation_degrees)
			if is_instance_valid(model_root) and ("initial_transforms" in model_root) and model_root.initial_transforms is Dictionary:
				model_root.initial_transforms[n3d.name] = n3d.transform
			var behavior = _get_part_behavior(n3d)
			if behavior:
				behavior._initial_parent_transform = n3d.transform
				behavior.reset()
			_reset_all_parts_recursive(child)

func _set_selected_part_visual_state(state: int) -> void:
	var targets: Array[Node3D] = []
	if not selected_parts.is_empty():
		targets = selected_parts
	elif selected_part:
		targets = [selected_part]

	if not targets.is_empty():
		var apply_action = func():
			for p in targets:
				if not is_instance_valid(p): continue
				if is_instance_valid(model_root) and model_root.has_method("set_child_visual_state"):
					model_root.call("set_child_visual_state", p, state)
				else:
					p.visible = (state != VS_HIDDEN)
				p.set_meta("visual_state", state)
				if p.name == "GroundPlane" or p.name == "GroundMesh":
					p.visible = (state != VS_HIDDEN)
					p.set_meta("is_deleted", false)
					_set_node_collision_enabled_recursive(p, state != VS_HIDDEN)
			_update_part_list()
			_update_ui()
		_confirm_running_action(apply_action)

var _blocking_transform_signals: bool = false

func _block_transform_signals(blocked: bool) -> void:
	_blocking_transform_signals = blocked
	if spin_part_pos_x: spin_part_pos_x.set_block_signals(blocked)
	if spin_part_pos_y: spin_part_pos_y.set_block_signals(blocked)
	if spin_part_pos_z: spin_part_pos_z.set_block_signals(blocked)

	if spin_part_rot_x: spin_part_rot_x.set_block_signals(blocked)
	if spin_part_rot_y: spin_part_rot_y.set_block_signals(blocked)
	if spin_part_rot_z: spin_part_rot_z.set_block_signals(blocked)

	if spin_part_scale_x: spin_part_scale_x.set_block_signals(blocked)
	if spin_part_scale_y: spin_part_scale_y.set_block_signals(blocked)
	if spin_part_scale_z: spin_part_scale_z.set_block_signals(blocked)

func _sync_part_sliders(part: Node3D) -> void:
	if not is_instance_valid(part):
		return

	_block_transform_signals(true)

	if spin_part_pos_x: spin_part_pos_x.value = part.position.x
	if spin_part_pos_y: spin_part_pos_y.value = part.position.y
	if spin_part_pos_z: spin_part_pos_z.value = part.position.z
	_last_synced_position = part.position

	if spin_part_rot_x: spin_part_rot_x.value = part.rotation_degrees.x
	if spin_part_rot_y: spin_part_rot_y.value = part.rotation_degrees.y
	if spin_part_rot_z: spin_part_rot_z.value = part.rotation_degrees.z

	if spin_part_scale_x: spin_part_scale_x.value = part.scale.x
	if spin_part_scale_y: spin_part_scale_y.value = part.scale.y
	if spin_part_scale_z: spin_part_scale_z.value = part.scale.z

	if is_instance_valid(line_edit_part_name):
		line_edit_part_name.text = part.name
	if is_instance_valid(color_picker_part):
		color_picker_part.set_block_signals(true)
		color_picker_part.color = _get_part_primary_color(part)
		color_picker_part.set_block_signals(false)

	_block_transform_signals(false)

func _on_part_position_spinbox_changed(_val: float) -> void:
	if _blocking_transform_signals or not selected_part: return
	var new_pos = Vector3(spin_part_pos_x.value, spin_part_pos_y.value, spin_part_pos_z.value)
	var delta = new_pos - _last_synced_position
	_last_synced_position = new_pos

	var apply_action = func():
		var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
		for p in targets:
			if not is_instance_valid(p): continue
			if p == selected_part:
				p.position = new_pos
			else:
				p.position += delta
			_sync_part_transform_meta(p)
		_mark_modified()
		_update_ui()

	var cancel_action = func():
		_is_restoring_ui_state = true
		_sync_part_sliders(selected_part)
		_is_restoring_ui_state = false

	_confirm_running_action(apply_action, cancel_action)

func _on_part_rotation_spinbox_changed(_val: float) -> void:
	if _blocking_transform_signals or not selected_part: return
	var new_rot = Vector3(spin_part_rot_x.value, spin_part_rot_y.value, spin_part_rot_z.value)
	var delta_rot = new_rot - selected_part.rotation_degrees

	var apply_action = func():
		var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
		for p in targets:
			if not is_instance_valid(p): continue
			if p == selected_part:
				p.rotation_degrees = new_rot
			else:
				p.rotation_degrees += delta_rot
			_sync_part_transform_meta(p)
		_mark_modified()
		_update_ui()

	var cancel_action = func():
		_is_restoring_ui_state = true
		_sync_part_sliders(selected_part)
		_is_restoring_ui_state = false

	_confirm_running_action(apply_action, cancel_action)

func _on_part_scale_spinbox_changed(changed_spin: SpinBox, new_val: float) -> void:
	if _blocking_transform_signals or _updating_scale_spinboxes or not selected_part: return
	
	if btn_link_part_scale and btn_link_part_scale.button_pressed:
		_updating_scale_spinboxes = true
		if spin_part_scale_x and spin_part_scale_x != changed_spin: spin_part_scale_x.value = new_val
		if spin_part_scale_y and spin_part_scale_y != changed_spin: spin_part_scale_y.value = new_val
		if spin_part_scale_z and spin_part_scale_z != changed_spin: spin_part_scale_z.value = new_val
		_updating_scale_spinboxes = false

	var new_scale = Vector3(spin_part_scale_x.value, spin_part_scale_y.value, spin_part_scale_z.value)

	var apply_action = func():
		var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
		for p in targets:
			if not is_instance_valid(p): continue
			p.scale = new_scale
			_sync_part_transform_meta(p)
		_mark_modified()
		_update_ui()

	var cancel_action = func():
		_is_restoring_ui_state = true
		_sync_part_sliders(selected_part)
		_is_restoring_ui_state = false

	_confirm_running_action(apply_action, cancel_action)

func _on_reset_part_pos_clicked() -> void:
	if not selected_part: return
	var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
	for p in targets:
		if is_instance_valid(p):
			var orig_pos = _get_original_position(p)
			p.position = orig_pos
			_sync_part_transform_meta(p)
	_sync_part_sliders(selected_part)
	_mark_modified()
	_update_ui()

func _on_reset_part_rot_clicked() -> void:
	if not selected_part: return
	var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
	for p in targets:
		if is_instance_valid(p):
			var orig_rot = _get_original_rotation(p)
			p.rotation_degrees = orig_rot
			_sync_part_transform_meta(p)
	_sync_part_sliders(selected_part)
	_mark_modified()
	_update_ui()

func _on_reset_part_scale_clicked() -> void:
	if not selected_part: return
	var targets = selected_parts if not selected_parts.is_empty() else [selected_part]
	for p in targets:
		if is_instance_valid(p):
			p.scale = Vector3.ONE
			_sync_part_transform_meta(p)
	_sync_part_sliders(selected_part)
	_mark_modified()
	_update_ui()

func _on_reset_create_pos_clicked() -> void:
	var init_p = Vector3.ZERO
	if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
		init_p = draft_parts[selected_draft_index].get("initial_position", Vector3.ZERO)
	_set_creation_controls_blocked(true)
	if spin_create_pos_x: spin_create_pos_x.value = init_p.x
	if spin_create_pos_y: spin_create_pos_y.value = init_p.y
	if spin_create_pos_z: spin_create_pos_z.value = init_p.z
	_set_creation_controls_blocked(false)
	_on_create_param_changed()

func _on_reset_create_rot_clicked() -> void:
	_set_creation_controls_blocked(true)
	if spin_create_rot_x: spin_create_rot_x.value = 0.0
	if spin_create_rot_y: spin_create_rot_y.value = 0.0
	if spin_create_rot_z: spin_create_rot_z.value = 0.0
	_set_creation_controls_blocked(false)
	_on_create_param_changed()

func _on_reset_create_scale_clicked() -> void:
	_set_creation_controls_blocked(true)
	if spin_create_scale_x: spin_create_scale_x.value = 1.0
	if spin_create_scale_y: spin_create_scale_y.value = 1.0
	if spin_create_scale_z: spin_create_scale_z.value = 1.0
	_set_creation_controls_blocked(false)
	_on_create_param_changed()


func _on_reset_selected_part_motion_pressed() -> void:
	if selected_part:
		apply_motion_to_part(selected_part, "none", {})
		_sync_motion_ui_from_selected_part()
	_update_ui()


# ── File Dialog model import logic ───────────────────────────────────────────

func _on_load_model_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.title = "インポートするGLBモデルを選択"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = PackedStringArray(["*.glb ; GLB 3D Model", "*.gltf ; GLTF 3D Model"])
	dialog.min_size = Vector2i(750, 500)
	
	dialog.file_selected.connect(func(path):
		dialog.hide()
		dialog.queue_free()
		_on_load_model_file_selected.call_deferred(path)
	)
	dialog.canceled.connect(func():
		dialog.hide()
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()

func _on_load_model_file_selected(absolute_path: String) -> void:
	if absolute_path.strip_edges() == "":
		return

	var ask_dialog = ConfirmationDialog.new()
	ask_dialog.title = "地面の配置選択"
	ask_dialog.dialog_text = "3Dモデルを読み込みます。\nモデルの直下に地面（GroundPlane）を配置しますか？"
	ask_dialog.ok_button_text = "はい（地面あり）"
	ask_dialog.cancel_button_text = "いいえ（地面なし）"
	ask_dialog.min_size = Vector2i(360, 140)
	ask_dialog.exclusive = true
	add_child(ask_dialog)
	ask_dialog.popup_centered()

	ask_dialog.confirmed.connect(func():
		ask_dialog.hide()
		ask_dialog.queue_free()
		_process_load_model.call_deferred(absolute_path, true)
	)
	ask_dialog.canceled.connect(func():
		ask_dialog.hide()
		ask_dialog.queue_free()
		_process_load_model.call_deferred(absolute_path, false)
	)

func _process_load_model(absolute_path: String, with_ground: bool) -> void:
	# 読み込み中ダイアログを表示
	var loading_dialog = AcceptDialog.new()
	loading_dialog.title = "読み込み中"
	loading_dialog.dialog_text = "3Dモデルを読み込んでいます...\nしばらくお待ちください。"
	loading_dialog.min_size = Vector2i(320, 120)
	loading_dialog.exclusive = true
	add_child(loading_dialog)
	loading_dialog.popup_centered()
	var ok_btn = loading_dialog.get_ok_button()
	if ok_btn:
		ok_btn.visible = false

	# ダイアログが描画されるのを待つ
	await get_tree().process_frame
	await get_tree().process_frame

	if not is_instance_valid(model_root):
		loading_dialog.hide()
		loading_dialog.queue_free()
		return

	# 選択したパスをそのまま AssemblyImporter に渡して展開
	model_root.set("glb_file", absolute_path)
	if model_root.has_method("_unpack"):
		model_root.call("_unpack")

	_reset_workspace_state(false)
	_current_tscn_path = ""

	var model_aabb = _get_node_aabb(model_root, true)
	var ground_y = model_aabb.position.y if model_aabb.size != Vector3.ZERO else 0.0
	set_ground_visible(with_ground, ground_y)
	_opened_ground_visible = with_ground
	_opened_ground_y = ground_y
	_last_loaded_scene_path = ""

	# 古い設定ファイルを削除（別モデルには無効なため）
	if FileAccess.file_exists("user://simulation_config.json"):
		DirAccess.remove_absolute("user://simulation_config.json")

	await get_tree().process_frame
	fit_view_to_all_parts()

	selected_part = null
	_update_ui()

	loading_dialog.hide()
	loading_dialog.queue_free()
	_update_part_list()

func _on_add_model_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.title = "追加するGLBモデルを選択"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = PackedStringArray(["*.glb ; GLB 3D Model", "*.gltf ; GLTF 3D Model"])
	dialog.min_size = Vector2i(750, 500)
	
	dialog.file_selected.connect(func(path):
		dialog.hide()
		dialog.queue_free()
		_on_add_model_file_selected.call_deferred(path)
	)
	dialog.canceled.connect(func():
		dialog.hide()
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()

func _on_add_model_file_selected(absolute_path: String) -> void:
	if absolute_path.strip_edges() == "":
		return

	var loading_dialog = AcceptDialog.new()
	loading_dialog.title = "読み込み中"
	loading_dialog.dialog_text = "3Dモデルを追加しています...\nしばらくお待ちください。"
	loading_dialog.min_size = Vector2i(320, 120)
	loading_dialog.exclusive = true
	add_child(loading_dialog)
	loading_dialog.popup_centered()
	var ok_btn = loading_dialog.get_ok_button()
	if ok_btn:
		ok_btn.visible = false

	await get_tree().process_frame
	await get_tree().process_frame

	if not is_instance_valid(model_root):
		loading_dialog.hide()
		loading_dialog.queue_free()
		return

	model_root.set("glb_file", absolute_path)
	if model_root.has_method("_unpack_add"):
		model_root.call("_unpack_add")

	await get_tree().process_frame
	fit_view_to_all_parts()

	selected_part = null
	_update_ui()
	_update_part_list()
	loading_dialog.hide()
	loading_dialog.queue_free()


func _has_mesh_recursive(node: Node) -> bool:
	if node is MeshInstance3D:
		return true
	for child in node.get_children():
		if _has_mesh_recursive(child):
			return true
	return false

func _update_part_list() -> void:
	if not is_instance_valid(part_list) or not is_instance_valid(model_root):
		return
	_update_created_part_list()
	var prev_sel = part_list.get_selected_items()
	var prev_part = selected_part
	part_list.clear()

	var candidates: Array[Node3D] = []
	for child in model_root.get_children():
		if child is Node3D and (child.has_meta("generated_by_importer") or child.name == "GroundPlane") and _has_mesh_recursive(child):
			candidates.append(child as Node3D)

	var main_ground = get_node_or_null("/root/Main/GroundPlane")
	if main_ground is Node3D and not candidates.has(main_ground as Node3D) and not candidates.any(func(n): return n.name == "GroundPlane"):
		if not main_ground.get_meta("is_deleted", false):
			candidates.append(main_ground as Node3D)

	for child in candidates:
		if child.get_meta("is_deleted", false):
			continue

		var clean_name = child.name
		if child.name == "GroundPlane":
			clean_name = "地面 (GroundPlane)"
		var tags = ""
		var state = _get_part_visual_state(child)
		if (child.name == "GroundPlane" or child.name == "GroundMesh") and not child.visible:
			state = VS_HIDDEN
			
		if state == VS_HIDDEN:
			tags += " [非]"
		elif state == VS_TRANSPARENT:
			tags += " [透]"
			
		if _get_part_behavior(child) != null:
			tags += " [動]"
			
		var idx = part_list.add_item(clean_name + tags)
		part_list.set_item_metadata(idx, child)
		if selected_parts.has(child):
			part_list.select(idx, false)
		elif child == prev_part and selected_parts.is_empty():
			part_list.select(idx, false)

	if is_instance_valid(model_root):
		_ensure_collision_bodies_recursive(model_root)
	_remove_collision_areas()
	_update_motion_range_visuals()

func _on_part_list_item_selected(_index: int) -> void:
	# Shift+クリックでなければアンカーを更新
	if not Input.is_key_pressed(KEY_SHIFT):
		_part_list_last_selected_idx = _index
	var selected_array: Array[Node3D] = []
	for idx in part_list.get_selected_items():
		var raw = part_list.get_item_metadata(idx)
		if is_instance_valid(raw) and raw is Node3D:
			selected_array.append(raw as Node3D)
	_set_selected_parts(selected_array)

func _on_part_list_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	if not mb.shift_pressed:
		return
	# Shift+左クリック: 範囲選択
	var clicked_idx := part_list.get_item_at_position(mb.position, true)
	if clicked_idx < 0:
		return
	var anchor := _part_list_last_selected_idx
	if anchor < 0:
		anchor = 0
	var from_idx := mini(anchor, clicked_idx)
	var to_idx := maxi(anchor, clicked_idx)
	# CTRL が押されていなければ既存選択をクリア
	if not mb.ctrl_pressed:
		part_list.deselect_all()
	for i in range(from_idx, to_idx + 1):
		part_list.select(i, false)
	_on_part_list_item_selected(clicked_idx)
	part_list.accept_event()

func _on_created_part_list_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	if not mb.shift_pressed:
		return
	# Shift+左クリック: 範囲選択
	var clicked_idx := created_part_list.get_item_at_position(mb.position, true)
	if clicked_idx < 0:
		return
	var anchor := _created_part_list_last_selected_idx
	if anchor < 0:
		anchor = 0
	var from_idx := mini(anchor, clicked_idx)
	var to_idx := maxi(anchor, clicked_idx)
	if not mb.ctrl_pressed:
		created_part_list.deselect_all()
	for i in range(from_idx, to_idx + 1):
		created_part_list.select(i, false)
	_on_created_part_list_item_selected(clicked_idx)
	created_part_list.accept_event()

func _on_export_glb_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.title = "GLBとしてエクスポート"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = PackedStringArray(["*.glb ; GLB 3D Model"])
	dialog.min_size = Vector2i(750, 500)
	
	dialog.file_selected.connect(func(path):
		_export_glb_with_animations(path)
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()


func _get_original_scale(node: Node3D) -> Vector3:
	if not orig_scale.has(node):
		orig_scale[node] = node.scale
	return orig_scale[node]

func _on_slider_part_scale_changed(value: float) -> void:
	if selected_part:
		var apply_action = func():
			var s = _get_original_scale(selected_part)
			selected_part.scale = s * value
			_update_ui()

		var cancel_action = func():
			_is_restoring_ui_state = true
			_sync_part_sliders(selected_part)
			_is_restoring_ui_state = false

		_confirm_running_action(apply_action, cancel_action)

func _on_tab_changed(tab: int) -> void:
	_mouse_selection_locked = false
	_cancel_pivot_picking()
	if SimulationManager.state != SimulationManager.State.IDLE:
		SimulationManager.reset_simulation()

	if is_instance_valid(tab_container):
		var current_tab_node = tab_container.get_child(tab)
		if current_tab_node and (current_tab_node.name == "ファイル" or current_tab_node.name == "作成"):
			_on_deselect_model_pressed()

	# Update PartList, CreatedPartList, and TscnList visibility based on current tab
	if tab_container:
		var current_tab_node = tab_container.get_child(tab)
		var is_file = current_tab_node and (current_tab_node.name == "ファイル")
		var is_placement_or_motion = current_tab_node and (current_tab_node.name == "配置" or current_tab_node.name == "動作")
		var is_creation = current_tab_node and (current_tab_node.name == "作成")
		
		if is_file:
			if is_instance_valid(tscn_list):
				tscn_list.show()
				_update_load_options()
			if is_instance_valid(part_list): part_list.hide()
			if is_instance_valid(created_part_list): created_part_list.hide()
			if is_instance_valid(lbl_selected_part_name):
				lbl_selected_part_name.show()
				_update_tscn_selection_label()
		elif is_placement_or_motion:
			# 作成タブの下書き選択をクリアして干渉を防止
			selected_draft_index = -1
			selected_is_group = false
			selected_group_name = ""
			if is_instance_valid(created_part_list): created_part_list.deselect_all()
			if is_instance_valid(part_list): part_list.show()
			if is_instance_valid(tscn_list): tscn_list.hide()
			if is_instance_valid(created_part_list): created_part_list.hide()
			if is_instance_valid(lbl_selected_part_name):
				lbl_selected_part_name.show()
				_update_ui()
		elif is_creation:
			if is_instance_valid(created_part_list):
				created_part_list.show()
				_update_created_part_list()
			if is_instance_valid(part_list): part_list.hide()
			if is_instance_valid(tscn_list): tscn_list.hide()
			if is_instance_valid(lbl_selected_part_name):
				lbl_selected_part_name.show()
				_update_created_selection_label()
		else:
			if is_instance_valid(part_list): part_list.hide()
			if is_instance_valid(tscn_list): tscn_list.hide()
			if is_instance_valid(created_part_list): created_part_list.hide()
			if is_instance_valid(lbl_selected_part_name): lbl_selected_part_name.hide()

	# Also show/hide the SepListOps separator
	var sep = get_node_or_null("MarginContainer/ScrollContainer/VBoxOuter/SepListOps")
	if sep:
		var list_visible = (is_instance_valid(part_list) and part_list.visible) \
			or (is_instance_valid(created_part_list) and created_part_list.visible) \
			or (is_instance_valid(tscn_list) and tscn_list.visible)
		if list_visible:
			sep.show()
		else:
			sep.hide()

	# Manage creation tab draft preview visibility (only draft, not inserted parts)
	var current_tab_node = tab_container.get_child(tab) if tab_container else null
	var is_create_tab = (current_tab_node != null and current_tab_node.name == "作成")
	if is_instance_valid(draft_mesh_instance):
		draft_mesh_instance.visible = is_create_tab
	if is_instance_valid(draft_preview_container):
		draft_preview_container.visible = is_create_tab
		_set_node_collision_enabled_recursive(draft_preview_container, is_create_tab)

	if is_create_tab:
		if is_instance_valid(check_hide_existing):
			_on_check_hide_existing_toggled(check_hide_existing.button_pressed)
	else:
		_on_check_hide_existing_toggled(true)
		_update_part_list()

func _on_export_viewer_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.title = "HTMLビューアとしてエクスポート"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = PackedStringArray(["*.html ; HTML Viewer"])
	dialog.min_size = Vector2i(750, 500)
	dialog.file_selected.connect(func(path): _export_viewer_html(path))
	add_child(dialog)
	dialog.popup_centered()

func _export_viewer_html(path: String) -> void:
	# Export GLB to a temporary file, read as base64, embed into HTML
	var temp_glb = "user://temp_viewer.glb"
	_export_glb_with_animations(temp_glb)
	var f = FileAccess.open(temp_glb, FileAccess.READ)
	if not f:
		return
	var bytes = f.get_buffer(f.get_length())
	var b64 = Marshalls.raw_to_base64(bytes)
	var html = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>3D Viewer</title>
<script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.3.0/model-viewer.min.js"></script>
<style>
  body { margin: 0; padding: 0; background-color: #f0f0f0; }
  model-viewer { width: 100vw; height: 100vh; }
</style>
</head>
<body>
<model-viewer src="data:model/gltf-binary;base64,{BASE64}" camera-controls autoplay  shadow-intensity="1"></model-viewer>
</body>
</html>
"""
	html = html.replace("{BASE64}", b64)
	var out_f = FileAccess.open(path, FileAccess.WRITE)
	if out_f:
		out_f.store_string(html)
		out_f.close()

func _collect_all_motions() -> Dictionary:
	var motions = {}
	if not is_instance_valid(model_root):
		return motions
	for child in model_root.get_children():
		if child is Node3D:
			var behavior = _get_part_behavior(child)
			if behavior:
				var m_data = _serialize_behavior(behavior)
				if not m_data.is_empty():
					motions[child.name] = m_data
	return motions

func _serialize_behavior(behavior: ModelBehavior) -> Dictionary:
	var script_path: String = behavior.get_script().resource_path
	var data = {}
	if script_path.ends_with("motion_rotary.gd"):
		data["type"] = "rotary"
		var ax = behavior.get("axis")
		data["axis"] = [ax.x, ax.y, ax.z] if ax is Vector3 else [0.0, 1.0, 0.0]
		data["angle_min"] = float(behavior.get("angle_min")) if behavior.get("angle_min") != null else 0.0
		data["angle_max"] = float(behavior.get("angle_max")) if behavior.get("angle_max") != null else 360.0
		data["duration"] = float(behavior.get("duration")) if behavior.get("duration") != null else 3.0
		data["ping_pong"] = bool(behavior.get("ping_pong")) if behavior.get("ping_pong") != null else false
		var piv = behavior.get("pivot")
		data["pivot"] = [piv.x, piv.y, piv.z] if piv is Vector3 else [0.0, 0.0, 0.0]
	elif script_path.ends_with("motion_linear.gd"):
		data["type"] = "linear"
		var ax = behavior.get("axis")
		data["axis"] = [ax.x, ax.y, ax.z] if ax is Vector3 else [1.0, 0.0, 0.0]
		data["distance_min"] = float(behavior.get("distance_min")) if behavior.get("distance_min") != null else 0.0
		data["distance_max"] = float(behavior.get("distance_max")) if behavior.get("distance_max") != null else 1.0
		data["duration"] = float(behavior.get("duration")) if behavior.get("duration") != null else 3.0
		data["ping_pong"] = bool(behavior.get("ping_pong")) if behavior.get("ping_pong") != null else false
	return data

func _export_glb_with_animations(path: String) -> void:
	if not is_instance_valid(model_root):
		return
	
	var max_dur = 1.0
	for behavior in SimulationManager._behaviors:
		if is_instance_valid(behavior):
			var d = float(behavior.get("duration")) if behavior.get("duration") != null else 1.0
			# ping_pong が有効なら往復1サイクル = duration × 2
			var pp = bool(behavior.get("ping_pong")) if behavior.get("ping_pong") != null else false
			if pp:
				d *= 2.0
			if d > max_dur:
				max_dur = d
	
	var fps = 30.0
	var step = 1.0 / fps
	var num_steps = int(max_dur / step)
	
	var anim = Animation.new()
	anim.length = max_dur
	
	var parts = []
	for behavior in SimulationManager._behaviors:
		if is_instance_valid(behavior):
			var parent = behavior.get_parent()
			if parent is Node3D and parent not in parts:
				parts.append(parent)
			
	var track_indices = {}
	for part in parts:
		var p_path = model_root.get_path_to(part)
		
		var pos_idx = anim.add_track(Animation.TYPE_POSITION_3D)
		anim.track_set_path(pos_idx, NodePath(p_path))
		var rot_idx = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(rot_idx, NodePath(p_path))
		
		track_indices[part] = {"pos": pos_idx, "rot": rot_idx}
		
	var orig_time = SimulationManager.elapsed_time
	var orig_state = SimulationManager.state
	SimulationManager.state = SimulationManager.State.IDLE
	
	for i in range(num_steps + 1):
		var t = i * step
		SimulationManager.elapsed_time = t
		for behavior in SimulationManager._behaviors:
			if is_instance_valid(behavior):
				behavior.tick(0.0)
				
		for part in parts:
			var idxs = track_indices[part]
			anim.position_track_insert_key(idxs.pos, t, part.position)
			anim.rotation_track_insert_key(idxs.rot, t, part.transform.basis.get_rotation_quaternion())
	
	SimulationManager.elapsed_time = orig_time
	SimulationManager.state = orig_state
	for behavior in SimulationManager._behaviors:
		if is_instance_valid(behavior):
			behavior.tick(0.0)
			
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	
	# Create a duplicate tree for export (do not use DUPLICATE_USE_INSTANTIATION to avoid scene instantiation mismatch errors)
	var dup_root_safe = model_root.duplicate(Node.DUPLICATE_SIGNALS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS)
	dup_root_safe.name = "Assembly"
	model_root.get_parent().add_child(dup_root_safe)
	
	# Add animation player ONLY to dup_root_safe
	if not parts.is_empty():
		var anim_player = AnimationPlayer.new()
		anim_player.name = "ExportAnimPlayer"
		var lib = AnimationLibrary.new()
		lib.add_animation("Action", anim)
		anim_player.add_animation_library("", lib)
		dup_root_safe.add_child(anim_player)
		anim_player.owner = dup_root_safe

	# Apply visual states and remove non-exportable internal nodes
	var trans_mat = StandardMaterial3D.new()
	trans_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trans_mat.albedo_color = Color(1, 1, 1, 0.4)
	
	_clean_tree_for_glb_export(dup_root_safe, dup_root_safe, model_root, trans_mat)

	var err = gltf_doc.append_from_scene(dup_root_safe, gltf_state)
	if err == OK:
		var motions = _collect_all_motions()
		if not motions.is_empty():
			var json = gltf_state.get_json()
			if not json is Dictionary:
				json = {}
			if not json.has("extras") or not json["extras"] is Dictionary:
				json["extras"] = {}
			json["extras"]["hgnn_motions"] = motions
			gltf_state.set_json(json)

			var sidecar_path = ProjectSettings.globalize_path(path).get_basename() + ".motion.json"
			var sf = FileAccess.open(sidecar_path, FileAccess.WRITE)
			if sf:
				sf.store_string(JSON.stringify(motions, "\t"))
				sf.close()

		err = gltf_doc.write_to_filesystem(gltf_state, path)

	dup_root_safe.queue_free()

func _process(_delta: float) -> void:
	_update_ui()
	if is_instance_valid(_timeline_slider) and not _is_timeline_dragging:
		var dur = max(0.01, spin_motion_duration.value)
		var max_t = dur * 2.0 if check_motion_ping_pong.button_pressed else dur
		var curr_t = fmod(SimulationManager.elapsed_time, max_t)
		_timeline_slider.max_value = max_t
		_timeline_slider.set_value_no_signal(curr_t)
		if is_instance_valid(_lbl_timeline_time):
			_lbl_timeline_time.text = "%.2fs / %.2fs" % [curr_t, max_t]

func _update_ui() -> void:
	if not is_instance_valid(btn_play):
		return

	# Playback status details
	var status_text := ""
	if SimulationManager.state == SimulationManager.State.RUNNING:
		status_text = "ステータス: 再生中"
	elif SimulationManager.state == SimulationManager.State.PAUSED:
		status_text = "ステータス: 一時停止中"
	else:
		status_text = "ステータス: 停止中"

	lbl_status.text = status_text
	if is_instance_valid(lbl_status2):
		lbl_status2.text = status_text

	# Flat button highlight for playback
	var play_flat = (SimulationManager.state != SimulationManager.State.RUNNING)
	var pause_flat = (SimulationManager.state == SimulationManager.State.RUNNING)

	btn_play.flat = play_flat
	btn_pause.flat = pause_flat
	if is_instance_valid(btn_play2):
		btn_play2.flat = play_flat
	if is_instance_valid(btn_pause2):
		btn_pause2.flat = pause_flat

	# Show/Hide part details panels based on selection
	var has_sel = (selected_part != null)

	if is_instance_valid(btn_deselect_model):
		btn_deselect_model.visible = _mouse_selection_locked

	# Enable/Disable placement transform controls and action buttons
	if is_instance_valid(spin_part_pos_x): spin_part_pos_x.editable = has_sel
	if is_instance_valid(spin_part_pos_y): spin_part_pos_y.editable = has_sel
	if is_instance_valid(spin_part_pos_z): spin_part_pos_z.editable = has_sel
	if is_instance_valid(btn_reset_part_pos): btn_reset_part_pos.disabled = not has_sel

	if is_instance_valid(spin_part_rot_x): spin_part_rot_x.editable = has_sel
	if is_instance_valid(spin_part_rot_y): spin_part_rot_y.editable = has_sel
	if is_instance_valid(spin_part_rot_z): spin_part_rot_z.editable = has_sel
	if is_instance_valid(btn_reset_part_rot): btn_reset_part_rot.disabled = not has_sel

	if is_instance_valid(spin_part_scale_x): spin_part_scale_x.editable = has_sel
	if is_instance_valid(spin_part_scale_y): spin_part_scale_y.editable = has_sel
	if is_instance_valid(spin_part_scale_z): spin_part_scale_z.editable = has_sel
	if is_instance_valid(btn_reset_part_scale): btn_reset_part_scale.disabled = not has_sel
	if is_instance_valid(btn_link_part_scale): btn_link_part_scale.disabled = not has_sel

	if is_instance_valid(btn_part_opaque): btn_part_opaque.disabled = not has_sel
	if is_instance_valid(btn_part_transparent): btn_part_transparent.disabled = not has_sel
	if is_instance_valid(btn_part_hidden): btn_part_hidden.disabled = not has_sel

	if is_instance_valid(btn_copy_part): btn_copy_part.disabled = not has_sel
	if is_instance_valid(btn_delete_part): btn_delete_part.disabled = not has_sel
	if is_instance_valid(btn_undo_delete_part): btn_undo_delete_part.disabled = not is_instance_valid(last_deleted_part)

	if is_instance_valid(line_edit_part_name): line_edit_part_name.editable = has_sel
	if is_instance_valid(btn_rename_part): btn_rename_part.disabled = not has_sel
	if is_instance_valid(color_picker_part): color_picker_part.disabled = not has_sel
	if not has_sel and is_instance_valid(line_edit_part_name):
		line_edit_part_name.text = ""

	var has_draft = (selected_draft_index >= 0 and selected_draft_index < draft_parts.size()) or selected_is_group or (selected_part != null)
	if is_instance_valid(btn_copy_created_part): btn_copy_created_part.disabled = not has_draft
	if is_instance_valid(btn_delete_created_part): btn_delete_created_part.disabled = not has_draft
	if is_instance_valid(btn_undo_delete_created_part): btn_undo_delete_created_part.disabled = last_deleted_draft.is_empty()
	if is_instance_valid(btn_rename_created_part): btn_rename_created_part.disabled = not has_draft
	if is_instance_valid(line_edit_create_name): line_edit_create_name.editable = has_draft
	if is_instance_valid(color_picker_create): color_picker_create.disabled = not has_draft

	# Sync Selection Label according to current tab
	var cur_tab_name = ""
	if is_instance_valid(tab_container) and tab_container.get_child_count() > tab_container.current_tab:
		var cur_t = tab_container.get_child(tab_container.current_tab)
		if cur_t: cur_tab_name = cur_t.name

	if cur_tab_name == "作成":
		_update_created_selection_label()
	elif cur_tab_name == "ファイル":
		_update_tscn_selection_label()
	elif selected_part:
		var clean_name = selected_part.name
		if selected_parts.size() > 1:
			var names: Array[String] = []
			for p in selected_parts:
				if is_instance_valid(p): names.append(p.name)
			lbl_selected_part_name.text = "選択: " + ", ".join(names.slice(0, 3)) + ("..." if names.size() > 3 else "") + " (計%d個)" % selected_parts.size()
		else:
			lbl_selected_part_name.text = "選択: " + clean_name
	else:
		lbl_selected_part_name.text = "選択: なし (クリックで選択)"

	# Sync Part Details UI
	if selected_part:
		var vx = abs(_get_axis_val(btn_axis_x))
		var vy = abs(_get_axis_val(btn_axis_y))
		var vz = abs(_get_axis_val(btn_axis_z))
		btn_pick_pivot.disabled = (vx + vy + vz != 1.0)
		if is_instance_valid(spin_pivot_x): spin_pivot_x.editable = true
		if is_instance_valid(spin_pivot_y): spin_pivot_y.editable = true
		if is_instance_valid(spin_pivot_z): spin_pivot_z.editable = true
		
		# Sync visual state button highlight
		var current_state := _get_part_visual_state(selected_part)
			
		btn_part_opaque.button_pressed = (current_state == VS_OPAQUE)
		btn_part_transparent.button_pressed = (current_state == VS_TRANSPARENT)
		btn_part_hidden.button_pressed = (current_state == VS_HIDDEN)
	else:
		if is_instance_valid(btn_pick_pivot):
			btn_pick_pivot.disabled = true
			if is_picking_pivot:
				_cancel_pivot_picking()
		if is_instance_valid(spin_pivot_x): spin_pivot_x.editable = false
		if is_instance_valid(spin_pivot_y): spin_pivot_y.editable = false
		if is_instance_valid(spin_pivot_z): spin_pivot_z.editable = false

	if is_instance_valid(part_list) and part_list.visible:
		part_list.deselect_all()
		var targets = selected_parts if not selected_parts.is_empty() else ([selected_part] if selected_part else [])
		for i in range(part_list.item_count):
			var raw = part_list.get_item_metadata(i)
			if is_instance_valid(raw) and raw is Node3D:
				var p: Node3D = raw
				if targets.has(p):
					part_list.select(i, false)

	_update_motion_gizmo()


# ── Motion Axis Gizmo Visualizer ─────────────────────────────────────────────

var motion_gizmo_root: Node3D = null
var gizmo_shaft_mesh: MeshInstance3D = null
var gizmo_head1_mesh: MeshInstance3D = null
var gizmo_head2_mesh: MeshInstance3D = null
var gizmo_ring_mesh: MeshInstance3D = null
var gizmo_pivot_sphere_mesh: MeshInstance3D = null

func _setup_motion_gizmo() -> void:
	if is_instance_valid(motion_gizmo_root): return
	motion_gizmo_root = Node3D.new()
	motion_gizmo_root.name = "MotionGizmoRoot"
	add_child(motion_gizmo_root)

	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.2, 0.75, 1.0, 0.65) # 薄い青
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true

	gizmo_shaft_mesh = MeshInstance3D.new()
	gizmo_shaft_mesh.material_override = mat
	motion_gizmo_root.add_child(gizmo_shaft_mesh)

	gizmo_head1_mesh = MeshInstance3D.new()
	gizmo_head1_mesh.material_override = mat
	motion_gizmo_root.add_child(gizmo_head1_mesh)

	gizmo_head2_mesh = MeshInstance3D.new()
	gizmo_head2_mesh.material_override = mat
	motion_gizmo_root.add_child(gizmo_head2_mesh)

	gizmo_ring_mesh = MeshInstance3D.new()
	gizmo_ring_mesh.material_override = mat
	motion_gizmo_root.add_child(gizmo_ring_mesh)

	var sphere_mat = StandardMaterial3D.new()
	sphere_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	sphere_mat.albedo_color = Color(1.0, 0.55, 0.0, 0.95) # 鮮やかなオレンジ色
	sphere_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	sphere_mat.no_depth_test = true

	gizmo_pivot_sphere_mesh = MeshInstance3D.new()
	gizmo_pivot_sphere_mesh.material_override = sphere_mat
	motion_gizmo_root.add_child(gizmo_pivot_sphere_mesh)

func _get_part_aabb(node: Node3D) -> AABB:
	var total_aabb := AABB()
	var first := true
	_calc_aabb_recursive(node, Transform3D.IDENTITY, total_aabb, first)
	if total_aabb.size == Vector3.ZERO:
		total_aabb = AABB(Vector3(-0.1, -0.1, -0.1), Vector3(0.2, 0.2, 0.2))
	return total_aabb

func _calc_aabb_recursive(node: Node, xform: Transform3D, total_aabb: AABB, first: bool) -> void:
	if node is MeshInstance3D and node.mesh:
		var mesh_aabb = xform * node.mesh.get_aabb()
		if first:
			total_aabb.position = mesh_aabb.position
			total_aabb.size = mesh_aabb.size
			first = false
		else:
			total_aabb = total_aabb.merge(mesh_aabb)
	for child in node.get_children():
		if child is Node3D:
			_calc_aabb_recursive(child, xform * child.transform, total_aabb, first)

func _update_motion_gizmo() -> void:
	_setup_motion_gizmo()
	
	var is_motion_tab = false
	if is_instance_valid(tab_container):
		var current_tab = tab_container.get_current_tab_control()
		if current_tab and current_tab.name == "動作":
			is_motion_tab = true

	if not is_motion_tab or SimulationManager.state == SimulationManager.State.RUNNING or not is_instance_valid(selected_part) or not is_instance_valid(motion_gizmo_root):
		if is_instance_valid(motion_gizmo_root): motion_gizmo_root.hide()
		return

	var m_type = "none"
	var bh = _get_part_behavior(selected_part)
	if bh:
		if bh is MotionRotary:
			m_type = "rotary"
		elif bh is MotionLinear:
			m_type = "linear"
	
	if is_instance_valid(option_motion_type) and option_motion_type.selected > 0:
		match option_motion_type.selected:
			1: m_type = "rotary"
			2: m_type = "linear"
	elif is_picking_pivot:
		m_type = "rotary"

	var axis_local = _get_current_motion_axis()
	if axis_local.is_zero_approx():
		if bh and "axis" in bh:
			axis_local = bh.axis
		else:
			axis_local = Vector3.UP

	var center_parent = Vector3.ZERO
	if is_instance_valid(spin_pivot_x) and is_instance_valid(spin_pivot_y) and is_instance_valid(spin_pivot_z):
		center_parent = Vector3(spin_pivot_x.value, spin_pivot_y.value, spin_pivot_z.value)
	elif bh and bh is MotionRotary:
		center_parent = selected_part.transform * bh.pivot
	else:
		center_parent = selected_part.position

	if m_type == "none" or axis_local.is_zero_approx():
		motion_gizmo_root.hide()
		return

	motion_gizmo_root.show()

	var aabb = _get_part_aabb(selected_part)
	var sz = maxf(aabb.size.x, maxf(aabb.size.y, aabb.size.z))
	if sz < 0.05: sz = 0.2
	var gizmo_len = maxf(0.15, sz * 0.9)
	var arrow_size = minf(0.04, gizmo_len * 0.2)
	var shaft_radius = maxf(0.003, arrow_size * 0.25)

	var part_transform = selected_part.global_transform
	var axis_dir_world = (part_transform.basis * axis_local.normalized()).normalized()
	
	if m_type == "linear":
		var origin_world = part_transform * aabb.get_center()
		motion_gizmo_root.global_position = origin_world
		
		if not axis_dir_world.is_equal_approx(Vector3.UP) and not axis_dir_world.is_equal_approx(Vector3.DOWN):
			motion_gizmo_root.look_at(origin_world + axis_dir_world, Vector3.UP)
		else:
			motion_gizmo_root.look_at(origin_world + axis_dir_world, Vector3.RIGHT)

		var cyl = CylinderMesh.new()
		cyl.top_radius = shaft_radius
		cyl.bottom_radius = shaft_radius
		cyl.height = gizmo_len
		gizmo_shaft_mesh.mesh = cyl
		gizmo_shaft_mesh.position = Vector3.ZERO
		gizmo_shaft_mesh.rotation = Vector3(PI/2, 0, 0)

		var cone1 = CylinderMesh.new()
		cone1.top_radius = 0.0
		cone1.bottom_radius = arrow_size
		cone1.height = arrow_size * 2.0
		gizmo_head1_mesh.mesh = cone1
		gizmo_head1_mesh.position = Vector3(0, 0, gizmo_len * 0.5 + arrow_size)
		gizmo_head1_mesh.rotation = Vector3(PI/2, 0, 0)

		var cone2 = CylinderMesh.new()
		cone2.top_radius = 0.0
		cone2.bottom_radius = arrow_size
		cone2.height = arrow_size * 2.0
		gizmo_head2_mesh.mesh = cone2
		gizmo_head2_mesh.position = Vector3(0, 0, - (gizmo_len * 0.5 + arrow_size))
		gizmo_head2_mesh.rotation = Vector3(-PI/2, 0, 0)

		gizmo_ring_mesh.hide()
		if is_instance_valid(gizmo_pivot_sphere_mesh): gizmo_pivot_sphere_mesh.hide()
		gizmo_shaft_mesh.show()
		gizmo_head1_mesh.show()
		gizmo_head2_mesh.show()

	elif m_type == "rotary":
		var parent_node = selected_part.get_parent() as Node3D
		var pivot_world = parent_node.global_transform * center_parent if is_instance_valid(parent_node) else center_parent
		motion_gizmo_root.global_position = pivot_world

		if not axis_dir_world.is_equal_approx(Vector3.UP) and not axis_dir_world.is_equal_approx(Vector3.DOWN):
			motion_gizmo_root.look_at(pivot_world + axis_dir_world, Vector3.UP)
		else:
			motion_gizmo_root.look_at(pivot_world + axis_dir_world, Vector3.RIGHT)

		var cyl = CylinderMesh.new()
		cyl.top_radius = shaft_radius
		cyl.bottom_radius = shaft_radius
		cyl.height = gizmo_len
		gizmo_shaft_mesh.mesh = cyl
		gizmo_shaft_mesh.position = Vector3.ZERO
		gizmo_shaft_mesh.rotation = Vector3(PI/2, 0, 0)

		var torus = TorusMesh.new()
		var r_outer = gizmo_len * 0.4
		torus.outer_radius = r_outer
		torus.inner_radius = maxf(0.001, r_outer - shaft_radius * 1.5)
		gizmo_ring_mesh.mesh = torus
		gizmo_ring_mesh.position = Vector3.ZERO
		gizmo_ring_mesh.rotation = Vector3(PI/2, 0, 0)

		if is_instance_valid(gizmo_pivot_sphere_mesh):
			var sphere = SphereMesh.new()
			var sphere_radius = maxf(0.008, shaft_radius * 3.0)
			sphere.radius = sphere_radius
			sphere.height = sphere_radius * 2.0
			gizmo_pivot_sphere_mesh.mesh = sphere
			gizmo_pivot_sphere_mesh.position = Vector3.ZERO
			gizmo_pivot_sphere_mesh.show()

		gizmo_shaft_mesh.show()
		gizmo_ring_mesh.show()
		gizmo_head1_mesh.hide()
		gizmo_head2_mesh.hide()


# ── Motion Settings Syncing ──────────────────────────────────────────────────

func _set_axis_ui(val: float, btn: Button, label: String) -> void:
	var disp = 0
	if val < -0.5: disp = -1
	elif val > 0.5: disp = 1
	btn.text = "%s: %d" % [label, disp]

func _get_current_motion_axis() -> Vector3:
	if is_instance_valid(btn_axis_x) and is_instance_valid(btn_axis_y) and is_instance_valid(btn_axis_z):
		return Vector3(_get_axis_val(btn_axis_x), _get_axis_val(btn_axis_y), _get_axis_val(btn_axis_z))
	return Vector3.ZERO

func _get_axis_val(btn: Button) -> float:
	if btn.text.ends_with("-1"): return -1.0
	if btn.text.ends_with("1"): return 1.0
	return 0.0

func _cycle_axis_btn(btn: Button, label: String) -> void:
	var val = _get_axis_val(btn)
	var next_val = 0.0
	if val == 0.0: next_val = 1.0
	elif val == 1.0: next_val = -1.0
	else: next_val = 0.0
	_set_axis_ui(next_val, btn, label)
	_on_motion_param_changed(0.0)

func _set_motion_controls_blocked(blocked: bool) -> void:
	if option_motion_type: option_motion_type.set_block_signals(blocked)
	if spin_motion_duration: spin_motion_duration.set_block_signals(blocked)
	if check_motion_ping_pong: check_motion_ping_pong.set_block_signals(blocked)
	if spin_motion_param_min: spin_motion_param_min.set_block_signals(blocked)
	if spin_motion_param_max: spin_motion_param_max.set_block_signals(blocked)
	if spin_pivot_x: spin_pivot_x.set_block_signals(blocked)
	if spin_pivot_y: spin_pivot_y.set_block_signals(blocked)
	if spin_pivot_z: spin_pivot_z.set_block_signals(blocked)

func _sync_motion_ui_from_selected_part() -> void:
	if not selected_part:
		return

	_is_restoring_ui_state = true
	_set_motion_controls_blocked(true)

	var behavior = _get_part_behavior(selected_part)
	if not behavior:
		option_motion_type.selected = 0 # None
		spin_motion_duration.value = 3.0
		check_motion_ping_pong.button_pressed = false
		spin_motion_param_min.value = 0.0
		spin_motion_param_max.value = 0.0
		_set_axis_ui(0.0, btn_axis_x, "X")
		_set_axis_ui(1.0, btn_axis_y, "Y")
		_set_axis_ui(0.0, btn_axis_z, "Z")
		spin_pivot_x.value = selected_part.position.x
		spin_pivot_y.value = selected_part.position.y
		spin_pivot_z.value = selected_part.position.z
		check_motion_ping_pong.text = "往復動作（なし）"
		_set_motion_controls_blocked(false)
		_is_restoring_ui_state = false
		return

	var script_path: String = behavior.get_script().resource_path
	if script_path.ends_with("motion_rotary.gd"):
		option_motion_type.selected = 1 # Rotary
		spin_motion_duration.value = float(behavior.get("duration")) if behavior.get("duration") != null else 3.0
		check_motion_ping_pong.button_pressed = bool(behavior.get("ping_pong")) if behavior.get("ping_pong") != null else false
		spin_motion_param_min.value = float(behavior.get("angle_min")) if behavior.get("angle_min") != null else 0.0
		spin_motion_param_max.value = float(behavior.get("angle_max")) if behavior.get("angle_max") != null else 360.0
		var raw_axis = behavior.get("axis")
		var axis: Vector3 = raw_axis if raw_axis is Vector3 else Vector3.UP
		_set_axis_ui(axis.x, btn_axis_x, "X")
		_set_axis_ui(axis.y, btn_axis_y, "Y")
		_set_axis_ui(axis.z, btn_axis_z, "Z")
		
		var raw_pivot = behavior.get("pivot")
		var pivot: Vector3 = raw_pivot if raw_pivot is Vector3 else Vector3.ZERO
		var center_parent = selected_part.transform * pivot
		spin_pivot_x.value = center_parent.x
		spin_pivot_y.value = center_parent.y
		spin_pivot_z.value = center_parent.z
	elif script_path.ends_with("motion_linear.gd"):
		option_motion_type.selected = 2 # Linear
		spin_motion_duration.value = float(behavior.get("duration")) if behavior.get("duration") != null else 3.0
		check_motion_ping_pong.button_pressed = bool(behavior.get("ping_pong")) if behavior.get("ping_pong") != null else false
		var d_min = behavior.get("distance_min")
		var d_max = behavior.get("distance_max")
		spin_motion_param_min.value = (float(d_min) * 1000.0) if d_min != null else 0.0
		spin_motion_param_max.value = (float(d_max) * 1000.0) if d_max != null else 1000.0
		var raw_dir = behavior.get("axis")
		var dir: Vector3 = raw_dir if raw_dir is Vector3 else Vector3.RIGHT
		_set_axis_ui(dir.x, btn_axis_x, "X")
		_set_axis_ui(dir.y, btn_axis_y, "Y")
		_set_axis_ui(dir.z, btn_axis_z, "Z")
		spin_pivot_x.value = selected_part.position.x
		spin_pivot_y.value = selected_part.position.y
		spin_pivot_z.value = selected_part.position.z

	check_motion_ping_pong.text = "往復動作（あり）" if check_motion_ping_pong.button_pressed else "往復動作（なし）"
	_set_motion_controls_blocked(false)
	_is_restoring_ui_state = false


func _on_motion_type_selected(index: int) -> void:
	if not selected_part:
		return

	var apply_action = func():
		var type = "none"
		if index == 1:
			type = "rotary"
		elif index == 2:
			type = "linear"

		var params = _get_motion_params_from_ui(type)
		apply_motion_to_part(selected_part, type, params)
		_update_ui()

	var cancel_action = func():
		_is_restoring_ui_state = true
		_sync_motion_ui_from_selected_part()
		_is_restoring_ui_state = false

	_confirm_running_action(apply_action, cancel_action)


func _on_motion_param_changed(_val: float) -> void:
	if _is_restoring_ui_state:
		return
	if not selected_part:
		return

	var index = option_motion_type.selected
	var type = "none"
	if index == 1:
		type = "rotary"
	elif index == 2:
		type = "linear"
	elif index == 0 and is_instance_valid(option_motion_type):
		option_motion_type.selected = 1
		type = "rotary"

	if type != "none":
		var apply_action = func():
			var params = _get_motion_params_from_ui(type)
			apply_motion_to_part(selected_part, type, params)
			_update_ui()

		var cancel_action = func():
			_is_restoring_ui_state = true
			_sync_motion_ui_from_selected_part()
			_is_restoring_ui_state = false

		_confirm_running_action(apply_action, cancel_action)


func _get_motion_params_from_ui(type: String) -> Dictionary:
	var params := {}
	params["duration"] = spin_motion_duration.value
	params["ping_pong"] = check_motion_ping_pong.button_pressed

	var vx = _get_axis_val(btn_axis_x)
	var vy = _get_axis_val(btn_axis_y)
	var vz = _get_axis_val(btn_axis_z)
	var vec = Vector3(vx, vy, vz)
	if vec.is_zero_approx():
		vec = Vector3.UP # fallback

	var center_parent = Vector3(spin_pivot_x.value, spin_pivot_y.value, spin_pivot_z.value)
	var local_pivot = Vector3.ZERO
	if is_instance_valid(selected_part):
		local_pivot = selected_part.transform.affine_inverse() * center_parent

	if type == "rotary":
		params["axis"] = vec.normalized()
		params["angle_min"] = spin_motion_param_min.value
		params["angle_max"] = spin_motion_param_max.value
		params["pivot"] = local_pivot
	elif type == "linear":
		params["axis"] = vec.normalized()
		params["distance_min"] = spin_motion_param_min.value / 1000.0 # mm to m
		params["distance_max"] = spin_motion_param_max.value / 1000.0 # mm to m

	return params


func _get_part_behavior(part: Node3D) -> ModelBehavior:
	for child in part.get_children():
		if child is ModelBehavior:
			return child as ModelBehavior
	return null


# ── Core API: Dynamic Motion Script Attachment ────────────────────────────────

func apply_motion_to_part(part_node: Node3D, type: String, params: Dictionary) -> void:
	if not is_instance_valid(part_node):
		return

	var old = _get_part_behavior(part_node)
	var has_old = false
	var old_transform = part_node.transform

	# Remove any existing behavior script
	if old:
		has_old = true
		old_transform = old._initial_parent_transform
		SimulationManager.unregister_behavior(old)
		old.queue_free()
		part_node.remove_child(old)
		
		# Always restore the transform before attaching a new behavior
		# so the new behavior captures the true original transform.
		part_node.transform = old_transform

	if type == "none" or type == "":
		return

	var behavior: Node = null
	if type == "rotary":
		behavior = Node.new()
		behavior.set_script(load("res://scripts/motion_rotary.gd"))
		behavior.set("axis", params.get("axis", Vector3.UP))
		behavior.set("angle_min", params.get("angle_min", 0.0))
		behavior.set("angle_max", params.get("angle_max", 360.0))
		behavior.set("duration", params.get("duration", 3.0))
		behavior.set("ping_pong", params.get("ping_pong", false))
		behavior.set("pivot", params.get("pivot", Vector3.ZERO))
	elif type == "linear":
		behavior = Node.new()
		behavior.set_script(load("res://scripts/motion_linear.gd"))
		behavior.set("axis", params.get("axis", Vector3.RIGHT))
		behavior.set("distance_min", params.get("distance_min", 0.0))
		behavior.set("distance_max", params.get("distance_max", 1.0))
		behavior.set("duration", params.get("duration", 3.0))
		behavior.set("ping_pong", params.get("ping_pong", false))

	if behavior:
		behavior.name = "MotionBehavior"
		part_node.add_child(behavior)
		_mark_modified()

	_update_motion_range_visuals()
	if SimulationManager.state == SimulationManager.State.RUNNING:
		SimulationManager.register_behavior(behavior)
		behavior.start()


# ── Persistence (Save / Load Config as Scene) ──────────────────────────────────

func _get_save_dir() -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://scenes")
	else:
		return OS.get_executable_path().get_base_dir()

func _get_last_scene_config_path() -> String:
	return "user://last_scene.json"

func _save_last_scene_path(filepath: String) -> void:
	if filepath.is_empty():
		return
	var clean_path = filepath.replace("\\", "/")
	var data = {
		"last_scene_name": clean_path.get_file(),
		"last_scene_path": clean_path
	}
	var file = FileAccess.open(_get_last_scene_config_path(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func _get_last_scene_path() -> String:
	var cfg_path = _get_last_scene_config_path()
	if not FileAccess.file_exists(cfg_path):
		return ""
	var file = FileAccess.open(cfg_path, FileAccess.READ)
	if not file:
		return ""
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) != OK or not (json.data is Dictionary):
		return ""
	var d = json.data as Dictionary
	var s_dir = _get_save_dir().replace("\\", "/").trim_suffix("/")

	var last_name = (d.get("last_scene_name", "") as String).strip_edges()
	var last_path = (d.get("last_scene_path", "") as String).replace("\\", "/").strip_edges()

	# 1. 保存されていたファイル名が現在の作業ディレクトリ配下に実在するか確認
	if last_name != "":
		var candidate = s_dir + "/" + last_name
		if FileAccess.file_exists(candidate):
			return candidate

	# 2. 保存されていたフルパスが現在の作業ディレクトリと一致し、かつ実在するか確認
	if last_path != "":
		var fname = last_path.get_file()
		var candidate_from_path = s_dir + "/" + fname
		if last_path.get_base_dir() == s_dir and FileAccess.file_exists(last_path):
			return last_path
		elif FileAccess.file_exists(candidate_from_path):
			return candidate_from_path

	return ""

func _find_first_available_tscn() -> String:
	var s_dir = _get_save_dir()
	var dir = DirAccess.open(s_dir)
	if not dir:
		return ""
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var latest_path = ""
	var latest_mtime: int = -1
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var lower = file_name.to_lower()
			if lower != "main.tscn" and not lower.begins_with("test_"):
				var full_path = s_dir + "/" + file_name
				var mtime = FileAccess.get_modified_time(full_path)
				if mtime > latest_mtime:
					latest_mtime = mtime
					latest_path = full_path
		file_name = dir.get_next()
	return latest_path

func _create_empty_base_scene(target_path: String) -> bool:
	var empty_assembly = Node3D.new()
	empty_assembly.name = "Assembly"
	var importer_script = load("res://scripts/assembly_importer.gd")
	if importer_script:
		empty_assembly.set_script(importer_script)
	empty_assembly.set_meta("ground_visible", true)
	empty_assembly.set_meta("ground_y", 0.0)
	
	var packed = PackedScene.new()
	var err = packed.pack(empty_assembly)
	empty_assembly.free()
	if err != OK:
		return false
	
	err = ResourceSaver.save(packed, target_path)
	if err == OK:
		return true
	else:
		return false

var _alert_dialog: AcceptDialog = null

func _show_alert(message: String, title_text: String = "警告") -> void:
	if not is_instance_valid(_alert_dialog):
		_alert_dialog = AcceptDialog.new()
		add_child(_alert_dialog)
	_alert_dialog.title = title_text
	_alert_dialog.dialog_text = message
	_alert_dialog.popup_centered()

func _sync_tscn_list_selection(target_path: String = "") -> void:
	if not is_instance_valid(tscn_list) or tscn_list.item_count == 0:
		_update_tscn_selection_label()
		return

	var path_to_find = target_path
	if path_to_find.is_empty():
		path_to_find = _current_tscn_path

	var found_idx = -1
	var base_idx = -1

	for i in range(tscn_list.item_count):
		var meta = tscn_list.get_item_metadata(i)
		if meta is Dictionary:
			var p = meta.get("path", "") as String
			var d_name = meta.get("display_name", "") as String
			if path_to_find != "" and (p == path_to_find or p.get_file() == path_to_find.get_file()):
				found_idx = i
				break
			if d_name == "base.tscn":
				if base_idx == -1:
					base_idx = i

	var final_idx = found_idx
	if final_idx == -1:
		final_idx = base_idx if base_idx != -1 else 0

	if final_idx >= 0 and final_idx < tscn_list.item_count:
		tscn_list.deselect_all()
		tscn_list.select(final_idx)
		tscn_list.ensure_current_is_visible()
		_last_selected_tscn_index = final_idx
		var meta = tscn_list.get_item_metadata(final_idx)
		if meta is Dictionary and meta.has("display_name") and is_instance_valid(line_edit_save_name):
			line_edit_save_name.text = (meta["display_name"] as String).trim_suffix(".tscn")
		if meta is Dictionary and meta.has("path") and _current_tscn_path.is_empty():
			_current_tscn_path = meta["path"] as String
		if is_instance_valid(option_load_config) and final_idx < option_load_config.item_count:
			option_load_config.select(final_idx)

	_update_tscn_selection_label()

func _update_load_options() -> void:
	if is_instance_valid(option_load_config):
		option_load_config.clear()
	if is_instance_valid(tscn_list):
		tscn_list.clear()

	var paths_to_search: Array[String] = []
	if OS.has_feature("editor"):
		paths_to_search.append(ProjectSettings.globalize_path("res://scenes"))
	else:
		paths_to_search.append(OS.get_executable_path().get_base_dir())
	
	for path in paths_to_search:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and (file_name.ends_with(".tscn") or file_name.ends_with(".tscn.remap")):
					var clean_name = file_name.trim_suffix(".remap")
					var lower_name = clean_name.to_lower()
					if lower_name != "main.tscn" and not lower_name.begins_with("test_") and not lower_name.begins_with("verify_"):
						var full_path = path + "/" + clean_name
						if path == "user://" or path.begins_with("res://"):
							if path == "user://": full_path = "user://" + clean_name
						else:
							full_path = path + "/" + clean_name

						if is_instance_valid(option_load_config):
							var idx = option_load_config.item_count
							option_load_config.add_item(clean_name)
							option_load_config.set_item_metadata(idx, full_path)

						if is_instance_valid(tscn_list):
							var found_tscn = false
							for i in range(tscn_list.item_count):
								var meta = tscn_list.get_item_metadata(i) as Dictionary
								if meta and meta.get("display_name", "") == clean_name:
									found_tscn = true
									break
							if not found_tscn:
								var idx = tscn_list.add_item(clean_name)
								tscn_list.set_item_metadata(idx, {"path": full_path, "display_name": clean_name})

				file_name = dir.get_next()
		
	_sync_tscn_list_selection()


var _is_modified: bool = false
var _was_just_cleared: bool = false
var _current_tscn_path: String = ""
var _last_loaded_scene_path: String = ""
var _opened_ground_visible: bool = true
var _opened_ground_y: float = 0.0
var _last_selected_tscn_index: int = -1
var _pending_tscn_index: int = -1
var _pending_tscn_filepath: String = ""
var _tscn_switch_confirm_dialog: ConfirmationDialog = null
var _quit_confirm_dialog: ConfirmationDialog = null
var _quit_cleared_confirm_dialog: ConfirmationDialog = null
var _all_reset_confirm_dialog: ConfirmationDialog = null

func _mark_modified() -> void:
	_is_modified = true
	_was_just_cleared = false

func _show_quit_cleared_confirm_dialog() -> void:
	if not is_instance_valid(_quit_cleared_confirm_dialog):
		_quit_cleared_confirm_dialog = ConfirmationDialog.new()
		_quit_cleared_confirm_dialog.title = "終了確認"
		_quit_cleared_confirm_dialog.dialog_text = "作業空間の全モデルが削除されています。\n保存せずに終了しますか？"
		_quit_cleared_confirm_dialog.get_ok_button().text = "終了する"
		_quit_cleared_confirm_dialog.get_cancel_button().text = "キャンセル"
		_quit_cleared_confirm_dialog.confirmed.connect(func(): _quit_app())
		add_child(_quit_cleared_confirm_dialog)
	_quit_cleared_confirm_dialog.popup_centered()

func _show_quit_confirm_dialog() -> void:
	if not is_instance_valid(_quit_confirm_dialog):
		_quit_confirm_dialog = ConfirmationDialog.new()
		_quit_confirm_dialog.title = "終了確認"
		_quit_confirm_dialog.get_ok_button().text = "保存して終了"
		_quit_confirm_dialog.add_button("保存せず終了", false, "dont_save")
		_quit_confirm_dialog.get_cancel_button().text = "キャンセル"
		
		_quit_confirm_dialog.confirmed.connect(_on_quit_save_confirmed)
		_quit_confirm_dialog.custom_action.connect(_on_quit_custom_action)
		add_child(_quit_confirm_dialog)

	var cur_name = _current_tscn_path.get_file() if _current_tscn_path != "" else "現在のシーン"
	_quit_confirm_dialog.dialog_text = "「%s」への変更が保存されていません。\n保存して終了しますか？" % cur_name
	_quit_confirm_dialog.popup_centered()

func _on_quit_save_confirmed() -> void:
	var save_path = _current_tscn_path
	if save_path.is_empty():
		var base_name = line_edit_save_name.text.strip_edges() if is_instance_valid(line_edit_save_name) else "base"
		if base_name == "": base_name = "base"
		if not base_name.ends_with(".tscn"): base_name += ".tscn"
		save_path = _get_save_dir() + "/" + base_name
	save_simulation_config(save_path)
	_quit_app()

func _on_quit_custom_action(action: String) -> void:
	if action == "dont_save":
		_quit_app()

func _on_tscn_list_item_selected(index: int) -> void:
	if not is_instance_valid(tscn_list): return
	if index < 0 or index >= tscn_list.item_count: return

	var meta = tscn_list.get_item_metadata(index)
	var filepath = ""
	if meta is Dictionary and meta.has("path"):
		filepath = meta["path"] as String

	# すでにロードされている同じファイルをクリックした場合
	if filepath == _current_tscn_path:
		_last_selected_tscn_index = index
		if meta is Dictionary and meta.has("display_name") and is_instance_valid(line_edit_save_name):
			line_edit_save_name.text = (meta["display_name"] as String).trim_suffix(".tscn")
		_update_tscn_selection_label()
		return

	if _is_modified:
		_pending_tscn_index = index
		_pending_tscn_filepath = filepath
		# ダイアログ表示中はリストの選択表示を元のファイルに戻しておく
		if _last_selected_tscn_index != -1 and _last_selected_tscn_index < tscn_list.item_count:
			tscn_list.select(_last_selected_tscn_index)
		_show_tscn_switch_confirm_dialog()
	else:
		_do_load_tscn_at_index(index)

func _do_load_tscn_at_index(index: int) -> void:
	if not is_instance_valid(tscn_list): return
	if index < 0 or index >= tscn_list.item_count: return
	var meta = tscn_list.get_item_metadata(index)
	if meta is Dictionary and meta.has("path"):
		var filepath = meta["path"] as String
		_last_selected_tscn_index = index
		_current_tscn_path = filepath
		load_simulation_config(filepath)
		tscn_list.deselect_all()
		tscn_list.select(index)
		tscn_list.ensure_current_is_visible()
		if meta.has("display_name") and is_instance_valid(line_edit_save_name):
			line_edit_save_name.text = (meta["display_name"] as String).trim_suffix(".tscn")
		_update_tscn_selection_label()

func _show_tscn_switch_confirm_dialog() -> void:
	if not is_instance_valid(_tscn_switch_confirm_dialog):
		_tscn_switch_confirm_dialog = ConfirmationDialog.new()
		_tscn_switch_confirm_dialog.title = "変更の保存確認"
		_tscn_switch_confirm_dialog.get_ok_button().text = "保存して移動"
		_tscn_switch_confirm_dialog.add_button("保存せず移動", false, "dont_save")
		_tscn_switch_confirm_dialog.get_cancel_button().text = "キャンセル"
		
		_tscn_switch_confirm_dialog.confirmed.connect(_on_tscn_switch_save_confirmed)
		_tscn_switch_confirm_dialog.custom_action.connect(_on_tscn_switch_custom_action)
		_tscn_switch_confirm_dialog.canceled.connect(_on_tscn_switch_canceled)
		add_child(_tscn_switch_confirm_dialog)

	var cur_name = _current_tscn_path.get_file() if _current_tscn_path != "" else "現在のシーン"
	_tscn_switch_confirm_dialog.dialog_text = "「%s」への変更が保存されていません。\n保存してから移動しますか？" % cur_name
	_tscn_switch_confirm_dialog.popup_centered()

func _on_tscn_switch_save_confirmed() -> void:
	# 現在の tscn に上書き保存する
	var save_path = _current_tscn_path
	if save_path.is_empty():
		save_path = _get_save_dir() + "/base.tscn"
	save_simulation_config(save_path)
	_update_load_options()
	
	# 保存後に目的の tscn をロード
	var next_idx = _pending_tscn_index
	_pending_tscn_filepath = ""
	_pending_tscn_index = -1
	if next_idx >= 0 and is_instance_valid(tscn_list) and next_idx < tscn_list.item_count:
		_do_load_tscn_at_index(next_idx)

func _on_tscn_switch_custom_action(action: String) -> void:
	if action == "dont_save":
		if is_instance_valid(_tscn_switch_confirm_dialog):
			_tscn_switch_confirm_dialog.hide()
		_is_modified = false
		var next_idx = _pending_tscn_index
		_pending_tscn_filepath = ""
		_pending_tscn_index = -1
		if next_idx >= 0 and is_instance_valid(tscn_list) and next_idx < tscn_list.item_count:
			_do_load_tscn_at_index(next_idx)

func _on_tscn_switch_canceled() -> void:
	_pending_tscn_filepath = ""
	_pending_tscn_index = -1
	_sync_tscn_list_selection()


func _update_tscn_selection_label() -> void:
	if not is_instance_valid(lbl_selected_part_name): return
	if is_instance_valid(tscn_list) and tscn_list.get_selected_items().size() > 0:
		var sel_idx = tscn_list.get_selected_items()[0]
		var meta = tscn_list.get_item_metadata(sel_idx)
		if meta is Dictionary and meta.has("display_name"):
			lbl_selected_part_name.text = "選択: " + meta["display_name"]
			return
	lbl_selected_part_name.text = "選択: なし (リストで選択)"


var _save_filepath_pending: String = ""
var _save_confirm_dialog: ConfirmationDialog = null

func _on_save_config_pressed() -> void:
	var name_part = line_edit_save_name.text.strip_edges() if is_instance_valid(line_edit_save_name) else ""
	if name_part == "":
		name_part = "base"
	
	var lower_name = name_part.to_lower()
	if lower_name == "main" or lower_name == "main.tscn":
		_show_alert("main.tscn は保護されているため保存・上書きできません。")
		_pending_tscn_filepath = ""
		_pending_tscn_index = -1
		_sync_tscn_list_selection()
		return

	if not name_part.ends_with(".tscn"):
		name_part += ".tscn"

	var filepath = _get_save_dir() + "/" + name_part
	
	if FileAccess.file_exists(filepath):
		if not is_instance_valid(_save_confirm_dialog):
			_save_confirm_dialog = ConfirmationDialog.new()
			_save_confirm_dialog.dialog_text = "既に同じ名前のファイルが存在します。\n上書き保存しますか？"
			_save_confirm_dialog.title = "上書き確認"
			_save_confirm_dialog.confirmed.connect(_do_save_config)
			add_child(_save_confirm_dialog)
		_save_filepath_pending = filepath
		_save_confirm_dialog.popup_centered()
	else:
		_save_filepath_pending = filepath
		_do_save_config()

func _do_save_config() -> void:
	if _save_filepath_pending != "":
		save_simulation_config(_save_filepath_pending)
		var saved_path = _save_filepath_pending
		_save_filepath_pending = ""
		_update_load_options()
		_sync_tscn_list_selection(saved_path)
		if _pending_tscn_filepath != "":
			var target_path = _pending_tscn_filepath
			_pending_tscn_filepath = ""
			_pending_tscn_index = -1
			if is_instance_valid(tscn_list):
				var found_idx = -1
				for i in range(tscn_list.item_count):
					var meta = tscn_list.get_item_metadata(i)
					if meta is Dictionary and meta.get("path", "") == target_path:
						found_idx = i
						break
				if found_idx != -1:
					_do_load_tscn_at_index(found_idx)

func _on_rename_tscn_pressed() -> void:
	if not is_instance_valid(tscn_list):
		return
	var selected_items = tscn_list.get_selected_items()
	if selected_items.is_empty():
		if _last_selected_tscn_index != -1 and _last_selected_tscn_index < tscn_list.item_count:
			selected_items = [_last_selected_tscn_index]
	if selected_items.is_empty():
		_show_alert("名前を変更するtscnファイルを一覧から選択してください。")
		return

	var sel_idx = selected_items[0]
	var meta = tscn_list.get_item_metadata(sel_idx)
	if not (meta is Dictionary):
		return

	var old_path = meta.get("path", "") as String
	var old_display = meta.get("display_name", "") as String
	if old_path.is_empty():
		return

	if old_display.to_lower() == "main.tscn":
		_show_alert("main.tscn は保護されているため名前を変更できません。")
		return

	var new_base = line_edit_save_name.text.strip_edges() if is_instance_valid(line_edit_save_name) else ""
	if new_base.is_empty():
		_show_alert("新しいファイル名を入力してください。")
		return
	if new_base.to_lower() == "main" or new_base.to_lower() == "main.tscn":
		_show_alert("main.tscn に変更することはできません。")
		return

	var new_filename = new_base
	if not new_filename.ends_with(".tscn"):
		new_filename += ".tscn"

	if new_filename == old_display:
		return

	var dir_path = old_path.get_base_dir()
	var new_path = dir_path + "/" + new_filename

	if FileAccess.file_exists(new_path):
		_show_alert("既に同名のファイルが存在します: " + new_filename)
		return

	var err = DirAccess.rename_absolute(old_path, new_path)
	if err != OK:
		_show_alert("ファイル名の変更に失敗しました (エラーコード: %d)" % err)
		return

	if _current_tscn_path == old_path:
		_current_tscn_path = new_path
		_save_last_scene_path(new_path)

	_update_load_options()

	for i in range(tscn_list.item_count):
		var m = tscn_list.get_item_metadata(i)
		if m is Dictionary and m.get("path", "") == new_path:
			tscn_list.select(i)
			_last_selected_tscn_index = i
			break
	_update_tscn_selection_label()

var _delete_tscn_confirm_dialog: ConfirmationDialog = null
var _delete_tscn_path_pending: String = ""
var _delete_tscn_display_pending: String = ""

func _on_delete_tscn_pressed() -> void:
	if not is_instance_valid(tscn_list):
		return
	var selected_items = tscn_list.get_selected_items()
	if selected_items.is_empty():
		if _last_selected_tscn_index != -1 and _last_selected_tscn_index < tscn_list.item_count:
			selected_items = [_last_selected_tscn_index]
	if selected_items.is_empty():
		_show_alert("削除するtscnファイルを一覧から選択してください。")
		return

	var sel_idx = selected_items[0]
	var meta = tscn_list.get_item_metadata(sel_idx)
	if not (meta is Dictionary):
		return

	var filepath = meta.get("path", "") as String
	var display_name = meta.get("display_name", "") as String
	if filepath.is_empty():
		return

	if display_name.to_lower() == "main.tscn":
		_show_alert("main.tscn は保護されているため削除できません。")
		return

	_delete_tscn_path_pending = filepath
	_delete_tscn_display_pending = display_name

	if not is_instance_valid(_delete_tscn_confirm_dialog):
		_delete_tscn_confirm_dialog = ConfirmationDialog.new()
		_delete_tscn_confirm_dialog.title = "tscn削除の確認"
		_delete_tscn_confirm_dialog.get_ok_button().text = "削除"
		_delete_tscn_confirm_dialog.get_cancel_button().text = "キャンセル"
		_delete_tscn_confirm_dialog.confirmed.connect(_do_delete_tscn_confirmed)
		add_child(_delete_tscn_confirm_dialog)

	_delete_tscn_confirm_dialog.dialog_text = "「%s」を削除しますか？\n※この操作は取り消せません。" % display_name
	_delete_tscn_confirm_dialog.popup_centered()

func _do_delete_tscn_confirmed() -> void:
	if _delete_tscn_path_pending.is_empty():
		return

	var path = _delete_tscn_path_pending
	var _disp = _delete_tscn_display_pending
	_delete_tscn_path_pending = ""
	_delete_tscn_display_pending = ""

	if not FileAccess.file_exists(path):
		_show_alert("ファイルが見つかりません: " + path)
		_update_load_options()
		return

	var err = DirAccess.remove_absolute(path)
	if err != OK:
		_show_alert("ファイルの削除に失敗しました (エラーコード: %d)" % err)
		return

	if _current_tscn_path == path:
		_current_tscn_path = ""
		_is_modified = false

	_update_load_options()

	if is_instance_valid(tscn_list) and tscn_list.item_count > 0:
		var target_idx = 0
		for i in range(tscn_list.item_count):
			var m = tscn_list.get_item_metadata(i)
			if m is Dictionary and m.get("display_name", "") == "base.tscn":
				target_idx = i
				break
		tscn_list.select(target_idx)
		_last_selected_tscn_index = target_idx
		_do_load_tscn_at_index(target_idx)
	else:
		_last_selected_tscn_index = -1
		if is_instance_valid(line_edit_save_name):
			line_edit_save_name.text = ""
		var new_base = _get_save_dir() + "/base.tscn"
		if _create_empty_base_scene(new_base):
			_update_load_options()
			load_simulation_config(new_base)
	_update_tscn_selection_label()

func _on_load_config_pressed() -> void:
	if option_load_config.item_count > 0:
		var selected_idx = option_load_config.selected
		if selected_idx >= 0:
			var filepath = option_load_config.get_item_metadata(selected_idx)
			load_simulation_config(filepath)

func save_simulation_config(filepath: String) -> void:
	var root_node = _find_assembly_root()
	if not root_node:
		return

	if root_node.name.begins_with("@") or root_node.name.begins_with("_"):
		root_node.name = "Assembly"

	# Stop simulation to ensure clean state
	SimulationManager.reset_simulation()

	# Clean temporary or empty dummy nodes before saving scene
	_clean_assembly_for_tscn_save(root_node)
	
	# Remove ground plane before saving (it will be recreated when loading)
	var grounds = get_all_ground_nodes()
	for g in grounds:
		if is_instance_valid(g) and g.get_parent() == root_node:
			root_node.remove_child(g)
			g.free()

	# Commit current transforms as new baseline initial transforms
	_commit_initial_transforms_recursive(root_node, root_node)

	# Save ground plane state in root_node metadata (only for reference)
	grounds = get_all_ground_nodes()
	var g_vis = false
	var g_y = 0.0
	if not grounds.is_empty() and is_instance_valid(grounds[0]):
		g_vis = grounds[0].visible
		g_y = grounds[0].position.y
	root_node.set_meta("ground_visible", g_vis)
	root_node.set_meta("ground_y", g_y)

	# Set owner for all descendants so PackedScene includes them
	if root_node.has_method("set_owner_recursive"):
		root_node.set_owner_recursive(root_node, root_node)
	else:
		_fallback_set_owner(root_node, root_node)

	var packed := PackedScene.new()
	var err = packed.pack(root_node)
	if err != OK:
		return

	err = ResourceSaver.save(packed, filepath)
	if err == OK:
		_is_modified = false
		_was_just_cleared = false
		_current_tscn_path = filepath
		_last_loaded_scene_path = filepath
		_opened_ground_visible = g_vis
		_opened_ground_y = g_y
		_save_last_scene_path(filepath)


func load_simulation_config(filepath: String) -> void:
	if not FileAccess.file_exists(filepath):
		return

	var packed = ResourceLoader.load(filepath, "PackedScene")
	if not packed or not packed is PackedScene:
		return

	var new_root = packed.instantiate()
	if not new_root:
		return

	if not (new_root is Node3D):
		new_root.queue_free()
		return

	# Immediately restore transforms from metadata before scene tree is set up
	_restore_all_transforms(new_root)

	var root_node = _find_assembly_root()
	if not root_node:
		new_root.free()
		return

	var parent = root_node.get_parent()
	var target_name = root_node.name
	if target_name.begins_with("@") or target_name == "_old_assembly":
		target_name = "Assembly"

	# Ensure old behaviors are unregistered before deleting old root
	SimulationManager.reset_simulation()

	# Remove old root immediately from parent to avoid name collisions
	root_node.name = "_old_assembly"
	if parent:
		parent.remove_child(root_node)
	root_node.queue_free()

	new_root.name = target_name
	if parent:
		parent.add_child(new_root)
	model_root = new_root
	_ensure_collision_bodies_recursive(model_root)
	
	# Restore ground plane state
	var g_vis: bool = true
	var g_y: float = 0.0
	if new_root.has_meta("ground_visible"):
		g_vis = bool(new_root.get_meta("ground_visible"))
		# Always create ground at Y=0 when loading (ignore saved ground_y)
		set_ground_visible(g_vis, 0.0)
	elif new_root.has_meta("ground_y"):
		# Fallback: ground was visible, create at Y=0
		set_ground_visible(true, 0.0)
		g_vis = true
	else:
		# Default: show ground at Y=0
		set_ground_visible(true, 0.0)
		g_vis = true

	_opened_ground_visible = g_vis
	_opened_ground_y = g_y
	_last_loaded_scene_path = filepath

	call_deferred("fit_view_to_all_parts")

	_reset_workspace_state(false)
	_update_ui()
	_update_part_list()
	_is_modified = false
	_current_tscn_path = filepath
	_save_last_scene_path(filepath)
	_sync_tscn_list_selection(filepath)
	if is_instance_valid(line_edit_save_name):
		var fname = filepath.get_file().get_basename()
		if fname != "":
			line_edit_save_name.text = fname


func _clear_draft_state() -> void:
	draft_parts.clear()
	selected_draft_index = -1
	selected_is_group = false
	selected_group_name = ""
	created_parent_groups.clear()
	if is_instance_valid(draft_preview_container):
		for c in draft_preview_container.get_children():
			c.queue_free()
	if is_instance_valid(created_part_list):
		created_part_list.clear()
	_update_created_selection_label()

func _clear_undo_state() -> void:
	if is_instance_valid(last_deleted_part) and last_deleted_part.get_parent() == null:
		last_deleted_part.queue_free()
	last_deleted_part = null
	last_deleted_parent = null
	last_deleted_index = -1

	if is_instance_valid(last_deleted_draft_node) and last_deleted_draft_node.get_parent() == null:
		last_deleted_draft_node.queue_free()
	last_deleted_draft_node = null
	last_deleted_draft.clear()
	last_deleted_draft_index = -1

	if is_instance_valid(btn_undo_delete_part):
		btn_undo_delete_part.disabled = true
	if is_instance_valid(btn_undo_delete_created_part):
		btn_undo_delete_created_part.disabled = true

func _clear_collision_state() -> void:
	for mesh_inst in range_mesh_instances.values():
		if is_instance_valid(mesh_inst):
			mesh_inst.queue_free()
	range_mesh_instances.clear()

func _reset_workspace_state(is_clear_all: bool = false) -> void:
	SimulationManager.reset_simulation()
	_cancel_pivot_picking()
	_clear_undo_state()
	_clear_collision_state()
	_clear_draft_state()
	_set_selected_parts([])
	_mouse_selection_locked = false

	if is_clear_all:
		_current_tscn_path = ""
		_is_modified = false
		_was_just_cleared = true
		if is_instance_valid(line_edit_save_name):
			line_edit_save_name.text = "base"
		if is_instance_valid(tscn_list):
			tscn_list.deselect_all()
		_update_tscn_selection_label()
	else:
		_was_just_cleared = false

func _on_clear_all_pressed() -> void:
	if not is_instance_valid(_clear_all_confirm_dialog):
		_clear_all_confirm_dialog = ConfirmationDialog.new()
		_clear_all_confirm_dialog.title = "モデル全削除の確認"
		_clear_all_confirm_dialog.dialog_text = "【注意】作業空間に配置された全モデル・パーツ、および【作成】タブの作成中モデル（下書きパーツ）をすべて削除します。\n未保存の変更は失われます。\n\n本当にすべて削除しますか？"
		_clear_all_confirm_dialog.get_ok_button().text = "すべて削除"
		_clear_all_confirm_dialog.get_cancel_button().text = "キャンセル"
		_clear_all_confirm_dialog.confirmed.connect(_do_clear_all_confirmed)
		add_child(_clear_all_confirm_dialog)
	_clear_all_confirm_dialog.popup_centered()

func _do_clear_all_confirmed() -> void:
	if is_instance_valid(model_root):
		for child in model_root.get_children():
			model_root.remove_child(child)
			child.queue_free()
		if "initial_transforms" in model_root and model_root.initial_transforms is Dictionary:
			model_root.initial_transforms.clear()
			
	set_ground_visible(false)
	
	if camera and camera.has_method("reset_view"):
		camera.reset_view()
		
	_reset_workspace_state(true)
	
	_update_part_list()
	_update_created_part_list()
	_update_ui()


func _fallback_set_owner(node: Node, root: Node) -> void:
	if node != root:
		if node.name.begins_with("CreatedParts_PreviewContainer") or node.has_meta("is_draft_preview"):
			return
		node.owner = root
	for child in node.get_children():
		_fallback_set_owner(child, root)

func _clean_assembly_for_tscn_save(node: Node) -> void:
	var children = node.get_children()
	for child in children:
		var c_name = child.name
		# 1. プレビュー枠・下書きコンテナの削除
		if c_name.begins_with("CreatedParts_PreviewContainer") or child.has_meta("is_draft_preview"):
			if child == draft_preview_container:
				draft_preview_container = null
			node.remove_child(child)
			child.free()
			continue
		# 2. 一時的なエクスポート用アニメーションプレイヤーの残骸
		if child is AnimationPlayer and c_name == "ExportAnimPlayer":
			node.remove_child(child)
			child.free()
			continue
		# 再帰的に子ノードをクリーンアップ
		_clean_assembly_for_tscn_save(child)
		# 3. メッシュを含まない空のNode3D（空の_Node3D_...や、中身のない空グループ等）
		if child is Node3D and not _has_mesh_recursive(child):
			node.remove_child(child)
			child.free()
			continue

func _commit_initial_transforms_recursive(node: Node, root: Node) -> void:
	for child in node.get_children():
		if child is Node3D and (child.has_meta("generated_by_importer") or _has_mesh_recursive(child)):
			var n3d := child as Node3D
			n3d.set_meta("initial_transform", n3d.transform)
			n3d.set_meta("initial_position", n3d.position)
			n3d.set_meta("initial_rotation", n3d.rotation_degrees)
			# リセット基準を保存時の位置に統一する
			n3d.set_meta("glb_original_transform", n3d.transform)
			n3d.set_meta("glb_original_position", n3d.position)
			n3d.set_meta("glb_original_rotation", n3d.rotation_degrees)
			var bh = _get_part_behavior(n3d)
			if bh:
				bh._initial_parent_transform = n3d.transform
			if is_instance_valid(root) and ("initial_transforms" in root) and root.initial_transforms is Dictionary:
				root.initial_transforms[n3d.name] = n3d.transform
		_commit_initial_transforms_recursive(child, root)


## Restore all part transforms from their stored initial_transform metadata
func _restore_all_transforms(node: Node) -> void:
	for child in node.get_children():
		if child is Node3D and child.has_meta("initial_transform"):
			var n3d := child as Node3D
			var initial_tf: Transform3D = n3d.get_meta("initial_transform")
			n3d.transform = initial_tf
			var bh = _get_part_behavior(n3d)
			if bh:
				bh._initial_parent_transform = initial_tf
			# glb_original_transform がない場合は initial_transform から補完する（旧形式TSCN対応）
			if not n3d.has_meta("glb_original_transform"):
				n3d.set_meta("glb_original_transform", initial_tf)
			if not n3d.has_meta("glb_original_position"):
				if n3d.has_meta("initial_position"):
					n3d.set_meta("glb_original_position", n3d.get_meta("initial_position"))
				else:
					n3d.set_meta("glb_original_position", initial_tf.origin)
			if not n3d.has_meta("glb_original_rotation"):
				if n3d.has_meta("initial_rotation"):
					n3d.set_meta("glb_original_rotation", n3d.get_meta("initial_rotation"))
				else:
					n3d.set_meta("glb_original_rotation", initial_tf.basis.get_euler() * (180.0 / PI))
		_restore_all_transforms(child)


func _find_assembly_root() -> Node3D:
	if is_instance_valid(model_root) and model_root.is_inside_tree() and not model_root.is_queued_for_deletion():
		return model_root
	var paths = [
		"/root/Main/Assembly",
		"/root/Main/SimulationRoot/ModelRoot",
		"/root/Main/node_3d/Assembly",
		"/root/node_3d/Assembly"
	]
	for p in paths:
		var n = get_node_or_null(p)
		if n is Node3D and not n.is_queued_for_deletion():
			return n as Node3D
	var tree = get_tree()
	if tree and tree.root:
		var rec = _find_root_node_recursive(tree.root)
		if rec:
			return rec
	var main_node = get_node_or_null("/root/Main")
	if main_node:
		for child in main_node.get_children():
			if child is Node3D and not child.is_queued_for_deletion():
				if child.name == "Assembly" or child.name.begins_with("Assembly") or child.has_meta("generated_by_importer") or child is AssemblyImporter:
					return child as Node3D
	return null


func _find_root_node_recursive(node: Node) -> Node3D:
	if not is_instance_valid(node) or node.is_queued_for_deletion():
		return null
	if node != get_tree().root and (node is AssemblyImporter or node.name == "Assembly" or node.has_meta("generated_by_importer")):
		return node as Node3D
	for child in node.get_children():
		var found = _find_root_node_recursive(child)
		if found:
			return found
	return null


func _find_camera() -> OrbitCamera:
	var paths = [
		"/root/Main/Camera3D",
		"/root/node_3d/Camera3D",
		"/root/Main/SimulationRoot/Camera3D"
	]
	for p in paths:
		var n = get_node_or_null(p)
		if n is OrbitCamera:
			return n as OrbitCamera
	return _find_camera_recursive(get_tree().root)


func _find_camera_recursive(node: Node) -> OrbitCamera:
	if node is OrbitCamera:
		return node as OrbitCamera
	for child in node.get_children():
		var found = _find_camera_recursive(child)
		if found:
			return found
	return null


func _on_main_tab_changed(tab_idx: int) -> void:
	if SimulationManager.state != SimulationManager.State.IDLE:
		SimulationManager.reset_simulation()

	if not tab_container: return
	var current_tab = tab_container.get_child(tab_idx)
	if current_tab.name == "ファイル":
		if is_instance_valid(tscn_list): tscn_list.show()
		if is_instance_valid(part_list): part_list.hide()
		if is_instance_valid(created_part_list): created_part_list.hide()
		if is_instance_valid(lbl_selected_part_name): lbl_selected_part_name.show()
	elif current_tab.name == "配置" or current_tab.name == "動作":
		if is_instance_valid(part_list): part_list.show()
		if is_instance_valid(tscn_list): tscn_list.hide()
		if is_instance_valid(created_part_list): created_part_list.hide()
		if is_instance_valid(lbl_selected_part_name): lbl_selected_part_name.show()
	elif current_tab.name == "作成":
		if is_instance_valid(created_part_list): created_part_list.show()
		if is_instance_valid(part_list): part_list.hide()
		if is_instance_valid(tscn_list): tscn_list.hide()
		if is_instance_valid(lbl_selected_part_name): lbl_selected_part_name.show()
	else:
		if is_instance_valid(part_list): part_list.hide()
		if is_instance_valid(tscn_list): tscn_list.hide()
		if is_instance_valid(created_part_list): created_part_list.hide()
		if is_instance_valid(lbl_selected_part_name): lbl_selected_part_name.hide()

	if current_tab.name == "作成":
		_update_created_mesh_preview()
	_update_ui()


func _clean_tree_for_glb_export(node: Node, dup_root: Node, orig_root: Node, trans_mat: Material) -> void:
	var children = node.get_children()
	for child in children:
		var c_name: String = child.name
		
		# 1. Skip Export Animation Player
		if child is AnimationPlayer and c_name == "ExportAnimPlayer":
			continue
			
		# 2. Delete preview container and draft previews
		if c_name.begins_with("CreatedParts_PreviewContainer") or child.has_meta("is_draft_preview"):
			node.remove_child(child)
			child.free()
			continue

		# 3. Delete behaviors
		if child is ModelBehavior or c_name.begins_with("MotionBehavior"):
			node.remove_child(child)
			child.free()
			continue

		# 4. Delete collision areas, collision shapes, static body colliders, and helper camera/lights
		if child is Area3D or child is CollisionShape3D or child is StaticBody3D or child is Camera3D or child is Light3D or c_name.begins_with("CollisionArea") or c_name.begins_with("CollisionShape") or c_name.ends_with("_col"):
			node.remove_child(child)
			child.free()
			continue


		# 5. Check visual state and visibility against original tree
		var orig_child: Node = null
		if is_instance_valid(orig_root):
			var rel_path = dup_root.get_path_to(child)
			orig_child = orig_root.get_node_or_null(rel_path)
			if not orig_child:
				orig_child = orig_root.get_node_or_null(c_name)

		var state = VS_OPAQUE
		if is_instance_valid(orig_child) and orig_child is Node3D:
			if orig_root.has_method("get_child_visual_state"):
				state = orig_root.call("get_child_visual_state", orig_child)
			else:
				state = VS_OPAQUE if orig_child.visible else VS_HIDDEN
		elif child is Node3D and not child.visible:
			state = VS_HIDDEN

		if state == VS_HIDDEN:
			node.remove_child(child)
			child.free()
			continue
		elif state == VS_TRANSPARENT:
			_apply_transparent_override_recursive(child, trans_mat)

		# Recurse into children
		_clean_tree_for_glb_export(child, dup_root, orig_root, trans_mat)

		# 6. Delete empty Node3Ds that contain no meshes (e.g. empty dummy nodes, empty groups)
		if child is Node3D and child != dup_root and not _has_mesh_recursive(child):
			node.remove_child(child)
			child.free()
			continue


# -------------------------------------------------------------------
# Creation Tab Logic (PNG to 3D Extrusion & Multi-Part/Group Support)
# -------------------------------------------------------------------

func _show_alert_dialog(title: String, message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.min_size = Vector2i(380, 120)
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered()


func _on_import_image_pressed() -> void:
	if image_file_dialog:
		image_file_dialog.popup_centered_ratio(0.7)


func _collect_all_node_names(node: Node, out_names: Dictionary) -> void:
	if not is_instance_valid(node):
		return
	for child in node.get_children():
		out_names[child.name] = true
		_collect_all_node_names(child, out_names)

func _generate_unique_name_from_dict(base_name: String, used_names: Dictionary) -> String:
	if not used_names.has(base_name):
		return base_name
	var prefix := base_name
	var counter := 2
	var regex := RegEx.new()
	if regex.compile("^(.*)_(\\d+)$") == OK:
		var match_result = regex.search(base_name)
		if match_result:
			prefix = match_result.get_string(1)
			counter = match_result.get_string(2).to_int() + 1

	while true:
		var candidate := "%s_%d" % [prefix, counter]
		if not used_names.has(candidate):
			return candidate
		counter += 1
	return base_name


func _on_image_file_selected(path: String) -> void:
	var img := Image.load_from_file(path)
	if not img or img.is_empty():
		_show_alert_dialog("読み込みエラー", "画像の読み込みに失敗しました。\nファイルパスまたは画像形式を確認してください:\n" + path)
		return
	
	# 1. フォーマット正規化（RGBA8）
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	
	# 2. 高解像度画像の自動ダウンサンプリング（最大1024pxでフリーズ防止）
	var max_dim = 1024
	if img.get_width() > max_dim or img.get_height() > max_dim:
		var orig_w = img.get_width()
		var orig_h = img.get_height()
		var scale_factor = float(max_dim) / float(max(orig_w, orig_h))
		var new_w = max(int(orig_w * scale_factor), 1)
		var new_h = max(int(orig_h * scale_factor), 1)
		img.resize(new_w, new_h, Image.INTERPOLATE_BILINEAR)
	
	current_raw_img = img
	
	var base_target_size = 1.0
	
	var all_raw_contours = _extract_all_black_contours(img)
	if all_raw_contours.is_empty():
		_show_alert_dialog("検出エラー", "画像から有効な黒色領域が検出されませんでした。\n背景が白で描画された線画・イラストを指定してください。")
		return

	# 検出輪郭数の上限キャップ（最大30件）
	var max_parts = 30
	if all_raw_contours.size() > max_parts:
		all_raw_contours = all_raw_contours.slice(0, max_parts)
		_show_alert_dialog("パーツ数制限", "検出された輪郭数が多いため、面積の大きい主要な上位 %d 件のみを取り込みました。" % max_parts)

	var file_name = path.get_file().get_basename()
	if file_name.is_empty():
		file_name = "part"
	
	draft_parts.clear()
	selected_draft_index = -1
	selected_is_group = false
	selected_group_name = ""

	var default_depth = 0.1
	if is_instance_valid(spin_create_depth):
		spin_create_depth.value = default_depth
	var default_tol = spin_create_tolerance.value if spin_create_tolerance else 1.0

	# 1. Compute bounding box maximum dimensions and centers for all contours for relative scaling & layout
	var count = all_raw_contours.size()
	var contour_max_dims: Array[float] = []
	var contour_centers: Array[Vector2] = []
	var global_max_dim: float = 0.0001
	var union_min := Vector2(INF, INF)
	var union_max := Vector2(-INF, -INF)
	
	for raw_pts_any in all_raw_contours:
		var raw_pts = raw_pts_any as Array
		if raw_pts.is_empty():
			contour_max_dims.append(0.0)
			contour_centers.append(Vector2.ZERO)
			continue
		var min_p = raw_pts[0] as Vector2
		var max_p = raw_pts[0] as Vector2
		for p_any in raw_pts:
			var p = p_any as Vector2
			min_p.x = min(min_p.x, p.x); min_p.y = min(min_p.y, p.y)
			max_p.x = max(max_p.x, p.x); max_p.y = max(max_p.y, p.y)
		var dim = max(float(max_p.x - min_p.x + 1), float(max_p.y - min_p.y + 1))
		contour_max_dims.append(dim)
		contour_centers.append((min_p + max_p) * 0.5)
		if dim > global_max_dim:
			global_max_dim = dim
		union_min.x = min(union_min.x, min_p.x)
		union_min.y = min(union_min.y, min_p.y)
		union_max.x = max(union_max.x, max_p.x)
		union_max.y = max(union_max.y, max_p.y)

	var union_center = (union_min + union_max) * 0.5 if count > 0 else Vector2.ZERO
	var scale_factor = base_target_size / global_max_dim if global_max_dim > 0.0 else 1.0

	# Collect all existing node names from root and any drafts to prevent collisions
	var root = _find_assembly_root()
	var used_names: Dictionary = {}
	if is_instance_valid(root):
		_collect_all_node_names(root, used_names)
	for d in draft_parts:
		if d is Dictionary and d.has("name"):
			used_names[d["name"]] = true

	# 2. Build draft parts with relative sizes, preserved image layout, and unique palette colors
	for i in range(count):
		var raw_name = file_name if count == 1 else "%s_%d" % [file_name, i + 1]
		var part_name = _generate_unique_name_from_dict(raw_name, used_names)
		used_names[part_name] = true
		var raw_pts: Array[Vector2] = []
		for p in all_raw_contours[i]:
			raw_pts.append(p)
			
		var contour_pts = _process_contour_points(raw_pts)
		
		# Proportional size calculation: largest contour gets base_target_size (1.0), others scale proportionally
		var ratio = contour_max_dims[i] / global_max_dim if global_max_dim > 0 else 1.0
		var item_size = base_target_size * ratio
		
		# Assign unique distinct color from HSV palette so parts are easily distinguishable
		var hue = float(i) / float(max(count, 1))
		var auto_color = Color.from_hsv(hue, 0.75, 0.95)
		
		# Preserve relative layout from the original image (X right, Y up in 3D)
		var rel_offset = (contour_centers[i] - union_center) * scale_factor
		var initial_pos = Vector3(rel_offset.x, -rel_offset.y, 0.0)
		
		draft_parts.append({
			"name": part_name,
			"raw_points": raw_pts,
			"contour": contour_pts,
			"color": auto_color,
			"depth": default_depth,
			"size": item_size,
			"initial_size": item_size,
			"tolerance": default_tol,
			"position": initial_pos,
			"initial_position": initial_pos,
			"rotation": Vector3.ZERO,
			"parent_name": "",
			"inserted": false,
			"node": null
		})

	# 3. Calculate overall minimum Y so all models sit entirely above ground line while preserving relative layout
	var overall_min_y: float = INF
	for draft in draft_parts:
		var c_pts = draft["contour"] as Array[Vector2]
		var c_size = draft["size"] as float
		var pos_y = draft["position"].y as float
		for pt in c_pts:
			var pt_y = pos_y + pt.y * c_size
			if pt_y < overall_min_y:
				overall_min_y = pt_y
	
	if is_inf(overall_min_y):
		overall_min_y = 0.0

	var ground_y = _get_ground_y()
	var lift_y = ground_y - overall_min_y
	for draft in draft_parts:
		var p: Vector3 = draft["position"]
		p.y += lift_y
		draft["position"] = p
		draft["initial_position"] = p
	
	_update_parent_options()
	_update_created_part_list()
	
	if not draft_parts.is_empty():
		if is_instance_valid(created_part_list):
			created_part_list.select(0)
		_on_created_part_list_item_selected(0)

	# PNG読み込み後は既存モデルを自動的に非表示にする
	if is_instance_valid(check_hide_existing):
		check_hide_existing.set_block_signals(true)
		check_hide_existing.button_pressed = false
		check_hide_existing.set_block_signals(false)
		_on_check_hide_existing_toggled(false)

	call_deferred("fit_view_to_all_parts")


func _on_tolerance_changed() -> void:
	if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
		var draft = draft_parts[selected_draft_index]
		draft["tolerance"] = spin_create_tolerance.value if spin_create_tolerance else 1.0
		draft["contour"] = _process_contour_points(draft["raw_points"])
		current_contour_points = draft["contour"]
		_on_create_param_changed()


## 作成リストで選択中の全ドラフトのインデックスを返す
func _get_selected_draft_indices() -> Array[int]:
	var indices: Array[int] = []
	if not is_instance_valid(created_part_list):
		return indices
	for list_idx in created_part_list.get_selected_items():
		var m = created_part_list.get_item_metadata(list_idx) as Dictionary
		if m:
			if not m.get("is_group", false):
				var di = m.get("index", -1) as int
				if di >= 0 and di < draft_parts.size():
					if not indices.has(di):
						indices.append(di)
			else:
				var g_name = m.get("name", "") as String
				if not g_name.is_empty():
					for di in range(draft_parts.size()):
						if draft_parts[di].get("parent_name", "") == g_name:
							if not indices.has(di):
								indices.append(di)
	# 主選択が含まれていない場合は追加
	if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
		if not indices.has(selected_draft_index):
			indices.append(selected_draft_index)
	elif selected_is_group and not selected_group_name.is_empty():
		for di in range(draft_parts.size()):
			if draft_parts[di].get("parent_name", "") == selected_group_name:
				if not indices.has(di):
					indices.append(di)
	return indices

func _on_create_param_changed() -> void:
	"""Called when any parameters (Color, Depth, Size, Pos SpinBoxes, Rot SpinBoxes, Scale SpinBoxes) are tweaked."""
	if selected_is_group or selected_draft_index < 0 or selected_draft_index >= draft_parts.size():
		return
	
	var primary_draft = draft_parts[selected_draft_index]
	
	# カラー・奥行き・サイズは主選択のみに適用（形状パラメータ）
	if spin_create_depth: primary_draft["depth"] = spin_create_depth.value
	if spin_create_size: primary_draft["size"] = spin_create_size.value
	if color_picker_create: primary_draft["color"] = color_picker_create.color
	
	# 位置・回転・スケールは選択中の全ドラフトに適用
	var new_pos = Vector3.ZERO
	if spin_create_pos_x: new_pos.x = spin_create_pos_x.value
	if spin_create_pos_y: new_pos.y = spin_create_pos_y.value
	if spin_create_pos_z: new_pos.z = spin_create_pos_z.value
	
	var new_rot = Vector3.ZERO
	if spin_create_rot_x: new_rot.x = spin_create_rot_x.value
	if spin_create_rot_y: new_rot.y = spin_create_rot_y.value
	if spin_create_rot_z: new_rot.z = spin_create_rot_z.value
	
	var new_scl = Vector3.ONE
	if spin_create_scale_x: new_scl.x = spin_create_scale_x.value
	if spin_create_scale_y: new_scl.y = spin_create_scale_y.value
	if spin_create_scale_z: new_scl.z = spin_create_scale_z.value
	
	# 主選択の位置デルタを計算（他の選択への相対移動に使用）
	var primary_old_pos: Vector3 = primary_draft.get("position", Vector3.ZERO)
	var pos_delta = new_pos - primary_old_pos
	
	var selected_indices = _get_selected_draft_indices()
	for di in selected_indices:
		var draft = draft_parts[di]
		if di == selected_draft_index:
			# 主選択はスピンボックスの値をそのまま適用
			draft["position"] = new_pos
			draft["rotation"] = new_rot
			draft["scale"] = new_scl
		else:
			# 複数選択の他パーツにはデルタ移動を適用、回転・スケールは同じ値を設定
			draft["position"] = draft.get("position", Vector3.ZERO) + pos_delta
			draft["rotation"] = new_rot
			draft["scale"] = new_scl
		# 挿入済みノードにも即時反映
		if draft.get("inserted", false) and is_instance_valid(draft.get("node")):
			var node = draft["node"] as Node3D
			node.position = draft["position"]
			node.rotation_degrees = draft["rotation"]
			node.scale = draft["scale"]
			if di == selected_draft_index:
				# 主選択のみメッシュ・マテリアルも更新
				var vis_mesh: MeshInstance3D = null
				for child in node.get_children():
					if child is MeshInstance3D:
						vis_mesh = child
						break
				if vis_mesh:
					var new_mesh = _generate_extruded_mesh(draft["contour"], draft["depth"], draft["size"], draft["color"])
					if new_mesh:
						vis_mesh.mesh = new_mesh
						var mat = StandardMaterial3D.new()
						mat.albedo_color = draft["color"]
						mat.roughness = 0.4
						mat.metallic = 0.1
						mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
						vis_mesh.material_override = mat
	
	current_contour_points = primary_draft["contour"]
	
	# Update draft previews in main viewport
	_update_created_mesh_preview()


func _create_new_blank_parent() -> String:
	"""Create a new empty parent Node3D in assembly root and return its name."""
	var root = _find_assembly_root()
	if not root: return ""
	
	var p_count = created_parent_groups.size() + 1
	var parent_name = "group_%d" % p_count
	while created_parent_groups.has(parent_name) or (root and root.has_node(parent_name)):
		p_count += 1
		parent_name = "group_%d" % p_count

	var p_node := Node3D.new()
	p_node.name = parent_name
	p_node.set_meta("generated_by_importer", true)
	p_node.set_meta("is_created_parent", true)
	p_node.set_meta("initial_transform", Transform3D.IDENTITY)
	p_node.set_meta("initial_position", Vector3.ZERO)
	p_node.set_meta("initial_rotation", Vector3.ZERO)
	
	root.add_child(p_node)
	
	if not created_parent_groups.has(parent_name):
		created_parent_groups.append(parent_name)

	return parent_name


func _update_parent_options() -> void:
	"""Update the parent dropdown option list including '➕ 新規追加' and all created parent groups."""
	if not is_instance_valid(option_create_parent):
		return
	option_create_parent.clear()
	option_create_parent.add_item("(なし / 独立パーツ)", 0)
	option_create_parent.add_item("➕ 新規追加", 1)
	
	var groups_list: Array[String] = []
	for g in created_parent_groups:
		if not groups_list.has(g):
			groups_list.append(g)
			
	var root = _find_assembly_root()
	if root:
		for child in root.get_children():
			if child is Node3D and (child.has_meta("is_created_parent") or (child.has_meta("generated_by_importer") and not child.has_meta("is_created_part"))):
				if not groups_list.has(child.name):
					groups_list.append(child.name)
					
	var idx = 2
	for g_name in groups_list:
		option_create_parent.add_item(g_name, idx)
		idx += 1


func _on_create_parent_option_selected(idx: int) -> void:
	# Item index 1 corresponds to "➕ 新規追加"
	if idx == 1:
		var new_p_name = _create_new_blank_parent()
		if not new_p_name.is_empty():
			if not selected_is_group and selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
				draft_parts[selected_draft_index]["parent_name"] = new_p_name
				
			_update_parent_options()
			
			# Select newly created group in list so user can immediately rename it
			selected_is_group = true
			selected_group_name = new_p_name
			selected_draft_index = -1
			if is_instance_valid(line_edit_create_name):
				line_edit_create_name.text = new_p_name
				
			_update_created_part_list()
			_update_part_list()
		return

	if selected_is_group or selected_draft_index < 0 or selected_draft_index >= draft_parts.size():
		return
	
	var draft = draft_parts[selected_draft_index]
	var parent_name = ""
	if idx > 1 and option_create_parent:
		parent_name = option_create_parent.get_item_text(idx)
	
	draft["parent_name"] = parent_name
	
	# If already inserted, re-parent in node tree
	if draft["inserted"] and is_instance_valid(draft["node"]):
		var node = draft["node"] as Node3D
		var root = _find_assembly_root()
		if not root: return
		
		var target_parent: Node3D = root
		if not parent_name.is_empty():
			var p_node = root.get_node_or_null(parent_name) as Node3D
			if is_instance_valid(p_node):
				target_parent = p_node
				
		if node.get_parent() != target_parent:
			node.reparent(target_parent)
			
	_update_created_part_list()
	_update_part_list()


func _set_node_collision_enabled_recursive(node: Node, enabled: bool) -> void:
	if not is_instance_valid(node): return
	if node is CollisionShape3D:
		node.disabled = not enabled
	elif node is CollisionObject3D:
		node.collision_layer = 1 if enabled else 0
		node.collision_mask = 1 if enabled else 0
	for c in node.get_children():
		_set_node_collision_enabled_recursive(c, enabled)

func _is_node_in_current_draft(node: Node) -> bool:
	if not is_instance_valid(node):
		return false
	for draft in draft_parts:
		if draft.get("inserted") and is_instance_valid(draft.get("node")):
			var n: Node = draft["node"]
			if n == node or node.is_ancestor_of(n):
				return true
	return false

func _get_part_visual_state(part: Node3D) -> int:
	if not is_instance_valid(part):
		return VS_OPAQUE
	if part.has_meta("visual_state"):
		return part.get_meta("visual_state")
	if is_instance_valid(model_root) and model_root.has_method("get_child_visual_state"):
		return model_root.call("get_child_visual_state", part)
	return VS_OPAQUE if part.visible else VS_HIDDEN

func _apply_visibility_to_workspace_nodes(node: Node, toggled_on: bool) -> void:
	for child in node.get_children():
		if child is Node3D and child != draft_preview_container and not child.has_meta("is_draft_preview"):
			if _is_node_in_current_draft(child):
				child.visible = true
				_set_node_collision_enabled_recursive(child, true)
				_apply_visibility_to_workspace_nodes(child, toggled_on)
			else:
				if not toggled_on:
					child.visible = false
					_set_node_collision_enabled_recursive(child, false)
				else:
					var state = _get_part_visual_state(child)
					var should_show = (state != VS_HIDDEN) and not child.get_meta("is_deleted", false)
					child.visible = should_show
					_set_node_collision_enabled_recursive(child, should_show)

func _on_check_hide_existing_toggled(toggled_on: bool) -> void:
	var root = _find_assembly_root()
	if not root: return
	_apply_visibility_to_workspace_nodes(root, toggled_on)

	for g in get_all_ground_nodes():
		if is_instance_valid(g):
			if not toggled_on:
				g.visible = false
				_set_node_collision_enabled_recursive(g, false)
			else:
				var g_state = _get_part_visual_state(g)
				var should_show = (g_state != VS_HIDDEN) and not g.get_meta("is_deleted", false)
				g.visible = should_show
				_set_node_collision_enabled_recursive(g, should_show)

	if is_instance_valid(check_hide_existing):
		check_hide_existing.text = "既存モデル（表示）" if check_hide_existing.button_pressed else "既存モデル（非表示）"


func _calculate_assembly_aabb_size() -> float:
	var root = _find_assembly_root()
	if not root:
		return 1.0
	
	var has_mesh = false
	var combined_aabb := AABB()
	
	var nodes := [root]
	while not nodes.is_empty():
		var n: Node = nodes.pop_back()
		if n is MeshInstance3D and n.visible and n != draft_preview_container and not n.has_meta("is_draft_preview"):
			var m_instance = n as MeshInstance3D
			if m_instance.mesh:
				var local_aabb = m_instance.get_aabb()
				var global_trans = m_instance.global_transform
				for i in range(8):
					var corner = local_aabb.get_endpoint(i)
					var g_corner = global_trans * corner
					if not has_mesh:
						combined_aabb = AABB(g_corner, Vector3.ZERO)
						has_mesh = true
					else:
						combined_aabb = combined_aabb.expand(g_corner)
		for c in n.get_children():
			nodes.append(c)
	
	if not has_mesh or combined_aabb.size.length() < 0.0001:
		return 1.0
	
	return max(combined_aabb.size.x, max(combined_aabb.size.y, combined_aabb.size.z))


# Extract ALL disconnected black islands from Image with noise filtering and area sorting
func _extract_all_black_contours(img: Image) -> Array:
	var w = img.get_width()
	var h = img.get_height()
	
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
		
	var raw_bytes: PackedByteArray = img.get_data()
	var total_pixels = w * h
	if raw_bytes.size() < total_pixels * 4:
		return []

	# 高速黒判定（アンチエイリアス対応：白背景ブレンド合成輝度 < 0.55）
	var is_black := func(x: int, y: int) -> bool:
		if x < 0 or x >= w or y < 0 or y >= h: return false
		var offset = (y * w + x) * 4
		var a_byte = raw_bytes[offset + 3]
		if a_byte < 32:
			return false
		var a_f = float(a_byte) / 255.0
		var r_byte = raw_bytes[offset]
		var g_byte = raw_bytes[offset + 1]
		var b_byte = raw_bytes[offset + 2]
		var rgb_f = float(r_byte + g_byte + b_byte) / (3.0 * 255.0)
		var eff_brightness = rgb_f * a_f + (1.0 - a_f)
		return eff_brightness < 0.55

	var visited := PackedByteArray()
	visited.resize(total_pixels)
	visited.fill(0)
	
	var candidates: Array = []
	var dirs = [
		Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1)
	]
	
	for y in range(h):
		for x in range(w):
			var idx = y * w + x
			if visited[idx] != 0:
				continue
			
			if is_black.call(x, y):
				var raw_pts: Array[Vector2] = []
				var curr_x = x
				var curr_y = y
				var backtrack_dir = 0
				var iter = 0
				var max_iter = total_pixels
				
				raw_pts.append(Vector2(curr_x, curr_y))
				visited[curr_y * w + curr_x] = 1
				
				while iter < max_iter:
					iter += 1
					var found_next = false
					for i in range(8):
						var d_idx = (backtrack_dir + i) % 8
						var nx = curr_x + dirs[d_idx].x
						var ny = curr_y + dirs[d_idx].y
						if is_black.call(nx, ny):
							curr_x = nx
							curr_y = ny
							raw_pts.append(Vector2(curr_x, curr_y))
							visited[curr_y * w + curr_x] = 1
							backtrack_dir = (d_idx + 5) % 8
							found_next = true
							break
					if not found_next or (curr_x == x and curr_y == y):
						break
				
				# BFSで内部を塗りつぶし、再走査をスキップ
				var queue: Array[Vector2i] = [Vector2i(x, y)]
				while not queue.is_empty():
					var p = queue.pop_back()
					for d in dirs:
						var nx = p.x + d.x
						var ny = p.y + d.y
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							var n_idx = ny * w + nx
							if visited[n_idx] == 0 and is_black.call(nx, ny):
								visited[n_idx] = 1
								queue.append(Vector2i(nx, ny))
				
				# ノイズ除外フィルタ: 頂点数8以上かつバウンディングボックス幅・高さが有意なもの
				if raw_pts.size() >= 8:
					var min_px = raw_pts[0].x
					var max_px = raw_pts[0].x
					var min_py = raw_pts[0].y
					var max_py = raw_pts[0].y
					for pt in raw_pts:
						if pt.x < min_px: min_px = pt.x
						elif pt.x > max_px: max_px = pt.x
						if pt.y < min_py: min_py = pt.y
						elif pt.y > max_py: max_py = pt.y
					var bb_w = max_px - min_px + 1
					var bb_h = max_py - min_py + 1
					if bb_w >= 4 and bb_h >= 4:
						candidates.append({
							"points": raw_pts,
							"area": bb_w * bb_h
						})
	
	# 面積の大きい順にソート（重要なパーツが先頭に来る）
	candidates.sort_custom(func(a, b): return a["area"] > b["area"])
	
	var all_raw_contours: Array = []
	for c in candidates:
		all_raw_contours.append(c["points"])
	
	return all_raw_contours


# Simplify and normalize contour points
func _process_contour_points(raw_points: Array[Vector2]) -> Array[Vector2]:
	if raw_points.size() < 3:
		return []

	var tol_val = spin_create_tolerance.value if spin_create_tolerance else 1.0
	var simplified: Array[Vector2] = []
	
	if tol_val <= 0.05:
		simplified = raw_points
	else:
		var epsilon = tol_val * 1.5
		simplified = _rdp_simplify(raw_points, epsilon)
	
	if simplified.size() < 3:
		simplified = raw_points

	var min_p = simplified[0]
	var max_p = simplified[0]
	for p in simplified:
		min_p.x = min(min_p.x, p.x)
		min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x)
		max_p.y = max(max_p.y, p.y)

	var bbox_width = float(max_p.x - min_p.x + 1)
	var bbox_height = float(max_p.y - min_p.y + 1)
	var max_dim = max(bbox_width, bbox_height)
	var center = (min_p + max_p) * 0.5
	
	var normalized_points: Array[Vector2] = []
	for p in simplified:
		var norm_p = (p - center) / max_dim
		norm_p.y = -norm_p.y
		normalized_points.append(norm_p)
		
	return normalized_points


func _rdp_simplify(points: Array[Vector2], epsilon: float) -> Array[Vector2]:
	if points.size() <= 2:
		return points
	
	var out: Array[Vector2] = []
	_rdp_rec(points, 0, points.size() - 1, epsilon, out)
	out.append(points[points.size() - 1])
	return out


func _rdp_rec(points: Array[Vector2], start_idx: int, end_idx: int, epsilon: float, out_points: Array[Vector2]) -> void:
	var dmax = 0.0
	var index = start_idx
	var p1 = points[start_idx]
	var p2 = points[end_idx]
	
	for i in range(start_idx + 1, end_idx):
		var d = _perpendicular_distance(points[i], p1, p2)
		if d > dmax:
			index = i
			dmax = d
			
	if dmax > epsilon:
		_rdp_rec(points, start_idx, index, epsilon, out_points)
		_rdp_rec(points, index, end_idx, epsilon, out_points)
	else:
		out_points.append(p1)


func _perpendicular_distance(p: Vector2, p1: Vector2, p2: Vector2) -> float:
	var diff = p2 - p1
	if diff.length_squared() == 0.0:
		return p.distance_to(p1)
	var num = abs(diff.y * p.x - diff.x * p.y + p2.x * p1.y - p2.y * p1.x)
	var den = diff.length()
	return num / den


func _generate_extruded_mesh(points: Array[Vector2], depth: float, target_size: float, color: Color) -> Mesh:
	if points.size() < 3:
		return null

	var scaled_pts := PackedVector2Array()
	for p in points:
		scaled_pts.append(p * target_size)

	var csg := CSGPolygon3D.new()
	csg.mode = CSGPolygon3D.MODE_DEPTH
	csg.depth = depth
	csg.polygon = scaled_pts

	# 一時的にツリーへ追加してベイクし、queue_free() で通常のノード終了経路から解放する
	var bake_parent: Node = _find_assembly_root()
	if not is_instance_valid(bake_parent):
		bake_parent = get_tree().root
	bake_parent.add_child(csg)
	csg._update_shape()

	var mesh: Mesh = null
	var meshes = csg.get_meshes()
	if meshes.size() >= 2 and meshes[1] is Mesh:
		mesh = meshes[1].duplicate()

	bake_parent.remove_child(csg)
	csg.free()

	if not mesh:
		return null

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_BACK
	mat.roughness = 0.4
	mat.metallic = 0.1
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	if mesh is ArrayMesh:
		for i in range(mesh.get_surface_count()):
			mesh.surface_set_material(i, mat)

	return mesh


func _update_created_mesh_preview() -> void:
	"""Update simultaneous 3D previews for ALL imported draft parts."""
	var root = _find_assembly_root()
	if not root:
		return

	if not is_instance_valid(draft_preview_container):
		draft_preview_container = Node3D.new()
		draft_preview_container.name = "CreatedParts_PreviewContainer"
		draft_preview_container.set_meta("is_draft_preview", true)
		root.add_child(draft_preview_container)
	else:
		for c in draft_preview_container.get_children():
			draft_preview_container.remove_child(c)
			c.free()

	for i in range(draft_parts.size()):
		var draft = draft_parts[i]
		if draft["inserted"]:
			continue  # Inserted parts are rendered by their actual workspace nodes
			
		var pts = draft["contour"] as Array[Vector2]
		if pts.is_empty():
			continue
			
		var mesh = _generate_extruded_mesh(pts, draft["depth"], draft["size"], draft["color"])
		if not mesh:
			continue
			
		var m_inst := MeshInstance3D.new()
		m_inst.name = "Preview_" + draft["name"]
		m_inst.mesh = mesh
		m_inst.position = draft["position"]
		m_inst.rotation_degrees = draft["rotation"]
		m_inst.scale = draft.get("scale", Vector3.ONE)
		
		var is_selected = (not selected_is_group and i == selected_draft_index)
		var alpha = 0.95 if is_selected else 0.6
		var col: Color = draft["color"]
		
		var preview_mat = StandardMaterial3D.new()
		preview_mat.albedo_color = Color(col.r, col.g, col.b, alpha)
		preview_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		if is_selected:
			preview_mat.emission_enabled = true
			preview_mat.emission = Color(col.r * 0.4, col.g * 0.4, col.b * 0.4)
			
		m_inst.material_override = preview_mat
		m_inst.set_meta("is_draft_preview", true)
		m_inst.set_meta("draft_index", i)
		m_inst.create_trimesh_collision()
		var cur_tab_name = ""
		if is_instance_valid(tab_container) and tab_container.get_child_count() > tab_container.current_tab:
			var cur_t = tab_container.get_child(tab_container.current_tab)
			if cur_t: cur_tab_name = cur_t.name
		var col_enabled = (cur_tab_name == "作成")
		for c in m_inst.get_children():
			if c is StaticBody3D:
				c.set_meta("is_draft_preview", true)
				c.set_meta("draft_index", i)
				_set_node_collision_enabled_recursive(c, col_enabled)
		draft_preview_container.add_child(m_inst)


## 未挿入ドラフトのプレビューノード（MeshInstance3D）を取得する
func _get_draft_preview_node(draft_idx: int) -> Node3D:
	if not is_instance_valid(draft_preview_container):
		return null
	for child in draft_preview_container.get_children():
		if child.has_meta("draft_index") and child.get_meta("draft_index") == draft_idx:
			return child as Node3D
	return null


func _update_created_part_list() -> void:
	"""Build hierarchical tree list with parent groups and indented child parts (uninserted only)."""
	if not is_instance_valid(created_part_list):
		return
	created_part_list.clear()
	
	var root = _find_assembly_root()
	var parent_groups: Array[String] = []
	if root:
		for child in root.get_children():
			if child is Node3D and child.has_meta("is_created_parent"):
				parent_groups.append(child.name)
				
	for draft in draft_parts:
		var pn = draft.get("parent_name", "") as String
		if not pn.is_empty() and not parent_groups.has(pn):
			parent_groups.append(pn)
			
	# 1. Add Parent Groups and their uninserted child parts
	for p_name in parent_groups:
		var uninserted_children: Array[int] = []
		var total_children_count := 0
		for i in range(draft_parts.size()):
			var draft = draft_parts[i]
			if draft.get("parent_name", "") == p_name:
				total_children_count += 1
				if not draft.get("inserted", false):
					uninserted_children.append(i)

		# 配下パーツがすべて挿入済みのグループはリストに表示しない
		if total_children_count > 0 and uninserted_children.is_empty():
			continue

		var g_label = "📁 [グループ] " + p_name
		var g_idx = created_part_list.add_item(g_label)
		created_part_list.set_item_metadata(g_idx, {"is_group": true, "name": p_name})
		
		for i in uninserted_children:
			var draft = draft_parts[i]
			var label = "    └ [未挿入] %s" % draft["name"]
			var c_idx = created_part_list.add_item(label)
			created_part_list.set_item_metadata(c_idx, {"is_group": false, "index": i})
				
	# 2. Add Independent Parts (parent_name == "", uninserted only)
	for i in range(draft_parts.size()):
		var draft = draft_parts[i]
		if draft.get("parent_name", "").is_empty():
			if draft.get("inserted", false):
				continue
			var label = "[未挿入] %s" % draft["name"]
			var c_idx = created_part_list.add_item(label)
			created_part_list.set_item_metadata(c_idx, {"is_group": false, "index": i})
	
	# Restore selection
	var selection_found := false
	if selected_is_group:
		for i in range(created_part_list.item_count):
			var meta = created_part_list.get_item_metadata(i) as Dictionary
			if meta and meta.get("is_group", false) and meta.get("name", "") == selected_group_name:
				created_part_list.select(i)
				selection_found = true
				break
	elif selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
		if not draft_parts[selected_draft_index].get("inserted", false):
			for i in range(created_part_list.item_count):
				var meta = created_part_list.get_item_metadata(i) as Dictionary
				if meta and not meta.get("is_group", false) and meta.get("index", -1) == selected_draft_index:
					created_part_list.select(i)
					selection_found = true
					break

	if not selection_found:
		selected_is_group = false
		selected_group_name = ""
		selected_draft_index = -1
		if is_instance_valid(line_edit_create_name):
			line_edit_create_name.text = ""
				
	_update_created_selection_label()


func _update_created_selection_label() -> void:
	if not is_instance_valid(lbl_selected_part_name):
		return
	if selected_is_group:
		lbl_selected_part_name.text = "選択: " + selected_group_name + " [グループ]"
	elif selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
		lbl_selected_part_name.text = "選択: " + draft_parts[selected_draft_index]["name"]
	else:
		lbl_selected_part_name.text = "選択: なし (リストで選択)"


func _on_created_part_list_item_selected(index: int) -> void:
	# Shift+クリックでなければアンカーを更新
	if not Input.is_key_pressed(KEY_SHIFT):
		_created_part_list_last_selected_idx = index
	var sel_nodes: Array[Node3D] = []
	for idx in created_part_list.get_selected_items():
		var m = created_part_list.get_item_metadata(idx) as Dictionary
		if m and m.get("node") and is_instance_valid(m["node"]):
			sel_nodes.append(m["node"] as Node3D)
	if not sel_nodes.is_empty():
		_set_selected_parts(sel_nodes)

	var meta = created_part_list.get_item_metadata(index) as Dictionary
	if not meta:
		return
		
	if meta.get("is_group", false):
		selected_is_group = true
		selected_group_name = meta.get("name", "")
		selected_draft_index = -1
		
		if is_instance_valid(line_edit_create_name):
			line_edit_create_name.text = selected_group_name
			
		_set_creation_controls_blocked(true)
		_update_parent_options()
		_set_creation_controls_blocked(false)
		_update_created_mesh_preview()
		_update_created_selection_label()
		_update_ui()
		return

	selected_is_group = false
	selected_group_name = ""
	selected_draft_index = meta.get("index", -1) as int
	if selected_draft_index < 0 or selected_draft_index >= draft_parts.size():
		_update_created_selection_label()
		return
		
	_update_created_selection_label()
	
	var draft = draft_parts[selected_draft_index]
	
	_set_creation_controls_blocked(true)
	
	if is_instance_valid(line_edit_create_name): line_edit_create_name.text = draft["name"]
	if spin_create_depth: spin_create_depth.value = draft["depth"]
	if spin_create_size: spin_create_size.value = draft["size"]
	if spin_create_tolerance: spin_create_tolerance.value = draft["tolerance"]
	if color_picker_create: color_picker_create.color = draft["color"]
	
	var pos: Vector3 = draft.get("position", Vector3.ZERO)
	if spin_create_pos_x: spin_create_pos_x.value = pos.x
	if spin_create_pos_y: spin_create_pos_y.value = pos.y
	if spin_create_pos_z: spin_create_pos_z.value = pos.z
	
	var rot: Vector3 = draft.get("rotation", Vector3.ZERO)
	if spin_create_rot_x: spin_create_rot_x.value = rot.x
	if spin_create_rot_y: spin_create_rot_y.value = rot.y
	if spin_create_rot_z: spin_create_rot_z.value = rot.z

	var scl: Vector3 = draft.get("scale", Vector3.ONE)
	if spin_create_scale_x: spin_create_scale_x.value = scl.x
	if spin_create_scale_y: spin_create_scale_y.value = scl.y
	if spin_create_scale_z: spin_create_scale_z.value = scl.z
	
	_update_parent_options()
	if option_create_parent:
		var p_name = draft["parent_name"]
		var sel_idx = 0
		for i in range(option_create_parent.item_count):
			if option_create_parent.get_item_text(i) == p_name:
				sel_idx = i
				break
		option_create_parent.select(sel_idx)
		
	_set_creation_controls_blocked(false)
	
	current_contour_points = draft["contour"]
	_update_created_mesh_preview()
	_update_ui()

func _on_create_scale_spinbox_changed(changed_spin: SpinBox, new_val: float) -> void:
	if _updating_scale_spinboxes: return
	if btn_create_link_scale and btn_create_link_scale.button_pressed:
		_updating_scale_spinboxes = true
		if spin_create_scale_x and spin_create_scale_x != changed_spin: spin_create_scale_x.value = new_val
		if spin_create_scale_y and spin_create_scale_y != changed_spin: spin_create_scale_y.value = new_val
		if spin_create_scale_z and spin_create_scale_z != changed_spin: spin_create_scale_z.value = new_val
		_updating_scale_spinboxes = false
	_on_create_param_changed()

func _set_creation_controls_blocked(blocked: bool) -> void:
	if spin_create_depth: spin_create_depth.set_block_signals(blocked)
	if spin_create_size: spin_create_size.set_block_signals(blocked)
	if spin_create_tolerance: spin_create_tolerance.set_block_signals(blocked)
	if color_picker_create: color_picker_create.set_block_signals(blocked)
	if spin_create_pos_x: spin_create_pos_x.set_block_signals(blocked)
	if spin_create_pos_y: spin_create_pos_y.set_block_signals(blocked)
	if spin_create_pos_z: spin_create_pos_z.set_block_signals(blocked)
	if spin_create_rot_x: spin_create_rot_x.set_block_signals(blocked)
	if spin_create_rot_y: spin_create_rot_y.set_block_signals(blocked)
	if spin_create_rot_z: spin_create_rot_z.set_block_signals(blocked)
	if spin_create_scale_x: spin_create_scale_x.set_block_signals(blocked)
	if spin_create_scale_y: spin_create_scale_y.set_block_signals(blocked)
	if spin_create_scale_z: spin_create_scale_z.set_block_signals(blocked)
	if option_create_parent: option_create_parent.set_block_signals(blocked)

func _on_copy_created_part_pressed() -> void:
	if selected_draft_index >= 0 and selected_draft_index < draft_parts.size():
		var orig = draft_parts[selected_draft_index]
		var copy_draft = orig.duplicate(true)
		var base_copy_name = orig["name"] + "_copy"
		
		var root = _find_assembly_root()
		var target_parent: Node = root
		if copy_draft.get("parent_name", "") != "" and root:
			var p = root.get_node_or_null(copy_draft["parent_name"])
			if is_instance_valid(p): target_parent = p
		
		# Collect all existing names across workspace models, groups, and drafts
		var used_names: Dictionary = {}
		if is_instance_valid(root):
			_collect_all_node_names(root, used_names)
		for g in created_parent_groups:
			used_names[g] = true
		for d in draft_parts:
			if d is Dictionary and d.has("name"):
				used_names[d["name"]] = true

		var unique_name = _generate_unique_name_from_dict(base_copy_name, used_names)
		copy_draft["name"] = unique_name
		
		if copy_draft["inserted"] and is_instance_valid(orig.get("node")):
			var orig_node = orig["node"] as Node3D
			var parent = orig_node.get_parent()
			if is_instance_valid(parent):
				var node_copy = orig_node.duplicate(Node.DUPLICATE_USE_INSTANTIATION | Node.DUPLICATE_SIGNALS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS) as Node3D
				node_copy.name = unique_name
				for child in node_copy.get_children():
					if child is MeshInstance3D:
						child.name = unique_name + "_mesh"
						break
				parent.add_child(node_copy)
				node_copy.position += Vector3(0.05, 0.0, 0.05)
				copy_draft["node"] = node_copy
				node_copy.set_meta("glb_original_transform", node_copy.transform)
				node_copy.set_meta("glb_original_position", node_copy.position)
				node_copy.set_meta("glb_original_rotation", node_copy.rotation_degrees)
				_sync_part_transform_meta(node_copy)
				if is_instance_valid(model_root) and ("initial_transforms" in model_root) and model_root.initial_transforms is Dictionary:
					model_root.initial_transforms[node_copy.name] = node_copy.transform
				
				_set_highlight(selected_part, false)
				selected_part = node_copy
				_set_highlight(selected_part, true)
		
		draft_parts.append(copy_draft)
		selected_draft_index = draft_parts.size() - 1
		_update_parent_options()
		_update_created_part_list()
		_update_part_list()
		_update_created_mesh_preview()
		_update_created_selection_label()
		_update_ui()
		_mark_modified()
	elif is_instance_valid(selected_part):
		_on_copy_part_pressed()

func _on_delete_created_part_pressed() -> void:
	"""Handle deletion of selected group or draft part."""
	var root = _find_assembly_root()
	
	# Case 1: Parent Group is selected
	if selected_is_group:
		if selected_group_name.is_empty():
			return
			
		var deleted_g_name = selected_group_name
		created_parent_groups.erase(deleted_g_name)
		
		# Re-parent all child draft parts to root (parent_name = "")
		for draft in draft_parts:
			if draft["parent_name"] == deleted_g_name:
				draft["parent_name"] = ""
				if draft["inserted"] and is_instance_valid(draft["node"]) and root:
					var child_node = draft["node"] as Node3D
					if child_node.get_parent() != root:
						child_node.reparent(root)
						
		# Delete the Group Node3D in workspace if present
		if root:
			var p_node = root.get_node_or_null(deleted_g_name)
			if is_instance_valid(p_node):
				p_node.free()
				
		selected_is_group = false
		selected_group_name = ""
		
		_update_parent_options()
		_update_created_part_list()
		_update_part_list()
		_update_created_mesh_preview()
		return

	# Case 2: Individual draft part is selected
	if selected_draft_index < 0 or selected_draft_index >= draft_parts.size():
		if is_instance_valid(selected_part):
			_on_delete_part_pressed()
		return
	
	if is_instance_valid(last_deleted_draft_node):
		last_deleted_draft_node.queue_free()
		last_deleted_draft_node = null

	var draft = draft_parts[selected_draft_index]
	last_deleted_draft = draft.duplicate(true)
	last_deleted_draft_index = selected_draft_index
	
	if draft["inserted"] and is_instance_valid(draft["node"]):
		var node_to_delete = draft["node"] as Node3D
		last_deleted_draft_node = node_to_delete
		if selected_part == node_to_delete:
			_set_highlight(selected_part, false)
			selected_part = null
		if node_to_delete.get_parent():
			node_to_delete.get_parent().remove_child(node_to_delete)

	draft_parts.remove_at(selected_draft_index)
	
	if draft_parts.is_empty():
		selected_draft_index = -1
		current_contour_points.clear()
	else:
		selected_draft_index = clamp(selected_draft_index, 0, draft_parts.size() - 1)
		_on_created_part_list_item_selected(selected_draft_index)
	
	_update_parent_options()
	_update_created_part_list()
	_update_part_list()
	_update_created_mesh_preview()
	_update_ui()

func _on_undo_delete_created_part_pressed() -> void:
	if last_deleted_draft.is_empty():
		if is_instance_valid(last_deleted_part):
			_on_undo_delete_part_pressed()
		return
	var restored_draft = last_deleted_draft.duplicate(true)
	if is_instance_valid(last_deleted_draft_node):
		var root = _find_assembly_root()
		if root:
			var parent_name = restored_draft.get("parent_name", "")
			var parent_node: Node = root
			if not parent_name.is_empty():
				var p = root.get_node_or_null(parent_name)
				if is_instance_valid(p): parent_node = p
			parent_node.add_child(last_deleted_draft_node)
			restored_draft["node"] = last_deleted_draft_node
			selected_part = last_deleted_draft_node
			_set_highlight(selected_part, true)
	
	var idx = clamp(last_deleted_draft_index, 0, draft_parts.size())
	draft_parts.insert(idx, restored_draft)
	selected_draft_index = idx
	
	last_deleted_draft.clear()
	last_deleted_draft_node = null
	last_deleted_draft_index = -1
	
	_update_parent_options()
	_update_created_part_list()
	_update_part_list()
	_update_created_mesh_preview()
	_update_ui()


func _on_rename_created_part_pressed() -> void:
	"""Handle renaming of selected parent group or individual draft part with uniqueness check."""
	var new_name = line_edit_create_name.text.strip_edges() if is_instance_valid(line_edit_create_name) else ""
	if new_name.is_empty():
		return

	var root = _find_assembly_root()

	# Case 1: Parent Group is selected
	if selected_is_group:
		if selected_group_name.is_empty() or new_name == selected_group_name:
			return
			
		var old_group_name = selected_group_name
		
		# Collect all existing names to prevent collisions
		var used_names: Dictionary = {}
		if is_instance_valid(root):
			_collect_all_node_names(root, used_names)
		for g in created_parent_groups:
			if g != old_group_name:
				used_names[g] = true
		for d in draft_parts:
			if d is Dictionary and d.has("name"):
				used_names[d["name"]] = true
		used_names.erase(old_group_name)

		new_name = _generate_unique_name_from_dict(new_name, used_names)
		selected_group_name = new_name
		if is_instance_valid(line_edit_create_name):
			line_edit_create_name.text = new_name
		
		var g_idx = created_parent_groups.find(old_group_name)
		if g_idx != -1:
			created_parent_groups[g_idx] = new_name
		elif not created_parent_groups.has(new_name):
			created_parent_groups.append(new_name)
		
		# Update all child draft parts matching old group name
		for draft in draft_parts:
			if draft["parent_name"] == old_group_name:
				draft["parent_name"] = new_name
				
		# Rename workspace Node3D group if present
		if root:
			var p_node = root.get_node_or_null(old_group_name)
			if is_instance_valid(p_node):
				p_node.name = new_name
				
		_update_parent_options()
		_update_created_part_list()
		_update_part_list()
		_update_created_selection_label()
		_mark_modified()
		return

	# Case 2: Individual Draft Part is selected
	if selected_draft_index < 0 or selected_draft_index >= draft_parts.size():
		return
	
	var draft = draft_parts[selected_draft_index]
	var old_name: String = draft.get("name", "")
	if new_name == old_name:
		return

	# Collect all existing names to prevent collisions
	var used_names: Dictionary = {}
	if is_instance_valid(root):
		_collect_all_node_names(root, used_names)
	for g in created_parent_groups:
		used_names[g] = true
	for i in range(draft_parts.size()):
		if i != selected_draft_index:
			var d = draft_parts[i]
			if d is Dictionary and d.has("name"):
				used_names[d["name"]] = true

	# Exclude self node and its mesh child if already inserted
	if draft.get("inserted") and is_instance_valid(draft.get("node")):
		var self_node: Node = draft["node"]
		used_names.erase(self_node.name)
		for c in self_node.get_children():
			used_names.erase(c.name)
	else:
		used_names.erase(old_name)

	new_name = _generate_unique_name_from_dict(new_name, used_names)
	draft["name"] = new_name
	if is_instance_valid(line_edit_create_name):
		line_edit_create_name.text = new_name

	if draft.get("inserted") and is_instance_valid(draft.get("node")):
		var node = draft["node"] as Node3D
		var prev_node_name = node.name
		node.name = new_name
		for child in node.get_children():
			if child is MeshInstance3D:
				child.name = new_name + "_mesh"
				break
		if is_instance_valid(model_root) and ("initial_transforms" in model_root) and model_root.initial_transforms is Dictionary:
			if model_root.initial_transforms.has(prev_node_name):
				var tf = model_root.initial_transforms[prev_node_name]
				model_root.initial_transforms.erase(prev_node_name)
				model_root.initial_transforms[new_name] = tf
	
	_update_created_part_list()
	_update_part_list()
	_update_created_selection_label()
	_mark_modified()


func _on_insert_created_part_pressed() -> void:
	if selected_is_group:
		_insert_created_group(selected_group_name)
		return

	if selected_draft_index < 0 or selected_draft_index >= draft_parts.size():
		return

	_insert_single_draft_part(selected_draft_index, true)


func _insert_created_group(group_name: String) -> void:
	"""グループを作業空間に挿入し、そのグループに属する未挿入の配下モデルも同時に挿入する。"""
	if group_name.is_empty():
		return

	var root = _find_assembly_root()
	if not root:
		return

	# グループ自体のノードがまだ作業空間に無ければ先に作成する
	if not root.get_node_or_null(group_name):
		var g_node := Node3D.new()
		g_node.name = group_name
		g_node.set_meta("generated_by_importer", true)
		g_node.set_meta("is_created_parent", true)
		g_node.set_meta("initial_transform", Transform3D.IDENTITY)
		g_node.set_meta("initial_position", Vector3.ZERO)
		g_node.set_meta("initial_rotation", Vector3.ZERO)
		root.add_child(g_node)
		if not created_parent_groups.has(group_name):
			created_parent_groups.append(group_name)

	var inserted_count := 0
	for i in range(draft_parts.size()):
		var d = draft_parts[i]
		if d.get("parent_name", "") == group_name and not d.get("inserted", false):
			_insert_single_draft_part(i, false)
			inserted_count += 1

	_update_created_part_list()
	_update_created_mesh_preview()
	_update_part_list()
	_update_parent_options()


func _insert_single_draft_part(idx: int, use_name_field: bool) -> void:
	"""ドラフト1件を作業空間に挿入する。use_name_field は単体選択時のみ true にし、
	作成名テキストフィールドの内容を優先する（グループ一括挿入時は各ドラフト自身の名前を使う）。"""
	var draft = draft_parts[idx]
	var points = draft["contour"] as Array[Vector2]
	if points.is_empty():
		return

	var root = _find_assembly_root()
	if not root:
		return

	var mesh = _generate_extruded_mesh(points, draft["depth"], draft["size"], draft["color"])
	if not mesh:
		return

	var part_name = draft["name"]
	if use_name_field and is_instance_valid(line_edit_create_name):
		var field_name = line_edit_create_name.text.strip_edges()
		if not field_name.is_empty():
			part_name = field_name
	draft["name"] = part_name

	# Determine parent node
	var parent_node: Node3D = root
	var parent_name: String = draft.get("parent_name", "") as String
	if not parent_name.is_empty():
		var found_p = root.get_node_or_null(parent_name) as Node3D
		if not is_instance_valid(found_p):
			found_p = Node3D.new()
			found_p.name = parent_name
			found_p.set_meta("generated_by_importer", true)
			found_p.set_meta("is_created_parent", true)
			found_p.set_meta("initial_transform", Transform3D.IDENTITY)
			found_p.set_meta("initial_position", Vector3.ZERO)
			found_p.set_meta("initial_rotation", Vector3.ZERO)
			root.add_child(found_p)
			if not created_parent_groups.has(parent_name):
				created_parent_groups.append(parent_name)
		parent_node = found_p

	# If already inserted previously, free the old node first
	if draft["inserted"] and is_instance_valid(draft["node"]):
		var old_node = draft["node"] as Node3D
		if selected_part == old_node:
			_set_highlight(selected_part, false)
			selected_part = null
		old_node.free()

	part_name = AssemblyImporter.get_unique_name(parent_node, part_name)
	draft["name"] = part_name

	# 1. Wrapper Node3D
	var part_node := Node3D.new()
	part_node.name = part_name
	part_node.position = draft["position"]
	part_node.rotation_degrees = draft["rotation"]
	part_node.set_meta("generated_by_importer", true)
	part_node.set_meta("is_created_part", true)
	part_node.set_meta("initial_transform", Transform3D(Basis.from_euler(Vector3(deg_to_rad(draft["rotation"].x), deg_to_rad(draft["rotation"].y), deg_to_rad(draft["rotation"].z))), draft["position"]))
	part_node.set_meta("initial_position", draft["position"])
	part_node.set_meta("initial_rotation", draft["rotation"])

	# 2. Visual Mesh Node
	var vis_node := MeshInstance3D.new()
	vis_node.name = part_name + "_mesh"
	vis_node.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = draft["color"]
	mat.roughness = 0.4
	mat.metallic = 0.1
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	vis_node.material_override = mat

	part_node.add_child(vis_node)

	model_root = root
	parent_node.add_child(part_node)

	# 3. Collision Body
	vis_node.create_trimesh_collision()

	orig_scale[part_node] = Vector3.ONE
	if root.has_method("__get") or "initial_transforms" in root:
		root.initial_transforms[part_node.name] = part_node.transform

	# Update draft part state
	draft["inserted"] = true
	draft["node"] = part_node

	# 「既存モデル非表示」トグルの状態に合わせて挿入直後の表示を決定
	var hide_existing_on = is_instance_valid(check_hide_existing) and not check_hide_existing.button_pressed
	part_node.visible = not hide_existing_on
	_set_node_collision_enabled_recursive(part_node, not hide_existing_on)
	# Refresh UI part lists and draft previews
	_update_created_part_list()
	_update_created_mesh_preview()
	_update_part_list()

	# If ground is visible, ensure it sits at the bottom of the model
	var grounds = get_all_ground_nodes()
	if not grounds.is_empty() and grounds[0].visible:
		var model_aabb = _get_node_aabb(root, true)
		if model_aabb.size != Vector3.ZERO:
			set_ground_visible(true, model_aabb.position.y)

	_mark_modified()


func _remove_collision_areas() -> void:
	if not is_instance_valid(model_root): return
	for child in model_root.get_children():
		if child is Node3D:
			for c in child.get_children():
				if c is Area3D and (c.name == "CollisionArea" or c.name.begins_with("CollisionArea")):
					c.queue_free()

func _update_motion_range_visuals() -> void:
	if not is_instance_valid(model_root): return
	var show_range = false
	if is_instance_valid(check_show_motion_range):
		show_range = check_show_motion_range.button_pressed

	for mesh_inst in range_mesh_instances.values():
		if is_instance_valid(mesh_inst):
			mesh_inst.queue_free()
	range_mesh_instances.clear()

	if not show_range:
		return

	for child in model_root.get_children():
		var behavior = _get_part_behavior(child)
		if behavior == null: continue

		var is_rotary = behavior is MotionRotary
		var is_linear = behavior is MotionLinear

		if not is_rotary and not is_linear: continue

		var mesh_inst = MeshInstance3D.new()
		var im = ImmediateMesh.new()
		mesh_inst.mesh = im
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.0, 1.0, 1.0)
		mat.no_depth_test = true
		mesh_inst.material_override = mat
		
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		
		var parent_orig = child.transform
		if child.has_meta("initial_transform"):
			parent_orig = child.get_meta("initial_transform")

		if is_linear:
			var axis = behavior.axis.normalized()
			var p_min = axis * behavior.distance_min
			var p_max = axis * behavior.distance_max
			im.surface_add_vertex(p_min)
			im.surface_add_vertex(p_max)
			mesh_inst.transform = parent_orig
		elif is_rotary:
			var axis = behavior.axis.normalized()
			var pivot = behavior.pivot
			var a_min = behavior.angle_min
			var a_max = behavior.angle_max
			var steps = 32
			var prev_pt = Vector3.ZERO
			for i in range(steps + 1):
				var t = float(i) / float(steps)
				var angle = lerpf(a_min, a_max, t)
				var pt = pivot - pivot.rotated(axis, deg_to_rad(angle))
				if i > 0:
					im.surface_add_vertex(prev_pt)
					im.surface_add_vertex(pt)
				prev_pt = pt
			
			mesh_inst.transform = parent_orig

		im.surface_end()
		model_root.add_child(mesh_inst)
		range_mesh_instances[child] = mesh_inst

# ── Preset and Timeline Features ──────────────────────────────────────────────

var _is_timeline_dragging: bool = false
var _timeline_slider: HSlider
var _lbl_timeline_time: Label
var _preset_dialog_mode: String = ""
var _preset_file_dialog: FileDialog

func _setup_motion_preset_and_timeline() -> void:
	var motion_vbox: VBoxContainer = null
	var curr = option_motion_type.get_parent()
	while curr:
		if curr is VBoxContainer and curr.get_parent() is ScrollContainer:
			motion_vbox = curr
			break
		curr = curr.get_parent()
		
	if not motion_vbox:
		motion_vbox = option_motion_type.get_parent() as VBoxContainer
		
	if not motion_vbox: return
	
	motion_vbox.add_child(HSeparator.new())
	
	var preset_hbox = HBoxContainer.new()
	var lbl_preset = Label.new()
	lbl_preset.text = "プリセット:"
	preset_hbox.add_child(lbl_preset)
	
	var btn_save_preset = Button.new()
	btn_save_preset.text = "保存"
	btn_save_preset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_save_preset.pressed.connect(_on_save_preset_pressed)
	preset_hbox.add_child(btn_save_preset)
	
	var btn_load_preset = Button.new()
	btn_load_preset.text = "読込"
	btn_load_preset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_load_preset.pressed.connect(_on_load_preset_pressed)
	preset_hbox.add_child(btn_load_preset)
	
	motion_vbox.add_child(preset_hbox)
	
	motion_vbox.add_child(HSeparator.new())
	
	var timeline_vbox = VBoxContainer.new()
	var timeline_label_hbox = HBoxContainer.new()
	var lbl_timeline_title = Label.new()
	lbl_timeline_title.text = "タイムライン:"
	timeline_label_hbox.add_child(lbl_timeline_title)
	
	_lbl_timeline_time = Label.new()
	_lbl_timeline_time.text = "0.00s / 0.00s"
	_lbl_timeline_time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_timeline_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timeline_label_hbox.add_child(_lbl_timeline_time)
	
	timeline_vbox.add_child(timeline_label_hbox)
	
	_timeline_slider = HSlider.new()
	_timeline_slider.min_value = 0.0
	_timeline_slider.max_value = 1.0
	_timeline_slider.step = 0.01
	_timeline_slider.gui_input.connect(_on_timeline_gui_input)
	_timeline_slider.value_changed.connect(_on_timeline_value_changed)
	timeline_vbox.add_child(_timeline_slider)
	
	motion_vbox.add_child(timeline_vbox)
	
	_preset_file_dialog = FileDialog.new()
	_preset_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_preset_file_dialog.add_filter("*.json", "Motion Preset")
	_preset_file_dialog.current_dir = _get_save_dir()
	_preset_file_dialog.file_selected.connect(_on_preset_file_selected)
	add_child(_preset_file_dialog)

func _on_save_preset_pressed() -> void:
	if not is_instance_valid(selected_part): return
	_preset_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_preset_file_dialog.title = "プリセットを保存"
	_preset_dialog_mode = "save"
	_preset_file_dialog.popup_centered_ratio(0.5)

func _on_load_preset_pressed() -> void:
	if not is_instance_valid(selected_part): return
	_preset_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_preset_file_dialog.title = "プリセットを読込"
	_preset_dialog_mode = "load"
	_preset_file_dialog.popup_centered_ratio(0.5)

func _on_preset_file_selected(path: String) -> void:
	if _preset_dialog_mode == "save":
		_save_preset_to_file(path)
	elif _preset_dialog_mode == "load":
		_load_preset_from_file(path)

func _save_preset_to_file(path: String) -> void:
	if not is_instance_valid(selected_part): return
	var type_str = "none"
	if option_motion_type.selected == 1: type_str = "rotary"
	elif option_motion_type.selected == 2: type_str = "linear"
	
	var params = _get_motion_params_from_ui(type_str)
	var data = {
		"type": type_str,
		"duration": params.get("duration", 1.0),
		"ping_pong": params.get("ping_pong", false)
	}
	
	if params.has("axis"):
		data["axis"] = [params["axis"].x, params["axis"].y, params["axis"].z]
		
	if type_str == "rotary":
		data["angle_min"] = params.get("angle_min", 0.0)
		data["angle_max"] = params.get("angle_max", 360.0)
		if params.has("pivot"):
			data["pivot"] = [params["pivot"].x, params["pivot"].y, params["pivot"].z]
	elif type_str == "linear":
		data["distance_min"] = params.get("distance_min", 0.0)
		data["distance_max"] = params.get("distance_max", 1.0)
		
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func _load_preset_from_file(path: String) -> void:
	if not is_instance_valid(selected_part): return
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_str) == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			_apply_preset_data(data)

func _apply_preset_data(data: Dictionary) -> void:
	var m_type = data.get("type", "none")
	if m_type == "rotary":
		option_motion_type.selected = 1
	elif m_type == "linear":
		option_motion_type.selected = 2
	else:
		option_motion_type.selected = 0
		
	_on_motion_type_selected(option_motion_type.selected)
	_is_restoring_ui_state = true
	
	if data.has("duration"): spin_motion_duration.value = data["duration"]
	if data.has("ping_pong"): check_motion_ping_pong.button_pressed = data["ping_pong"]
	
	if data.has("axis"):
		var arr = data["axis"]
		if arr is Array and arr.size() >= 3:
			_set_axis_ui(arr[0], btn_axis_x, "X")
			_set_axis_ui(arr[1], btn_axis_y, "Y")
			_set_axis_ui(arr[2], btn_axis_z, "Z")
			
	if m_type == "rotary":
		if data.has("angle_min"): spin_motion_param_min.value = data["angle_min"]
		if data.has("angle_max"): spin_motion_param_max.value = data["angle_max"]
		if data.has("pivot"):
			var p_arr = data["pivot"]
			if p_arr is Array and p_arr.size() >= 3:
				var local_piv = Vector3(float(p_arr[0]), float(p_arr[1]), float(p_arr[2]))
				var center_parent = selected_part.transform * local_piv
				spin_pivot_x.value = center_parent.x
				spin_pivot_y.value = center_parent.y
				spin_pivot_z.value = center_parent.z
	elif m_type == "linear":
		if data.has("distance_min"): spin_motion_param_min.value = data["distance_min"] * 1000.0
		if data.has("distance_max"): spin_motion_param_max.value = data["distance_max"] * 1000.0
		
	_is_restoring_ui_state = false
	_on_motion_param_changed(0.0)

func _on_timeline_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_timeline_dragging = event.pressed

func _on_timeline_value_changed(val: float) -> void:
	if _is_timeline_dragging:
		SimulationManager.elapsed_time = val
		if is_instance_valid(_lbl_timeline_time):
			_lbl_timeline_time.text = "%.2fs / %.2fs" % [val, _timeline_slider.max_value]
		for behavior in SimulationManager._behaviors:
			if is_instance_valid(behavior):
				behavior.tick(0.0)
