extends CharacterBody3D

@export var speed = 6.0
@export var sprint_speed = 10.0
@export var jump_velocity = 6.0
@export var mouse_sensitivity = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var stamina = 5.0
var max_stamina = 5.0
var third_person = true

var camera_pivot
var camera

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    camera_pivot = Node3D.new()
    add_child(camera_pivot)
    camera = Camera3D.new()
    camera_pivot.add_child(camera)
    camera.transform.origin = Vector3(0, 2, -6)

func _unhandled_input(event):
    if event is InputEventMouseMotion:
        rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
        camera_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.2, 1.2)

    if event.is_action_pressed("ui_accept"):
        third_person = !third_person
        if third_person:
            camera.transform.origin = Vector3(0, 2, -6)
        else:
            camera.transform.origin = Vector3(0, 2, 0)

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta

    var input_dir = Vector3.ZERO

    if Input.is_action_pressed("ui_up"):
        input_dir.z -= 1
    if Input.is_action_pressed("ui_down"):
        input_dir.z += 1
    if Input.is_action_pressed("ui_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("ui_right"):
        input_dir.x += 1

    input_dir = input_dir.normalized()

    var current_speed = speed

    if Input.is_action_pressed("ui_shift") and stamina > 0:
        current_speed = sprint_speed
        stamina -= delta
    else:
        stamina += delta

    stamina = clamp(stamina, 0, max_stamina)

    var direction = (transform.basis * input_dir)
    velocity.x = direction.x * current_speed
    velocity.z = direction.z * current_speed

    if Input.is_action_just_pressed("ui_select") and is_on_floor():
        velocity.y = jump_velocity

    move_and_slide()
