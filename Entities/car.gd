extends Area2D

var base_speed = randf_range(1 , 1.5)
var speed = base_speed
var max_speed = 2.0
var min_speed = 0.2

@onready var front = $Front
@onready var back = $Back
@onready var texture_nodes = [
	$cars/Carl,
	$cars/Carls,
	$cars/Cars2,
	$cars/Flesh
]

# Driving behavior parameters
var safe_distance = 80.0  # Preferred distance from car in front
var panic_distance = 50.0  # Emergency brake distance
var acceleration = 0.05
var brake_force = 0.1

func _ready():
	# Show one random texture
	var random_index = randi() % texture_nodes.size()
	texture_nodes[random_index].visible = true

func _process(delta: float) -> void:
	
	var front_collider = front.get_collider()
	var back_collider = back.get_collider()
	
	# Check distance to car in front
	if front.is_colliding() and front_collider:
		var distance = position.distance_to(front_collider.global_position)

		# Panic brake if too close
		if distance < panic_distance:
			speed -= brake_force * 2
		# Gradual slow down if within safe distance
		elif distance < safe_distance:
			var slow_factor = (safe_distance - distance) / safe_distance
			speed -= brake_force * slow_factor
		# Match speed if comfortable distance
		else:
			speed = lerp(speed, base_speed, 0.02)
	else:
		# No car in front - accelerate back to base speed
		if speed < base_speed:
			speed += acceleration
	
	# Check if being tailgated
	if back.is_colliding() and back_collider:
		var distance = position.distance_to(back_collider.global_position)
		
		# Speed up a bit to create space
		if distance < safe_distance * 0.7:
			speed += acceleration * 0.5
	
	# Clamp speed to realistic limits
	speed = clamp(speed, min_speed, max_speed)
	
	# Move the car
	position.x -= speed


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("car"):
		queue_free()
	#explode... when touching car

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
