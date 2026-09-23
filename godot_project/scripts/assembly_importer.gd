@tool
class_name AssemblyImporter
extends Node3D

## 読み込む GLB ファイルパス
@export_file("*.glb") var glb_file: String = "":
	set(value):
		glb_file = value

## エディタ上でオンにすると GLB を展開します（ランタイムでは _unpack() を直接呼ぶ）
@export var unpack_glb: bool = false:
	set(value):
		if value:
			_unpack()
		unpack_glb = false

## パーツ名 → 初期ローカル Transform（GLBのローカル変換をそのまま保存）
@export var initial_transforms: Dictionary = {}

## GLBから読み込んだモーション設定（パーツ名 → モーション辞書）
var current_imported_motions: Dictionary = {}

func _ready() -> void:
	self.scale = Vector3.ONE
	# 起動時は自動展開しない。
	# GLBの展開は ui_controller.gd の「モデル読み込み」ボタンから明示的に行う。


## GLB を読み込み、Blender の親子構造をそのまま Godot ノードツリーに再現する。
## 各ノードのローカル変換（position / rotation / scale）を完全保持する。
func _unpack() -> void:
	initial_transforms.clear()
	current_imported_motions.clear()

	# 既存の自動生成ノードをすべて破棄
	for child in get_children():
		child.free()

	if glb_file == "":
		return

	if not FileAccess.file_exists(glb_file):
		return

	# GLB をロード
	var inst: Node = null
	var global_path: String = ProjectSettings.globalize_path(glb_file) \
			if glb_file.begins_with("res://") else glb_file

	var gltf_doc := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	if gltf_doc.append_from_file(global_path, gltf_state) == OK:
		inst = gltf_doc.generate_scene(gltf_state)

	if not inst and glb_file.begins_with("res://"):
		var res = ResourceLoader.load(glb_file, "", ResourceLoader.CACHE_MODE_REPLACE)
		if res is PackedScene:
			inst = res.instantiate()

	if not inst:
		return

	_extract_motion_data(global_path, gltf_state)

	# GLB ルート直下の子を self 配下に再帰的に複製する
	for glb_child in inst.get_children():
		_build_tree(glb_child, self)

	inst.queue_free()


func _unpack_add() -> void:
	if glb_file == "":
		return

	if not FileAccess.file_exists(glb_file):
		return

	var inst: Node = null
	var global_path: String = ProjectSettings.globalize_path(glb_file) \
			if glb_file.begins_with("res://") else glb_file

	var gltf_doc := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	if gltf_doc.append_from_file(global_path, gltf_state) == OK:
		inst = gltf_doc.generate_scene(gltf_state)

	if not inst and glb_file.begins_with("res://"):
		var res = ResourceLoader.load(glb_file, "", ResourceLoader.CACHE_MODE_REPLACE)
		if res is PackedScene:
			inst = res.instantiate()

	if not inst:
		return

	_extract_motion_data(global_path, gltf_state)

	for glb_child in inst.get_children():
		_build_tree(glb_child, self)

	inst.queue_free()


func _extract_motion_data(global_path: String, gltf_state: GLTFState) -> void:
	current_imported_motions.clear()
	var json = gltf_state.get_json()
	if json is Dictionary and json.has("extras") and json["extras"] is Dictionary:
		var extras = json["extras"]
		if extras.has("hgnn_motions") and extras["hgnn_motions"] is Dictionary:
			current_imported_motions = extras["hgnn_motions"]

	# 同階層の .motion.json からもフォールバック読み込み
	if current_imported_motions.is_empty():
		var sidecar_path = global_path.get_basename() + ".motion.json"
		if FileAccess.file_exists(sidecar_path):
			var f = FileAccess.open(sidecar_path, FileAccess.READ)
			if f:
				var parsed = JSON.parse_string(f.get_as_text())
				if parsed is Dictionary:
					current_imported_motions = parsed
				f.close()



## 指定された親ノード配下で重複しない一意なノード名を生成して返す
static func get_unique_name(godot_parent: Node, base_name: String) -> String:
	if not is_instance_valid(godot_parent):
		return base_name
	if not _has_child_with_name(godot_parent, base_name):
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
		if not _has_child_with_name(godot_parent, candidate):
			return candidate
		counter += 1
	return base_name

static func _has_child_with_name(parent: Node, child_name: String) -> bool:
	if not is_instance_valid(parent):
		return false
	for child in parent.get_children():
		if child.name == child_name:
			return true
	return false

static func _has_mesh_recursive(node: Node) -> bool:
	if node is MeshInstance3D:
		return true
	for child in node.get_children():
		if _has_mesh_recursive(child):
			return true
	return false


