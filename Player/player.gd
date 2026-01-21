extends CharacterBody2D
const GRID = 32
var cooldown = false
var is_dead = false  # Prevent multiple death calls
var on_log = false  # Track if player is on a log
var current_log = null  # Reference to the log we're standing on
@export var lives = 3
@onready var camera = $Camera2D
@onready var raycast = $RayCast
@onready var frogPivot = $Pivot
@onready var frogidle = $Pivot/FrogwizootteIdle
@onready var frogjumping = $Pivot/Frogwizootte1
@onready var hitbox = $Hitbox  # Make sure to reference your Area2D
signal died(death_position)

func _ready() -> void:
	camera.position.x -= GRID * 8
	spawn_scene()
		
func _physics_process(delta: float) -> void:
	# Don't allow input while dead
	if is_dead:
		return
	
	# Check water and logs every frame
	check_water_and_logs(delta)
	
	var direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	var illdirectionlist = [Vector2.ZERO, Vector2.ONE, -Vector2.ONE, Vector2(1, -1), Vector2(-1, 1)]
	
	# Only move if a key was just pressed
	if direction not in illdirectionlist and cooldown == false and (
		Input.is_action_just_pressed("ui_right") or
		Input.is_action_just_pressed("ui_left") or
		Input.is_action_just_pressed("ui_up") or
		Input.is_action_just_pressed("ui_down")
	):
		cooldown = true
		raycast.target_position = direction * GRID                #RAYCAST ROTATION
		frogPivot.look_at(raycast.target_position + position)     #FROG ROTATION
		position += direction * GRID                              #MOVEMENT
		hop_animation()
		await get_tree().create_timer(0.1).timeout  
		cooldown = false
	
	move_and_slide()

func check_water_and_logs(delta: float):
	# Reset log status
	on_log = false
	current_log = null
	
	# Get all overlapping areas
	var overlapping_areas = hitbox.get_overlapping_areas()
	
	# First check if we're on a log
	for area in overlapping_areas:
		if area.is_in_group("log"):
			on_log = true
			current_log = area
			# Move with the log (adjust based on your log's implementation)
			# If your log has a velocity variable:
			if area.has_method("get_velocity"):
				position.x += area.get_velocity() * delta
			# Or if the log parent has a velocity:
			elif area.get_parent().has("velocity"):
				position.x += area.get_parent().velocity.x * delta
			break
	
	# Then check if we're in water
	var in_water = false
	for area in overlapping_areas:
		if area.is_in_group("water"):
			in_water = true
			break
	
	# Die only if in water AND not on a log
	if in_water and not on_log:
		die()

func spawn_scene():
	is_dead = false
	process_mode = Node.PROCESS_MODE_DISABLED
	position = Vector2(-256, -16)
	frogPivot.rotation = 0
	
	for intro in 8:
		await get_tree().create_timer(0.5).timeout
		position.x += GRID
		hop_animation()
	
	process_mode = Node.PROCESS_MODE_INHERIT
	
func hop_animation():
	frogidle.visible = false 
	frogjumping.visible = true
	await get_tree().create_timer(0.1).timeout
	frogidle.visible = true
	frogjumping.visible = false

func die():
	# Prevent multiple death calls
	if is_dead:
		return
	
	is_dead = true
	lives -= 1
	
	# Check if game over
	if lives <= 0:
		Manager.Death()
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		# Respawn after a brief delay
		visible = false
		await get_tree().create_timer(0.5).timeout
		spawn_scene()
		visible = true

func _screen_exited() -> void:
	die()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("car"):
		died.emit(global_position)
		die()
	# Removed the instant water death - now handled in check_water_and_logs()
