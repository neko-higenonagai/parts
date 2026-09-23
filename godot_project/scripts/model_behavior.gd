## Base class for all motion / animation behaviors.
## Attach as a child of a Node3D. Stores the parent's initial transform
## so it can be restored on reset. Subclasses override [method tick].
class_name ModelBehavior
extends Node

# ── Exports ──────────────────────────────────────────────────────────────────
## If true, the behavior activates as soon as the simulation starts.
@export var auto_start: bool = false

# ── State ────────────────────────────────────────────────────────────────────
var _is_active: bool = false
var _initial_parent_transform: Transform3D


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Store the parent's transform so we can restore it on reset.
	var parent := _get_parent_node3d()
	if parent:
		_initial_parent_transform = parent.transform

	# Register with the global SimulationManager.
	SimulationManager.register_behavior(self)

	# Listen for simulation-wide reset.
	SimulationManager.simulation_reset.connect(_on_simulation_reset)

	# Auto-start support: activate when the simulation starts.
	if auto_start:
		SimulationManager.simulation_started.connect(_on_simulation_started)


func _exit_tree() -> void:
	SimulationManager.unregister_behavior(self)


# ── Public API ───────────────────────────────────────────────────────────────

## Activate this behavior.
func start() -> void:
	_is_active = true


## Deactivate this behavior (does NOT reset).
func stop() -> void:
	_is_active = false


## Reset and restore the parent's original transform.
func reset() -> void:
	_is_active = false
	var parent := _get_parent_node3d()
	if parent:
		parent.transform = _initial_parent_transform


## Called every simulation frame. Override in subclasses.
## [param delta] is already scaled by SimulationManager.time_scale.
func tick(_delta: float) -> void:
	pass


# ── Helpers ──────────────────────────────────────────────────────────────────

## Safely retrieve the parent as a Node3D.
func _get_parent_node3d() -> Node3D:
	var p := get_parent()
	if p is Node3D:
		return p as Node3D
	return null


# ── Signal Callbacks ─────────────────────────────────────────────────────────

func _on_simulation_reset() -> void:
	reset()


func _on_simulation_started() -> void:
	if auto_start:
		start()
