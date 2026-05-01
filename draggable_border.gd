@tool
extends VBoxContainer


## The term "margin" is used to represent the area which will accept mouse input.
enum Margin {
	BOTTOM,
	LEFT,
	RIGHT,
	TOP,
}

@export var resizable: bool = true:
	set(r):
		resizable = r
		
		if %Top and %Left and %Right and %Bottom and %TopLeft and %TopRight and %BottomLeft and %BottomRight:
			var f := Control.MOUSE_FILTER_STOP if resizable else Control.MOUSE_FILTER_IGNORE
			
			%TopLeft.mouse_filter = f
			%Top.mouse_filter = f
			%TopRight.mouse_filter = f
			%Right.mouse_filter = f
			%BottomRight.mouse_filter = f
			%Bottom.mouse_filter = f
			%BottomLeft.mouse_filter = f
			%Left.mouse_filter = f

@export_group("Margins", "margin_")

@export var margin_bottom: int = 4:
	set(m):
		margin_bottom = m
		_resize_margin.call_deferred(Margin.BOTTOM, m)

@export var margin_left: int = 4:
	set(m):
		margin_left = m
		_resize_margin.call_deferred(Margin.LEFT, m)

@export var margin_right: int = 4:
	set(m):
		margin_right = m
		_resize_margin.call_deferred(Margin.RIGHT, m)

@export var margin_top: int = 4:
	set(m):
		margin_top = m
		_resize_margin.call_deferred(Margin.TOP, m)

var _last_hovered: DisplayServer.WindowResizeEdge


func _resize_margin(margin: Margin, value: int) -> void:
	match margin:
		Margin.BOTTOM:
			%BottomLeft.custom_minimum_size.y = value
			%Bottom.custom_minimum_size.y = value
			%BottomRight.custom_minimum_size.y = value
		Margin.LEFT:
			%TopLeft.custom_minimum_size.x = value
			%Left.custom_minimum_size.x = value
			%BottomLeft.custom_minimum_size.x = value
		Margin.RIGHT:
			%TopRight.custom_minimum_size.x = value
			%Right.custom_minimum_size.x = value
			%BottomRight.custom_minimum_size.x = value
		Margin.TOP:
			%TopLeft.custom_minimum_size.y = value
			%Top.custom_minimum_size.y = value
			%TopRight.custom_minimum_size.y = value


func _on_border_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_on_mouse_button(event)


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_window().start_resize(_last_hovered)


#region Borders signals
func _on_bottom_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_BOTTOM
	_on_border_input(event)


func _on_bottom_left_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_BOTTOM_LEFT
	_on_border_input(event)


func _on_bottom_right_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_BOTTOM_RIGHT
	_on_border_input(event)


func _on_left_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_LEFT
	_on_border_input(event)


func _on_right_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_RIGHT
	_on_border_input(event)


func _on_top_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_TOP
	_on_border_input(event)


func _on_top_left_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_TOP_LEFT
	_on_border_input(event)


func _on_top_right_gui_input(event: InputEvent) -> void:
	_last_hovered = DisplayServer.WINDOW_EDGE_TOP_RIGHT
	_on_border_input(event)
#endregion
