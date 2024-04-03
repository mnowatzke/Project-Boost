extends RigidBody3D

@export_range(750, 3000) var thrust : float = 1000.0
@export_range(100, 300) var torque : float = 100.0

#this transitioning function will help control if other functions
#should be called when transitioning eg crashing > restarting the game
var is_transitioning : bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("up"):
		# basis is a 3x3 matrix controlling x, y, and z rotation.. I think
		# this let's us apply our torques left and right with the up.. I think
		apply_central_force(basis.y * delta * thrust)
		
	if Input.is_action_pressed("left"):
		apply_torque(Vector3(0.0, 0.0, torque * delta))
		
	if Input.is_action_pressed("right"):
		apply_torque(Vector3(0.0, 0.0, -torque * delta))


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazard" in body.get_groups():
			crash_sequence()
		
func crash_sequence() -> void:
	print("BOOM!")
	# set process determines if _process function is working
	# by disabling it the player can't do anything
	set_process(false)
	is_transitioning = true
	# we use a tween to set a delay between the reload current scene
	# note the lack of () on the end of reload_current_scene when calling that func
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file : String) -> void:
	print("Way to go space cowboy!")
	# stop player movement
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
		)
	
