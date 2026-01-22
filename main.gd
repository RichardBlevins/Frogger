extends Node2D

@export var car_scene: PackedScene
@export var log_scene: PackedScene
var roadkill_scene = preload("res://Resources/deadfrog.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.died.connect(spawn_roadkill)

func spawn_roadkill(pos: Vector2):
	var roadkill = roadkill_scene.instantiate()
	add_child(roadkill)
	roadkill.global_position = pos
	


func _on_timer_timeout() -> void:
	var GRID = -32
	var car = car_scene.instantiate()
	
	var random_car_location = randi_range(1,5)
	
	car.position = Vector2(randf_range(256, 500), GRID * random_car_location)
	
	add_child(car)


func _on_log_timer_timeout() -> void:
	var GRID = -32
	var log = log_scene.instantiate()
	var random_log_location = randi_range(1,5)
	
	# Determine direction based on row (odd rows go right, even go left)
	var direction = 1 if random_log_location % 2 == 1 else -1
	
	# Spawn on right side for leftward logs, left side for rightward logs
	var spawn_x = 300 if direction == -1 else -256
	
	log.position = Vector2(spawn_x, -208 + GRID * random_log_location)
	
	# Set the log's direction (assuming your log script has a speed/direction variable)
	log.speed *= direction 
	print(spawn_x)
	add_child(log)
