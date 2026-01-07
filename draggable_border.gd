@tool
extends VBoxContainer


## The term "border" is used to represent each location which the user can drag.
enum Border {
	NONE,
	BOTTOM,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	LEFT,
	RIGHT,
	TOP,
	TOP_LEFT,
	TOP_RIGHT,
}

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

# Used to know where the edge (bottom right) was when the dragging started.
# When the user drag the origin (top/left), we move the window and
# resize so it doesn't pass the edge initial position.
var _dragging_edge_start: Vector2i

# Used to know where the origin (top left) was when the dragging started.
# When the user drag the edge (bottom/right), we resize the window but
# we cannot let them move pass the edge.
var _dragging_origin_limit: Vector2i

var _is_dragging: bool = false

var _last_hovered: Border = Border.NONE


func _process(_delta: float) -> void:
	if _is_dragging:
		_on_dragged()


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


func _on_dragged() -> void:
	if get_window().mode != Window.MODE_WINDOWED:
		return
	
	var mouse_position: Vector2i = get_global_mouse_position() as Vector2i
	
	match _last_hovered:
		Border.TOP:
			get_window().position.y = min(
				get_window().position.y + mouse_position.y,
				_dragging_origin_limit.y
			)
			
			get_window().size.y = _dragging_edge_start.y - get_window().position.y
		Border.RIGHT:
			get_window().size.x = mouse_position.x
		Border.BOTTOM:
			get_window().size.y = mouse_position.y
		Border.LEFT:
			get_window().position.x = min(
				get_window().position.x + mouse_position.x,
				_dragging_origin_limit.x
			)
			
			get_window().size.x = _dragging_edge_start.x - get_window().position.x
		Border.TOP_RIGHT:
			get_window().position.y = min(
				get_window().position.y + mouse_position.y,
				_dragging_origin_limit.y
			) # Top
			
			get_window().size = Vector2i(
				mouse_position.x, # Right
				_dragging_edge_start.y - get_window().position.y, # Top
			)
		Border.TOP_LEFT:
			get_window().position = Vector2i(
				min(
					get_window().position.x + mouse_position.x,
					_dragging_origin_limit.x
				), # Left,
				min(
					get_window().position.y + mouse_position.y,
					_dragging_origin_limit.y
				), # Top
			)

			get_window().size = Vector2i(
				_dragging_edge_start.x - get_window().position.x, # Left
				_dragging_edge_start.y - get_window().position.y, # Top
			)
		Border.BOTTOM_RIGHT:
			get_window().size = Vector2i(
				mouse_position.x, # Right
				mouse_position.y, # Bottom
			)
		Border.BOTTOM_LEFT:
			get_window().position.x = min(
				get_window().position.x + mouse_position.x,
				_dragging_origin_limit.x
			) # Left
			
			get_window().size = Vector2i(
				_dragging_edge_start.x - get_window().position.x, # Left
				mouse_position.y, # Bottom
			)


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_is_dragging = true
		_dragging_edge_start = get_window().position + get_window().size
		_dragging_origin_limit = _dragging_edge_start - get_window().min_size
	elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_is_dragging = false


#region Borders signals
func _on_bottom_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.BOTTOM
	_on_border_input(event)


func _on_bottom_left_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.BOTTOM_LEFT
	_on_border_input(event)


func _on_bottom_right_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.BOTTOM_RIGHT
	_on_border_input(event)


func _on_left_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.LEFT
	_on_border_input(event)


func _on_right_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.RIGHT
	_on_border_input(event)


func _on_top_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.TOP
	_on_border_input(event)


func _on_top_left_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.TOP_LEFT
	_on_border_input(event)


func _on_top_right_gui_input(event: InputEvent) -> void:
	_last_hovered = Border.TOP_RIGHT
	_on_border_input(event)
#endregion
