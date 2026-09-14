extends Node2D

var levels: Array[String] = []
var level_titles: Array[String] = []
var ranks: Array[String] = []
var current_level_index: int = 0
var game_state: String = "START_SCREEN"
var is_active: bool = false
var is_cloud_data_ready: bool = false

@onready var ui: Node = $UIManager
@onready var painter: Node = $ScratchPainter
var tutorial_label: Label
var final_win_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	RenderingServer.set_default_clear_color(Color("443850")) 
	setup_100_levels_data()
	
	# БЕЗОПАСНЫЙ ВЫЗОВ ИНИЦИАЛИЗАЦИИ БЕЗ ИМЕНИ КЛАССА
	var wrapper = get_node_or_null("/root/YTGameWrapper")
	if wrapper:
		if wrapper.has_method("game_ready"):
			wrapper.game_ready()
		
		# Безопасное подключение сигналов рекламы, сохранений и звуков
		if wrapper.has_signal("audio_enabled_changed"): 
			wrapper.audio_enabled_changed.connect(_on_youtube_audio_changed)
		if wrapper.has_signal("game_paused"): 
			wrapper.game_paused.connect(_on_youtube_game_paused)
		if wrapper.has_signal("game_resumed"): 
			wrapper.game_resumed.connect(_on_youtube_game_resumed)
		if wrapper.has_signal("load_data_received"): 
			wrapper.load_data_received.connect(_on_youtube_data_loaded)
		if wrapper.has_signal("ad_request_success"): 
			wrapper.ad_request_success.connect(_on_ad_finished)
		if wrapper.has_signal("ad_request_failed"): 
			wrapper.ad_request_failed.connect(_on_ad_failed)
			
	ui.show_menu_window("KAWAII TOY WASH", "Welcome! Clean all the dirty toys!", "PLAY")
	setup_tutorial_label()


func load_level(index: int) -> void:
	# --- ИСПРАВЛЕНИЕ ДЛЯ YOUTUBE SDK ---
	# Прямой вызов window.ytgame.gameReady() удален, так как он вызывается строго один раз в _ready()
	# -----------------------------------
	
	if index >= levels.size():
		game_state = "GAME_WIN"
		final_win_timer = 0.0
		ui.show_menu_window("VICTORY! ", "You are the Ultimate Supreme Washer!", "REPLAY")
		is_active = false
		return

	# Вызов межстраничной рекламы раз в 4 уровня
	if index > 0 and index % 4 == 0 and game_state != "PLAYING" and index % 20 != 0:
		var wrapper = get_node_or_null("/root/YTGameWrapper")
		if wrapper and wrapper.has_method("request_interstitial_ad"):
			wrapper.request_interstitial_ad()

	game_state = "PLAYING"
	current_level_index = index
	RenderingServer.set_default_clear_color(Color("443850"))
	ui.update_level_info(level_titles[index], ranks[index])
	painter.prepare_character_textures(levels[index])
	tutorial_label.visible = (index == 0)
	is_active = true
	