## GLB ノード 1 つを Godot ノードとして godot_parent 配下に生成し、
## その子も再帰的に同じ処理をする。
## ローカル変換は GLB ノードのものをそのままコピーするため、
## Blender 上の位置・回転・スケール・バウンディングボックスが完全に再現される。
func _build_tree(glb_node: Node, godot_parent: Node) -> void:
	if not glb_node is Node3D:
		return

	# 除外: Blender の GUI カメラ・ライト、および本アプリ内部ノード等
	var n: String = glb_node.name
	if n.begins_with("__") \
			or n.begins_with("KeyLight") or n.begins_with("FillLight") \
			or n.begins_with("BackLight") or n.begins_with("RimLight") \
			or n.begins_with("CreatedParts_PreviewContainer") \
			or n.begins_with("CollisionArea") or n.begins_with("ExportAnimPlayer"):
		return

	# メッシュを含まない空ノード（_Node3D_... など）はツリー構築から除外
	if not (glb_node is MeshInstance3D) and not _has_mesh_recursive(glb_node):
		return

	var glb_n3d := glb_node as Node3D
	var unique_name := get_unique_name(godot_parent, n)

	if glb_node is MeshInstance3D:
		# ── メッシュを持つノード ──
		# GLBから取り出した MeshInstance3D をそのまま独立したノードとして再作成する。
		# ラッパーNode3Dでメッシュを包む構造にして、モーション・選択・リセットに対応。
		var mesh_src := glb_node as MeshInstance3D

		# ラッパー Node3D：位置・回転・スケールを担う（モーション・選択対象）
		var part_node := Node3D.new()
		part_node.name = unique_name
		part_node.transform = glb_n3d.transform
		part_node.set_meta("generated_by_importer", true)
		part_node.set_meta("initial_transform", glb_n3d.transform)
		part_node.set_meta("initial_position", glb_n3d.position)
		part_node.set_meta("initial_rotation", glb_n3d.rotation_degrees)
		part_node.set_meta("glb_original_transform", glb_n3d.transform)
		part_node.set_meta("glb_original_position", glb_n3d.position)
		part_node.set_meta("glb_original_rotation", glb_n3d.rotation_degrees)
		initial_transforms[unique_name] = glb_n3d.transform
		godot_parent.add_child(part_node)

		# メッシュノード：ローカル原点に配置（変換はラッパー側で管理）
		var vis_node := MeshInstance3D.new()
		vis_node.name = unique_name + "_mesh"
		vis_node.mesh = mesh_src.mesh

		# マテリアルを取得する。
		# GLBではマテリアルはメッシュのサーフェスに直接埋め込まれているため、
		# surface_get_material() で取り出してオーバーライドとして設定する。
		if mesh_src.mesh:
			for i in range(mesh_src.mesh.get_surface_count()):
				# オーバーライドが設定されていればそちらを優先
				var mat = mesh_src.get_surface_override_material(i)
				if not mat:
					mat = mesh_src.mesh.surface_get_material(i)
				if mat:
					vis_node.set_surface_override_material(i, mat)

		part_node.add_child(vis_node)

		# モーションの復元（本アプリからエクスポートされたGLBの場合）
		if current_imported_motions.has(n):
			_apply_motion_data(part_node, current_imported_motions[n])

		# コリジョン（ランタイムのみ。クリック選択に必要）
		if not Engine.is_editor_hint():
			vis_node.create_trimesh_collision()

		# メッシュノードの子も再帰処理
		for glb_child in glb_node.get_children():
			_build_tree(glb_child, part_node)

	else:
		# ── 空ノード（EMPTY / グループ親）──
		# Blenderのグループ構造を保持するための Node3D として作成する。
		var group_node := Node3D.new()
		group_node.name = unique_name
		group_node.transform = glb_n3d.transform
		group_node.set_meta("generated_by_importer", true)
		group_node.set_meta("initial_transform", glb_n3d.transform)
		group_node.set_meta("initial_position", glb_n3d.position)
		group_node.set_meta("initial_rotation", glb_n3d.rotation_degrees)
		group_node.set_meta("glb_original_transform", glb_n3d.transform)
		group_node.set_meta("glb_original_position", glb_n3d.position)
		group_node.set_meta("glb_original_rotation", glb_n3d.rotation_degrees)
		initial_transforms[unique_name] = glb_n3d.transform

		# スケールが極端に小さい場合の行列エラー防止
		var s := glb_n3d.scale
		if abs(s.x) < 1e-4 or abs(s.y) < 1e-4 or abs(s.z) < 1e-4:
			group_node.scale = Vector3.ONE

		godot_parent.add_child(group_node)

		# モーションの復元（本アプリからエクスポートされたGLBの場合）
		if current_imported_motions.has(n):
			_apply_motion_data(group_node, current_imported_motions[n])

		# 子ノードを再帰的に group_node 配下に生成
		for glb_child in glb_node.get_children():
			_build_tree(glb_child, group_node)


