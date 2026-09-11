extends Node

@onready var manager: Node2D = get_parent()
var ui_layer: CanvasLayer
var top_panel: Panel
var label_level_name: Label
var label_progress: Label
var label_rank: Label

var menu_overlay: Panel
var menu_box: Panel
var menu_title: Label
var menu_subtitle: Label
var menu_button: Button

var animation_time: float = 0.0

func _ready() -> void:
	setup_ui_elements()

func _process(delta: float) -> void:
	if menu_overlay and menu_overlay.visible:
		animation_time += delta * 4.0
		var wobble_y = sin(animation_time) * 10.0
		var scale_pulse = 1.0 + cos(animation_time * 0.5) * 0.03
		
		menu_box.position = Vector2(110, 560 + wobble_y)
		menu_box.scale = Vector2(scale_pulse, scale_pulse)
		menu_box.pivot_offset = menu_box.size / 2.0

func setup_ui_elements() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	top_panel = Panel.new()
	top_panel.position = Vector2(90, 60)
	top_panel.size = Vector2(900, 320) 
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color("5c4d6c") 
	top_style.set_border_width_all(24) 
	top_style.border_color = Color("ffccd5") 
	top_style.set_corner_radius_all(35)
	top_panel.add_theme_stylebox_override("panel", top_style)
	ui_layer.add_child(top_panel)
	
	label_level_name = create_label(Vector2(0, 40), Vector2(900, 60), 64, Color("ffffff"), top_panel)
	label_progress = create_label(Vector2(0, 125), Vector2(900, 80), 76, Color("ffb3c1"), top_panel)
	label_rank = create_label(Vector2(0, 230), Vector2(900, 50), 54, Color("b3f0ff"), top_panel)
	
	setup_menu_windows()

func setup_menu_windows() -> void:
	menu_overlay = Panel.new()
	menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var overlay_style = StyleBoxFlat.new()
	overlay_style.bg_color = Color(0, 0, 0, 0.5)
	menu_overlay.add_theme_stylebox_override("panel", overlay_style)
	ui_layer.add_child(menu_overlay)
	
	menu_box = Panel.new()
	menu_box.size = Vector2(860, 800) 
	menu_box.position = Vector2(110, 560)
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = Color("ffffff")
	box_style.set_border_width_all(32) 
	box_style.border_color = Color("ffccd5") 
	box_style.set_corner_radius_all(50)
	menu_box.add_theme_stylebox_override("panel", box_style)
	menu_overlay.add_child(menu_box)
	
	# ИСПРАВЛЕНО: Размер уменьшен до 84, добавлены боковые границы (сдвиг x=40, ширина=780)
	menu_title = create_label(Vector2(40, 80), Vector2(780, 120), 84, Color("ff4081"), menu_box)
	menu_subtitle = create_label(Vector2(60, 240), Vector2(740, 240), 64, Color("4a4a4a"), menu_box)
	menu_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	menu_button = Button.new()
	menu_button.size = Vector2(520, 140)
	menu_button.position = Vector2(170, 540)
	menu_button.add_theme_font_size_override("font_size", 64) 
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("ff4081") 
	btn_style.set_corner_radius_all(40)
	btn_style.set_border_width_all(6)
	btn_style.border_color = Color("ffffff")
	
	menu_button.add_theme_stylebox_override("normal", btn_style)
	menu_button.add_theme_stylebox_override("hover", btn_style)
	menu_button.add_theme_stylebox_override("pressed", btn_style)
	menu_button.add_theme_stylebox_override("focus", btn_style) 
	
	menu_button.pressed.connect(func(): manager._on_menu_button_pressed())
	menu_box.add_child(menu_button)

func create_label(pos: Vector2, size: Vector2, font_size: int, color: Color, parent_node: Node) -> Label:
	var lbl = Label.new()
	lbl.position = pos
	lbl.size = size
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	parent_node.add_child(lbl)
	return lbl

func show_menu_window(title: String, sub: String, btn_text: String) -> void:
	top_panel.visible = false
	menu_overlay.visible = true
	menu_title.text = title
	menu_subtitle.text = sub
	menu_button.text = btn_text
	animation_time = 0.0

func hide_menu_window() -> void:
	menu_overlay.visible = false
	top_panel.visible = true

func update_level_info(title: String, rank: String) -> void:
	label_level_name.text = "TARGET: " + title.to_upper()
	label_rank.text = "RANK: " + rank

func update_progress_text(percent: int) -> void:
	label_progress.text = "CLEANED: " + str(percent) + "%"