func setup_100_levels_data() -> void:
	# СТРОГО СИНХРОНИЗИРОВАНО С ВАШИМИ РЕАЛЬНЫМИ ПРОМТАМИ И ФАЙЛАМИ (БЕЗ ПУТАНИЦЫ)
	var base_ids = [
		# Отдел 1: Бесплатная классика (1-4 старые, 5-20 обновленные под ваши файлы)
		"witch","cat","gamer","dragon","unicorn","elf","griffin","necromancer","pixie","golem","phoenix_fox","mermaid","shroom","cookie_knight","elemental","valkyrie","pegasus","cerberus","shaman","gold_phoenix",
		# Отдел 2: Магия и Сказки (21-40 полностью уникальные, без повторов контента)
		"genie","dryad","sphinx","alchemist","cloud_pegasus","amethyst_drake","fire_bird","lake_undine","root_gnome","tin_soldier","book_spirit","ice_queen","winged_lion","minotaur","time_mage","emerald_basilisk","kitsune","pegacorn","kraken","dragon_king",
		# Отдел 3: Космос и Галактика (41-60)
		"alien","astronaut","rocket_cat","star_bunny","moon_hamster","ufo_saucer","nebula_fox","robo_rover","comet_dog","solar_lion","astro_slime","star_whale","cosmic_ray","asteroid_golem","pulsar_deer","stardust_fairy","blackhole_kitty","saturn_raccoon","gravity_mouse","galaxy_phoenix",
		# Отдел 4: Кибер-роботы (61-80)
		"neon_bot","cyber_dog","matrix_cat","laser_rabbit","pixel_duck","holo_deer","synth_fox","gear_owl","wire_mouse","battery_bear","cyber_dragon","ai_core","glitch_slime","led_penguin","plasma_jelly","data_bee","circuit_frog","chip_squirrel","hacker_raccoon","mech_titan",
		# Отдел 5: Сладкое королевство (81-100)
		"donut_bear","cupcake_cat","marshmallow_bunny","icecream_penguin","candy_fox","chocolate_dog","berry_mouse","waffle_lion","pancake_sloth","lollipop_dragon","biscuit_koala","macaron_frog","jelly_whale","popcorn_squirrel","cream_deer","pudding_pig","cookie_owl","mint_shark","honey_bee","cake_castle"
	]

	var base_names = [
		"Cute Witch","Neko Cat","Pro Gamer","Chibi Dragon","Marshmallow Unicorn","Forest Elf","Pocket Griffin","Chibi Necromancer","Tinker Fairy","Ice Golem","Fire Foxey","Princess Mermaid","Baby Shroom","Cookie Knight","Water Spirit","Chibi Valkyrie","Sky Pegasus","Puppy Cerberus","Forest Shaman","Golden Phoenix",
		"Magic Genie","Forest Dryad","Little Sphinx","Chibi Alchemist","Cloud Pegasus","Amethyst Drake","Fire Bird","Lake Undine","Root Gnome","Tin Soldier","Book Spirit","Ice Queen","Winged Lion","Baby Minotaur","Time Mage","Emerald Basilisk","Nine-Tail Kitsune","Star Pegacorn","Tiny Kraken","Imperial Dragon",
		"Green Martian","Astro Bear","Rocket Neko","Cosmic Bunny","Moon Hamster","Tiny UFO","Nebula Fox","Mars Rover","Comet Puppy","Solar Simba","Space Slime","Galaxy Whale","Cosmic Ray","Meteor Golem","Pulsar Deer","Stardust Pixie","Void Kitty","Saturn Ring","Zero-G Mouse","Supernova Bird",
		"Robo Buddy","Cyber-Corgi","Matrix Neko","Laser Bunny","Retro Duck","Holo Fawn","Synthwave Fox","Steampunk Owl","Electric Mouse","Battery Teddy","Neon Drake","Cute AI Core","Glitch Slime","LED Penguin","Plasma Jelly","Byte Bee","Circuit Frog","Micro Chipmunk","Hack Raccoon","Chibi Mech",
		"Donut Teddy","Cupcake Neko","Mochi Bunny","Sundae Penguin","Caramel Fox","Choco Puppy","Berry Mouse","Waffle Simba","Honey Sloth","Candy Drake","Biscuit Koala","Macaron Frog","Gummy Whale","Popcorn Pop","Vanilla Deer","Pudding Piglet","Sugar Owl","Minty Shark","Sweet Honey","Grand Birthday Cake"
	]

	for i in range(100):
		levels.append("lvl" + str(i+1) + "_" + base_ids[i])
		level_titles.append(base_names[i])
		if i < 20: ranks.append("Toy Novice 🧸")
		elif i < 40: ranks.append("Bubbles Expert 🧼")
		elif i < 60: ranks.append("Shiny Master ✨")
		elif i < 80: ranks.append("Cyber Cleaner 🤖")
		else: ranks.append("Legendary Washer 👑")

func setup_tutorial_label() -> void:
	tutorial_label = Label.new()
	tutorial_label.text = "🧼 SWIPE TO WASH! 👇"
	tutorial_label.position = Vector2(0, 1450)
	tutorial_label.size = Vector2(1080, 100)
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.add_theme_font_size_override("font_size", 48)
	tutorial_label.add_theme_color_override("font_color", Color("ffccd5"))
	tutorial_label.visible = false
	add_child(tutorial_label)

func _on_youtube_audio_changed(is_enabled: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not is_enabled)