func _apply_motion_data(target_node: Node3D, m_data: Dictionary) -> void:
	if not m_data is Dictionary or not m_data.has("type"):
		return
	var m_type = m_data.get("type", "")
	var behavior: Node = null
	if m_type == "rotary":
		behavior = Node.new()
		behavior.set_script(load("res://scripts/motion_rotary.gd"))
		var ax = m_data.get("axis", [0, 1, 0])
		if ax is Array and ax.size() >= 3:
			behavior.set("axis", Vector3(float(ax[0]), float(ax[1]), float(ax[2])))
		behavior.set("angle_min", float(m_data.get("angle_min", 0.0)))
		behavior.set("angle_max", float(m_data.get("angle_max", 360.0)))
		behavior.set("duration", float(m_data.get("duration", 3.0)))
		behavior.set("ping_pong", bool(m_data.get("ping_pong", false)))
		var piv = m_data.get("pivot", [0, 0, 0])
		if piv is Array and piv.size() >= 3:
			behavior.set("pivot", Vector3(float(piv[0]), float(piv[1]), float(piv[2])))
	elif m_type == "linear":
		behavior = Node.new()
		behavior.set_script(load("res://scripts/motion_linear.gd"))
		var ax = m_data.get("axis", [1, 0, 0])
		if ax is Array and ax.size() >= 3:
			behavior.set("axis", Vector3(float(ax[0]), float(ax[1]), float(ax[2])))
		behavior.set("distance_min", float(m_data.get("distance_min", 0.0)))
		behavior.set("distance_max", float(m_data.get("distance_max", 1.0)))
		behavior.set("duration", float(m_data.get("duration", 3.0)))
		behavior.set("ping_pong", bool(m_data.get("ping_pong", false)))

	if behavior:
		behavior.name = "MotionBehavior"
		target_node.add_child(behavior)


func set_owner_recursive(node: Node, root_node: Node) -> void:
	if not is_instance_valid(node):
		return
	if node != root_node:
		if node.name.begins_with("CreatedParts_PreviewContainer") or node.has_meta("is_draft_preview"):
			return
		node.owner = root_node
	for child in node.get_children():
		set_owner_recursive(child, root_node)


# ── UI / SimulationManager 向け API ─────────────────────────────────────────

func get_original_transform(node: Node3D) -> Transform3D:
	if node.has_meta("glb_original_transform"):
		return node.get_meta("glb_original_transform")
	if node.has_meta("initial_transform"):
		return node.get_meta("initial_transform")
	if initial_transforms.has(node.name):
		return initial_transforms[node.name]
	return node.transform

func get_original_rotation_deg(node: Node3D) -> Vector3:
	if node.has_meta("glb_original_rotation"):
		return node.get_meta("glb_original_rotation")
	if node.has_meta("initial_rotation"):
		return node.get_meta("initial_rotation")
	return node.rotation_degrees

## 全パーツを初期変換にリセットする
func reset_all_parts() -> void:
	for child in get_children():
		if child is Node3D and child.has_meta("generated_by_importer"):
			var orig: Transform3D = get_original_transform(child as Node3D)
			child.transform = orig

## ModelSelector 互換: 視覚状態を設定する
func set_child_visual_state(part: Node3D, state: int) -> void:
	part.set_meta("visual_state", state)
	_apply_visual_state_recursive(part, state)

## ModelSelector 互換: 視覚状態を取得する
func get_child_visual_state(part: Node3D) -> int:
	if part.has_meta("visual_state"):
		return part.get_meta("visual_state")
	return 0 # OPAQUE

## ModelSelector 互換: パーツをオフセット移動する
func set_child_part_offset(part: Node3D, offset: Vector3) -> void:
	var orig: Transform3D = get_original_transform(part)
	part.position = orig.origin + offset


func _apply_visual_state_recursive(node: Node, state: int) -> void:
	if node is MeshInstance3D:
		match state:
			0: # OPAQUE
				node.material_override = null
				node.visible = true
			1: # TRANSPARENT
				var mat := StandardMaterial3D.new()
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color = Color(0.3, 0.6, 1.0, 0.25)
				mat.roughness = 0.5
				node.material_override = mat
				node.visible = true
			2: # HIDDEN
				node.visible = false
		if node.get_parent() and node.get_parent().has_meta("generated_by_importer"):
			node.get_parent().set_meta("visual_state", state)
	for child in node.get_children():
		_apply_visual_state_recursive(child, state)
