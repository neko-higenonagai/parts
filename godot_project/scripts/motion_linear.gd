## Linear translation animation along a configurable axis.
## Calculates position directly from elapsed time (no Tween) so that
## reset and time-scale changes are instantaneous and glitch-free.
class_name MotionLinear
extends ModelBehavior

# ── Exports ──────────────────────────────────────────────────────────────────
## Direction of travel (will be normalized internally).
@export var axis: Vector3 = Vector3.RIGHT
## Minimum travel distance in meters.
@export var distance_min: float = 0.0
## Maximum travel distance in meters.
@export var distance_max: float = 1.0
## Time for one full traversal in seconds.
@export var duration: float = 2.0
## Whether the motion repeats after completion.
@export var loop: bool = true
## Go back and forth instead of snapping to start.
@export var ping_pong: bool = true
## Easing curve applied to the normalized progress.
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT


# ── Tick ─────────────────────────────────────────────────────────────────────

func tick(delta: float) -> void:
	super.tick(delta)

	var parent := _get_parent_node3d()
	if not parent:
		return

	var direction: Vector3 = axis.normalized()

	# Compute raw progress (0 → 1) using global elapsed time for perfect synchronization.
	var t: float = 0.0
	if duration > 0.0:
		t = SimulationManager.elapsed_time / duration

	if loop:
		if ping_pong:
			# Triangle wave: 0→1→0→1…
			t = fmod(t, 2.0)
			if t > 1.0:
				t = 2.0 - t
		else:
			t = fmod(t, 1.0)
	else:
		if ping_pong:
			t = clampf(t, 0.0, 2.0)
			if t > 1.0:
				t = 2.0 - t
		else:
			t = clampf(t, 0.0, 1.0)

	# Apply easing.
	t = _apply_ease(t)

	var current_dist = lerpf(distance_min, distance_max, t)

	# Set position relative to the stored initial transform.
	parent.transform = _initial_parent_transform
	parent.position += direction * current_dist


# ── Easing Helper ────────────────────────────────────────────────────────────

func _apply_ease(t: float) -> float:
	match ease_type:
		Tween.EASE_IN:
			return t * t
		Tween.EASE_OUT:
			return 1.0 - (1.0 - t) * (1.0 - t)
		Tween.EASE_IN_OUT:
			if t < 0.5:
				return 2.0 * t * t
			else:
				return 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0
		_:
			return t
