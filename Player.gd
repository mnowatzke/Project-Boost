extends RigidBody3D

@export_range(750, 3000) var thrust : float = 1000.0
@export_range(100, 300) var torque : float = 100.0

#this transitioning function will help control if other functions
#should be called when transitioning eg crashing > restarting the game
var is_transitioning : bool = false
# if you ctrl, click and drag the ExplosionAudio child here is will auto create
# this on-ready
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles
@onready var body: MeshInstance3D = $Body


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("up"):
		# basis is a 3x3 matrix controlling x, y, and z rotation.. I think
		# this let's us apply our torques left and right with the up.. I think
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
	
	if Input.is_action_pressed("left"):
		apply_torque(Vector3(0.0, 0.0, torque * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false
	
	if Input.is_action_pressed("right"):
		apply_torque(Vector3(0.0, 0.0, -torque * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
		
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazard" in body.get_groups():
			crash_sequence()
		
func crash_sequence() -> void:
	print("BOOM!")
	explosion_particles.emitting = true
	explosion_audio.play()
	# set process determines if _process function is working
	# by disabling it the player can't do anything
	set_physics_process(false)
	is_transitioning = true
	body.queue_free()
	# we use a tween to set a delay between the reload current scene
	# note the lack of () on the end of reload_current_scene when calling that func
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file : String) -> void:
	print("Way to go space cowboy!")
	success_particles.emitting = true
	success_audio.play()
	# stop player movement
	set_physics_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
		)
	
