extends CharacterBody2D

enum STATE {PLAY, ANIMATION}

const GRID = 32
var cooldown = false
@export var lives = 3

@onready var raycast = $RayCast
@onready var frogPivot = $Pivot

@onready var frogidle = $Pivot/FrogwizootteIdle
@onready var frogjumping = $Pivot/Frogwizootte1

func _ready() -> void:
	for intro in 7:
		await get_tree().create_timer(0.4).timeout
		position.x += GRID
		print(position)
		hop_animation()
	process_mode = Node.PROCESS_MODE_INHERIT
		

func _physics_process(_delta: float) -> void:
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
			position += direction * GRID                            #MOVMENT
			hop_animation()
			await get_tree().create_timer(0.1).timeout  
			cooldown = false
		
		move_and_slide()


func _screen_exited() -> void:
	if lives <= 0:
		Manager.Death() #this is basically final death game over
	else:
		print(lives)
		lives -= 1
		#this die and den respawn

func hop_animation():
	frogidle.visible = false 
	frogjumping.visible = true
	await get_tree().create_timer(0.1).timeout
	frogidle.visible = true
	frogjumping.visible = false