func _on_youtube_game_paused() -> void:
	get_tree().paused = true

func _on_youtube_game_resumed() -> void:
	get_tree().paused = false

func _on_youtube_data_loaded(save_data_string: String) -> void:
	is_cloud_data_ready = true
	if save_data_string.is_empty(): return
	var json = JSON.new()
	if json.parse(save_data_string) == OK:
		var data = json.get_data()
		if data.has("saved_level"):
			current_level_index = int(data["saved_level"])
		
func save_progress_to_youtube() -> void:
	if not is_cloud_data_ready: 
		return
	var save_dict = {"saved_level": current_level_index}
	var save_string = JSON.stringify(save_dict)
	
	# --- ИСПРАВЛЕНИЕ: Прямое безопасное обращение к синглтону ---
	if typeof(YTGameWrapper) != TYPE_NIL and YTGameWrapper.has_method("save_data"):
		YTGameWrapper.save_data(save_string)
		print("YouTube SDK: Прогресс сохранен в облако: ", save_string)
	# ------------------------------------------------------------

func _on_ad_finished() -> void: _proceed_after_ad()
func _on_ad_failed(_err: String) -> void: _proceed_after_ad()

func _proceed_after_ad() -> void:
	if ui.menu_overlay.visible:
		ui.hide_menu_window()
		load_level(current_level_index)

func _on_menu_button_pressed() -> void:
	if game_state == "GAME_WIN":
		current_level_index = 0
		game_state = "START_SCREEN"
		save_progress_to_youtube()
		ui.hide_menu_window()
		load_level(current_level_index)
		return
		
	# ИСПРАВЛЕНИЕ: Безопасное обращение к синглтону напрямую без get_node()
	if current_level_index > 0 and current_level_index % 20 == 0 and game_state == "PLAYING":
		if typeof(YTGameWrapper) != TYPE_NIL and YTGameWrapper.has_method("request_interstitial_ad"):
			YTGameWrapper.request_interstitial_ad()
		return
		
	ui.hide_menu_window()
	load_level(current_level_index)
	
func _process(delta: float) -> void:
	if game_state == "GAME_WIN":
		final_win_timer += delta
		if final_win_timer >= 0.15:
			final_win_timer = 0.0
			var r_pos = Vector2(randf_range(200, 880), randf_range(400, 1500))
			$EffectManager.spawn_asmr_bubble(r_pos)
	if tutorial_label and tutorial_label.visible:
		tutorial_label.modulate.a = 0.4 + abs(sin(Time.get_ticks_msec() * 0.004)) * 0.6

func complete_level() -> void:
	is_active = false
	game_state = "LEVEL_WIN"
	if tutorial_label and tutorial_label.visible:
		tutorial_label.visible = false
	RenderingServer.set_default_clear_color(Color("cce6ff"))
	ui.update_progress_text(100)
	painter.hide_dirty_sprite()
	$EffectManager.spawn_victory_firework()
	
	# ИСПРАВЛЕНИЕ: Безопасная отправка счета напрямую в автозагрузку
	var score = (current_level_index + 1) * 100
	if typeof(YTGameWrapper) != TYPE_NIL and YTGameWrapper.has_method("send_score"):
		YTGameWrapper.send_score(score)
		
	save_progress_to_youtube()
	get_tree().create_timer(1.2).timeout.connect(func():
		var title = "SO CLEAN! "
		var sub = "You successfully washed the " + level_titles[current_level_index] + "!"
		current_level_index += 1
		if current_level_index % 20 == 0 and current_level_index < 100:
			var d_name = ""
			if current_level_index == 20: d_name = "Magic & Fantasy "
			elif current_level_index == 40: d_name = "Space & Galaxy "
			elif current_level_index == 60: d_name = "Cyber & Robots "
			elif current_level_index == 80: d_name = "Sweet Kingdom "
			ui.show_menu_window("NEW PACK UNLOCKED!", "Watch a short video to unlock the " + d_name + " department!", "UNLOCK WITH AD ")
		else:
			ui.show_menu_window(title, sub, "CONTINUE")
	)
	
func _unhandled_input(event: InputEvent) -> void:
	if tutorial_label and tutorial_label.visible:
		if event is InputEventMouseButton and event.pressed:
			tutorial_label.visible = false
