extends Node

var stump_scene = preload('res://scenes/stump.tscn')
var bush_scene = preload('res://scenes/bush.tscn')
var mushroom_scene = preload('res://scenes/mushroom.tscn')
var bird_scene = preload('res://scenes/bird.tscn')
var obstacle_types := [stump_scene, bush_scene, mushroom_scene, bird_scene]
var obstacle_types_still := [stump_scene, bush_scene]
var obstacle_types_animated := [mushroom_scene, bird_scene]
var obstacles : Array
var bird_heights := [80, 110]

var song_name = "rose_water"


const CAT_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var ground_height : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var score : int 
var high_score : int
const SCORE_MODIFIER : int = 10

var screen_size : Vector2i
var game_running : bool
var last_obs
var time_running: float

var beats := []

# Called when the node enters the scene tree for the first time.
func _ready():
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()*0.09
	screen_size = get_window().size
	new_game()
	

func new_game():
	score = 0
	time_running = 0.0
	showScore()
	
	$Cat.position = CAT_START_POS
	$Cat.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	$HUD/StartLabel.show()
	
	var song_file = "res://assets/sounds/music/" + song_name + ".mp3"
	var beats_file = "res://assets/sounds/music/" + song_name + "_onsets.json"
	$Song.stream = load(song_file)
	process_onsets(beats_file)
#	$Song.playing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running: 
		$Cat.position.x += START_SPEED
		$Camera2D.position.x += START_SPEED
		time_running += delta
		score +=  START_SPEED
		showScore()
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
				$Ground.position.x += screen_size.x
		generate_obs()
		
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		$Song.playing = true
	else:
		if Input.is_action_pressed("up"):
			game_running = true
			time_running = 0.0
			$HUD/StartLabel.hide()
			$Song.playing = true

func process_onsets(file_path):
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var result = JSON.parse_string(data_file.get_as_text())
		if result is Dictionary:
			beats = result['onsets']
		else:
			print("Error: not dictionary")
	else:
		print("Error: file doesn't exist")

func generate_obs():
	if beats.front()-time_running < 0.01:
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
#		var max_obs = 3
#		for i in range(randi() % max_obs):
		obs = obs_type.instantiate()
		var obs_height = 0
		var obs_scale = 0
		var offset = 50
		if obs_type in obstacle_types_still:
			obs_height = obs.get_node("Sprite2D").texture.get_height()
			obs_scale = obs.get_node("Sprite2D").scale
		else: 
			obs_height = obs.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("default", 1).get_size()[1]
			obs_scale = obs.get_node("AnimatedSprite2D").scale
		if obs_type == bird_scene:
			offset = bird_heights[randi() % bird_heights.size()]
		var obs_x  = screen_size.x + score + 100 #+ (i * 100)
		var obs_y  = screen_size.y - ground_height - offset
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		beats.remove_at(0)
	
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Cat":
		game_over()
		

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
#	$Song.playing = false
#	$GameOver.show()

func showScore():
	$HUD/ScoreLabel.text = "SCORE: " + str(score/SCORE_MODIFIER)
