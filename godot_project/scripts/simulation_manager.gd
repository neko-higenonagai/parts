## Autoload singleton that manages simulation lifecycle.
## Controls start/pause/stop/reset and distributes tick() calls
## to all registered ModelBehavior nodes with time-scale support.
extends Node

# ── Signals ──────────────────────────────────────────────────────────────────
signal simulation_started
signal simulation_stopped
signal simulation_paused
signal simulation_reset

# ── Enums ────────────────────────────────────────────────────────────────────
enum State { IDLE, RUNNING, PAUSED }

# ── Public State ─────────────────────────────────────────────────────────────
var state: State = State.IDLE
var time_scale: float = 1.0
var elapsed_time: float = 0.0

# ── Internals ────────────────────────────────────────────────────────────────
var _behaviors: Array[ModelBehavior] = []


func _process(delta: float) -> void:
	if state != State.RUNNING:
		return

	var scaled_delta: float = delta * time_scale
	elapsed_time += scaled_delta

	# Tick every registered behavior
	for behavior in _behaviors:
		if is_instance_valid(behavior) and behavior._is_active:
			behavior.tick(scaled_delta)


# ── Simulation Control ──────────────────────────────────────────────────────

## Begin or resume the simulation.
func start_simulation() -> void:
	if state == State.RUNNING:
		return
	state = State.RUNNING
	for behavior in _behaviors:
		if is_instance_valid(behavior):
			behavior.start()
	simulation_started.emit()


## Pause the simulation (preserves elapsed time).
func pause_simulation() -> void:
	if state != State.RUNNING:
		return
	state = State.PAUSED
	for behavior in _behaviors:
		if is_instance_valid(behavior):
			behavior.stop()
	simulation_paused.emit()


## Stop the simulation entirely.
func stop_simulation() -> void:
	if state == State.IDLE:
		return
	state = State.IDLE
	for behavior in _behaviors:
		if is_instance_valid(behavior):
			behavior.stop()
	elapsed_time = 0.0
	simulation_stopped.emit()


## Reset everything to initial state — transforms, timers, etc.
func reset_simulation() -> void:
	state = State.IDLE
	elapsed_time = 0.0
	for behavior in _behaviors:
		if is_instance_valid(behavior):
			behavior.reset()
	simulation_reset.emit()


## Change playback speed (0.1 – 10.0 clamped for safety).
func set_time_scale(scale: float) -> void:
	time_scale = clampf(scale, 0.1, 10.0)


# ── Registration ─────────────────────────────────────────────────────────────

## Register a ModelBehavior so it receives tick() calls.
func register_behavior(behavior: ModelBehavior) -> void:
	if behavior not in _behaviors:
		_behaviors.append(behavior)


## Remove a ModelBehavior from the update list.
func unregister_behavior(behavior: ModelBehavior) -> void:
	_behaviors.erase(behavior)
