@tool
extends EditorPlugin

const editor_window = preload("res://addons/card_editor/card_editor_window.tscn")
var editor_window_instance

func _enter_tree():
	editor_window_instance = editor_window.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(editor_window_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)

func _exit_tree():
	if editor_window_instance:
		editor_window_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if editor_window_instance:
		editor_window_instance.visible = visible

func _get_plugin_name():
	return "Card Editor"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("ClassList", "EditorIcons")
