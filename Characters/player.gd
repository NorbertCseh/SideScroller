extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -150.0
@export var double_jump_velocity: float = -200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_double_jump: bool = false
var is_animation_locked: bool = false
var direction: Vector2 = Vector2.ZERO
var is_in_air: bool = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		is_in_air = true
	elif is_on_floor():
		is_double_jump = true
		is_animation_locked = false
		is_in_air = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif is_double_jump and not is_on_floor():
			double_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	falling()
	update_animation()
	update_facing_direction()


func update_animation():
	if not is_animation_locked && is_on_floor():
		if direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")


func jump():
	is_animation_locked = true
	velocity.y = jump_velocity
	animated_sprite.play("jump_start")


func double_jump():
	velocity.y += double_jump_velocity
	is_double_jump = false


func update_facing_direction():
	if direction.x < 0:
		animated_sprite.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false


func falling():
	if not is_animation_locked && velocity.y > 0 && is_in_air:
		animated_sprite.play("jump_end")
		is_animation_locked = true
