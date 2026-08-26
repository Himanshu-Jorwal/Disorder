extends Node

enum Phase {
	CRESCENT,
	HALF,
	FULL,
	BLOOD,
	BLUE,
	NEW
}

const PHASE_NAMES = {
	Phase.CRESCENT: "Crescent Moon",
	Phase.HALF: "Half Moon",
	Phase.FULL: "Full Moon",
	Phase.BLOOD: "Blood Moon",
	Phase.BLUE: "Blue Moon",
	Phase.NEW: "New Moon"
}

const PHASE_DURATION = 10.0

var paused = false
var current_phase = Phase.CRESCENT
var phase_timer = 0.0
var phase_order = [
	Phase.CRESCENT,
	Phase.HALF,
	Phase.FULL,
	Phase.BLOOD,
	Phase.BLUE,
	Phase.NEW
]
var phase_index = 0
var cycles_completed = 0

signal phase_changed(new_phase)
signal cycle_completed(cycle_number)

func _process(delta):
	if paused:
		return
	phase_timer += delta
	if phase_timer >= PHASE_DURATION:
		phase_timer = 0.0
		advance_phase()

func advance_phase():
	phase_index = (phase_index + 1) % phase_order.size()
	current_phase = phase_order[phase_index]
	print("Moon Phase: ", PHASE_NAMES[current_phase])
	emit_signal("phase_changed", current_phase)
	# Check if completed a full cycle
	if phase_index == 0:
		cycles_completed += 1
		print("Moon Cycle Complete: ", cycles_completed)
		emit_signal("cycle_completed", cycles_completed)

func get_phase_name():
	return PHASE_NAMES[current_phase]

func get_cycles_completed():
	return cycles_completed
