extends Node2D

var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var barell_scene = preload("res://scenes/barell.tscn")
var obstacle_types := [bird_scene, stump_scene, rock_scene, barell_scene]
var screen_size: Vector2i
const dino_start_pos = Vector2i(146, 520)
const cam_start_pos = Vector2i(576, 329)
const start_speed: int = 5
const max_speed = 12
var speed: float
var score: int
const ground_obstacle_vertical_transform: float = 176
const air_obstacle_vertical_transform: float = 10
var obstacles: Array
var last_obstacle
var start_button: bool = false
var is_game_ended: bool = false

func _ready() -> void:
	randomize()
	$HUD/TitleScreen.text = "Press Spacebar to start the game !"
	$HUD/Score.text = "Score: " + str(score)
	screen_size = get_window().size
	start()
	
func spawn_obstacle():
	if obstacles.is_empty():
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		obs = obs_type.instantiate()
		if(obs_type != obstacle_types[0]):
			obs.scale = Vector2(3,3)
			obs.position = Vector2($Dinosaur.position.x + 1200, 530)
		else:
			obs.scale = Vector2(1.3, 1.3)
			obs.position = Vector2($Dinosaur.position.x + 1200, 440)
		last_obstacle = obs
		add_child(obs)
		obs.body_entered.connect(_on_obs_body_entered)
		obstacles.append(obs)
		
func _on_obs_body_entered(body):
	if(body.name == "Dinosaur"):
		die()
	
func die():
	is_game_ended = true
	set_process(false)
	start_button = false
	set_process(true)
	$Dinosaur.set_physics_process(false)
	last_obstacle.queue_free()
	$Dinosaur.get_node("DinosaurAnimations").play("Die")
	$HUD/Restart.visible = true
	
	
func destroy_obstacle():
	if(last_obstacle):
		if $Camera2D.position.x - last_obstacle.position.x > screen_size.x * 0.7:
			last_obstacle.queue_free()
			obstacles.erase(last_obstacle)

func restart():
	obstacles = []
	$HUD/Restart.visible = false
	score = 0
	$HUD/Score.text = "Score: " + str(score)
	$Dinosaur.set_physics_process(true)
	is_game_ended = false
	start_button = true
	
func start():
	$Dinosaur.set_physics_process(false)
	$Dinosaur.get_node("DinosaurAnimations").play("Idle")
	score = 0
	$HUD/Score.text = "Score: " + str(score)
	speed = start_speed
	$Dinosaur.position = dino_start_pos
	$Dinosaur.velocity = Vector2(0,0)
	$Camera2D.position = cam_start_pos
	$Floor.position = Vector2(0,0)

func _process(delta: float) -> void:
	if(!is_game_ended):
		if(Input.is_action_just_pressed("ui_accept") and start_button == false):
			start_button = true
			$Dinosaur.set_physics_process(true)
			$HUD/TitleScreen.hide()
			
		if(start_button):
			spawn_obstacle()
			destroy_obstacle()
			$HUD/Score.text = "Score: " + str(score)
			if(speed <= max_speed):
				speed += 0.001
				score += speed
			$Dinosaur.position.x += speed
			$Camera2D.position.x += speed
			if $Camera2D.position.x - $Floor.position.x > screen_size.x * 1.5:
				$Floor.position.x += screen_size.x
	else:
		if(Input.is_action_just_pressed("restart")):
			restart()

func _on_timer_timeout() -> void:
	if(!start_button and !is_game_ended):
		if($HUD/TitleScreen.visible == true):
			$HUD/TitleScreen.hide()
		else:
			$HUD/TitleScreen.show()
