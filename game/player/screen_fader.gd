class_name ScreenFader extends Control

@export var fade_speed : float = 1.0 ## Transition time
@export var fade_cooldown : float = 1.0 ## Time before next action happens again? Or should it be done manually?

@export_group("Default values; Do not touch")
@export var black_screen : ColorRect

var fade_status : bool = false 
var currently_fading : bool = false


func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if event.pressed and event.keycode == KEY_R:
				# _fade_screen()
				_fade_screen_custom_color(Color.WHITE)


## Is a toggle
## Should probably have one where it's guaranteed to either flick or not
## Should also have color
func _fade_screen(new_fade_speed: float = fade_speed, new_fade_cooldown: float = fade_cooldown) -> void:
	if !currently_fading:
		currently_fading = true
		var tween : Tween = get_tree().create_tween()

		if fade_status:
			tween.tween_property(black_screen, "color:a", 0.0, new_fade_speed)
		else:
			tween.tween_property(black_screen, "color:a", 1.0, new_fade_speed)
		
		fade_status = !fade_status

		await get_tree().create_timer(new_fade_cooldown).timeout

		currently_fading = false


func _fade_screen_custom_color(
							fade_color : Color = Color.BLACK,
							new_fade_speed: float = fade_speed, 
							new_fade_cooldown: float = fade_cooldown) -> void:
	if !currently_fading:
		currently_fading = true
		black_screen.color = fade_color

		var tween : Tween = get_tree().create_tween()

		if fade_status:
			black_screen.color.a = 1.0
			tween.tween_property(black_screen, "color:a", 0.0, new_fade_speed)
		else:
			black_screen.color.a = 0.0
			tween.tween_property(black_screen, "color:a", 1.0, new_fade_speed)
		
		fade_status = !fade_status

		await get_tree().create_timer(new_fade_cooldown).timeout

		currently_fading = false
