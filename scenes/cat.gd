extends CharacterBody2D

@onready var jumpSound = $jumpSound
const SPEED = 300.0
const JUMP_VELOCITY = -700.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") + 1500


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		if get_parent().game_running: 
			$runCol.disabled = false
			if Input.is_action_pressed("up"):
				velocity.y = JUMP_VELOCITY
		#			jumpSound.play()
			elif Input.is_action_pressed("down"):
				$runCol.disabled = true
				$AnimatedSprite2D.play("duck")
				position.y = 530
			else:
				$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play('idle')
	else: 
		$AnimatedSprite2D.play("jump")

	move_and_slide()

func _input(event):
	if event.is_action_pressed("up") or event.is_action_pressed("down"):
		jumpSound.play()

#	if is_on_floor():
#		if not get_parent().game_running:
#			$AnimatedSprite2D.play("idle")
#		else:
#			$RunCol.disabled = false
#			if Input.is_action_pressed("ui_accept"):
#				velocity.y = JUMP_SPEED
#				#$JumpSound.play()
#			elif Input.is_action_pressed("ui_down"):
#				$AnimatedSprite2D.play("duck")
#				$RunCol.disabled = true
#			else:
#				$AnimatedSprite2D.play("run")
#	else:
#		$AnimatedSprite2D.play("jump")
#
#	move_and_slide()
