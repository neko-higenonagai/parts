## Rotary (rotation) animation around a configurable axis.
## Supports continuous full-rotation or angle-limited oscillation.
## Position is computed directly from elapsed time for clean resets.
class_name MotionRotary
extends ModelBehavior

# ── Exports ──────────────────────────────────────────────────────────────────
## Rotation axis (will be normalized internally).
@export var axis: Vector3 = Vector3.UP
## Rotation angle in degrees (start).
@export var angle_min: float = 0.0
## Rotation angle in degrees (end).
@export var angle_max: float = 360.0
## Time for one full traversal in seconds.
@export var duration: float = 2.0
## Whether the motion repeats after completion.
@export var loop: bool = true
## Go back and forth instead of snapping to start.
@export var ping_pong: bool = false
## Easing curve applied to the normalized progress.
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
## Offset from the object's origin around which to rotate (in local space).
@export var pivot: Vector3 = Vector3.ZERO


# ── Tick ─────────────────────────────────────────────────────────────────────

func tick(delta: float) -> void:
	super.tick(delta)

	var parent := _get_parent_node3d()
	if not parent:
		return

	var direction: Vector3 = axis.normalized()

	# Compute raw progress (0 → 1) using global elapsed time.
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

	var current_angle = lerpf(angle_min, angle_max, t)
	var rot_basis := Basis(direction, deg_to_rad(current_angle))
	
	parent.transform = _initial_parent_transform
	if not pivot.is_zero_approx():
		# Translate to pivot, rotate, then translate back
		parent.transform = parent.transform.translated_local(pivot)
		parent.transform = parent.transform.rotated_local(direction, deg_to_rad(current_angle))
		parent.transform = parent.transform.translated_local(-pivot)
	else:
		parent.rotate(direction, deg_to_rad(current_angle))


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
