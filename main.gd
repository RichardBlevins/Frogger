extends Node2D

@export var car_scene: PackedScene
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
