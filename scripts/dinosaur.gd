extends CharacterBody2D

const jump_velocity = -1000.0
var gravity = 800

func _physics_process(delta: float) -> void:
	if is_on_floor():
		gravity = 800	
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity
			$DinosaurAnimations.animation = "Jump"
			$JumpSound.pitch_scale = randf_range(0.90, 1.1)
			$JumpSound.play()
		
		if Input.is_action_pressed("duck"):
			$DuckCollision.disabled = false
			$NormalCollision.disabled = true
			$DinosaurAnimations.animation = "Duck"
			$DinosaurAnimations.play()
		else:
			$DuckCollision.disabled = true
			$NormalCollision.disabled = false
			$DinosaurAnimations.animation = "Run"
			$DinosaurAnimations.play()
	else:
		gravity += 100
		velocity.y += gravity * delta
		$DinosaurAnimations.animation = "Jump"
	move_and_slide()
