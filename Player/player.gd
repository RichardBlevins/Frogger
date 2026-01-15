extends CharacterBody2D
const GRID = 32
var cooldown = false
var is_dead = false  # Prevent multiple death calls
@export var lives = 3
@onready var raycast = $RayCast
@onready var frogPivot = $Pivot
@onready var frogidle = $Pivot/FrogwizootteIdle
@onready var frogjumping = $Pivot/Frogwizootte1

signal died(death_position)

func _ready() -> void:
	spawn_scene()
		
func _physics_process(_delta: float) -> void:
	print(lives)
	# Don't allow input while dead
	if is_dead:
		return
		
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
	died.emit(global_position)
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
	die()
