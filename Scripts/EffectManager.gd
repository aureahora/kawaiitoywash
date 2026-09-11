extends Node2D

var bubble_sound: AudioStreamPlayer
var win_sound: AudioStreamPlayer

func _ready() -> void:
	# ВРЕМЕННО ОТКЛЮЧАЕМ ВЕБ-ЗАГРУЗКУ ЗВУКОВ ДЛЯ ИСКЛЮЧЕНИЯ ВЫЛЕТОВ В HTML5
	bubble_sound = AudioStreamPlayer.new()
	add_child(bubble_sound)

	win_sound = AudioStreamPlayer.new()
	add_child(win_sound)
	
	print("ℹ️ Звуковые модули переведены в безопасный веб-режим")

func spawn_asmr_bubble(pos: Vector2) -> void:
	# Воспроизводим ASMR-звук пузыря (с небольшой случайной высотой тона для разнообразия)
	if bubble_sound and bubble_sound.stream:
		bubble_sound.pitch_scale = randf_range(0.9, 1.3)
		bubble_sound.play()

	var bubble = Label.new()
	bubble.text = "🫧"
	bubble.add_theme_font_size_override("font_size", randi_range(36, 56))
	bubble.position = pos + Vector2(randf_range(-25, 25), randf_range(-25, 25))
	add_child(bubble)

	var direction = Vector2(randf_range(-0.5, 0.5), -1.0).normalized()
	var speed = randf_range(120, 220)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(bubble, "position", bubble.position + direction * speed, 0.5)
	tween.tween_property(bubble, "scale", Vector2(1.4, 1.4), 0.5)
	tween.tween_property(bubble, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(bubble.queue_free)

func spawn_victory_firework() -> void:
	# Воспроизводим победный радостный возглас
	if win_sound and win_sound.stream:
		win_sound.play()

	var center = Vector2(540, 1080)
	for i in range(55):
		var star = Label.new()
		star.text = ["✨", "⭐", "🌸", "💖", "🌈"].pick_random()
		star.add_theme_font_size_override("font_size", randi_range(44, 74))
		star.position = center
		add_child(star)

		var angle = randf_range(0, 2 * PI)
		var direction = Vector2(cos(angle), sin(angle))
		var speed = randf_range(250, 550)

		var tween = create_tween().set_parallel(true)
		tween.tween_property(star, "position", center + direction * speed, 1.6)
		tween.tween_property(star, "rotation", randf_range(-5, 5), 1.6)
		tween.tween_property(star, "modulate:a", 0.0, 1.6)
		tween.chain().tween_callback(star.queue_free)
