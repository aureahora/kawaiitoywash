extends Node2D

@onready var manager: Node2D = get_parent()
var clean_sprite: Sprite2D
var dirty_sprite: Sprite2D

var dirty_image: Image
var dirty_texture: ImageTexture
var is_dragging: bool = false
var brush_radius: int = 45 
var total_dirty_pixels: float = 0.0
var erased_pixels: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	# Создаем спрайт чистой игрушки
	clean_sprite = Sprite2D.new()
	clean_sprite.position = Vector2(540, 1080)
	add_child(clean_sprite)
	
	# Создаем спрайт грязной игрушки сверху
	dirty_sprite = Sprite2D.new()
	dirty_sprite.position = Vector2(540, 1080)
	add_child(dirty_sprite)

func _process(delta: float) -> void:
	# Кавайное покачивание (Idle) игрушки, пока игрок ее моет
	time_passed += delta * 3.2
	var wobble_y = sin(time_passed) * 12.0
	var pulse = 1.0 + cos(time_passed * 0.4) * 0.02
	
	var pos = Vector2(540, 1080 + wobble_y)
	var sc = Vector2(1.0, 1.0) * pulse
	
	clean_sprite.position = pos
	clean_sprite.scale = sc
	dirty_sprite.position = pos
	dirty_sprite.scale = sc

func prepare_character_textures(folder: String) -> void:
	clean_sprite.texture = load("res://assets/characters/" + folder + "/clean.webp")
	var orig_tex = load("res://assets/characters/" + folder + "/dirty.webp")
	if not orig_tex: return
	
	dirty_image = orig_tex.get_image()
	total_dirty_pixels = 0.0
	erased_pixels = 0.0
	
	# Оптимизированный шаг 5 для плавного подсчета без лагов на Xiaomi Redmi 12C
	for x in range(0, dirty_image.get_width(), 5):
		for y in range(0, dirty_image.get_height(), 5):
			if dirty_image.get_pixel(x, y).a > 0.1:
				total_dirty_pixels += 1.0
				
	dirty_texture = ImageTexture.create_from_image(dirty_image)
	dirty_sprite.texture = dirty_texture

func _unhandled_input(event: InputEvent) -> void:
	if not manager.is_active or manager.game_state != "PLAYING" or dirty_image == null: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		if is_dragging: erase_at(get_local_mouse_position())
	elif event is InputEventMouseMotion and is_dragging:
		erase_at(get_local_mouse_position())

func erase_at(mouse_pos: Vector2) -> void:
	var local_pos = dirty_sprite.to_local(mouse_pos)
	var img_x = int(local_pos.x + dirty_image.get_width() / 2.0)
	var img_y = int(local_pos.y + dirty_image.get_height() / 2.0)
	var changed = false
	
	for x in range(img_x - brush_radius, img_x + brush_radius):
		for y in range(img_y - brush_radius, img_y + brush_radius):
			if x >= 0 and x < dirty_image.get_width() and y >= 0 and y < dirty_image.get_height():
				if Vector2(x, y).distance_to(Vector2(img_x, img_y)) <= brush_radius:
					if dirty_image.get_pixel(x, y).a > 0.0:
						dirty_image.set_pixel(x, y, Color(0, 0, 0, 0))
						erased_pixels += 0.09
						changed = true
						
	if changed:
		dirty_texture.update(dirty_image)
		var percent = min(int((erased_pixels / total_dirty_pixels) * 100), 100)
		manager.ui.update_progress_text(percent)
		manager.get_node("EffectManager").spawn_asmr_bubble(mouse_pos)
		
		if percent >= 85:
			manager.complete_level()

func hide_dirty_sprite() -> void:
	dirty_sprite.texture = null
	is_dragging = false
