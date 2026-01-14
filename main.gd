extends Node2D

@export var car_scene: PackedScene
@export var dead_frog: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_timer_timeout() -> void:
	var GRID = -32
	var car = car_scene.instantiate()
	var random_car_location = randi_range(1,5)
	
	car.position = Vector2(randf_range(256, 500), GRID * random_car_location)
	add_child(car)
