@tool
extends Node
const uuid_util = preload("res://addons/uuid/uuid.gd")

var ACTIVE_CARD = null
var IDX_UUID_TABLE = {}
var UUID_CARD_TABLE = {}
var TYPES = {
	"entity": 0,
	"spell" : 1
}

func load_txt_file(fp: String):
	var file = FileAccess.open(fp, FileAccess.READ)
	if file == null:
		printerr("Error opening card list")
	var text = file.get_as_text()
	file.close()
	return text

func load_card_file_json(path):
	var card_path = %CardFilePathField.text
	var card_file = load_txt_file(card_path)
	var cards = JSON.parse_string(card_file)

	var i = 0
	IDX_UUID_TABLE = {}
	UUID_CARD_TABLE = cards
	ACTIVE_CARD = cards.values()[0]["uuid"]
	%CardSelectDropdown.clear()
	for card in cards.values():
		%CardSelectDropdown.add_item(card["name"], i)
		%CardSelectDropdown.set_item_metadata(i, card["uuid"])
		IDX_UUID_TABLE[i] = card["uuid"]
		i += 1
	handle_load_card(cards.values()[0])

func save_card_file():
	var json_str = JSON.stringify(UUID_CARD_TABLE)
	var file = FileAccess.open(%CardFilePathField.text, FileAccess.WRITE)
	file.store_string(json_str)
	file.close()	
	
func handle_load_card(data: Dictionary):
	%TypeDropdown.clear()
	for type in TYPES.keys():
		%TypeDropdown.add_item(type, TYPES[type])
	%CardNameLabel.text = data["name"]
	%NameField.text = data["name"]
	%UUIDField.text = data["uuid"]
	%TypeDropdown.select(TYPES[data["type"]])
	%DamageField.text = str(data["damage"])
	%ManaField.text = str(data["mana"])
	%TooltipField.text = data["tooltip"]
	if ResourceLoader.exists("res://Cards/images/" + ACTIVE_CARD + ".png"):
		%CardImage.texture = load("res://Cards/images/" + ACTIVE_CARD + ".png")
	else:
		%CardImage.texture = null

func _ready() -> void:
	load_card_file_json(%CardFilePathField.text)

func _on_load_button_pressed():
	load_card_file_json(%CardFilePathField.text)

func _on_generate_uuid_button_pressed():
	var new_id = uuid_util.v4()
	if %UUIDField.text != "":
		DisplayServer.clipboard_set(new_id)
	else:
		%UUIDField.text = new_id

func _on_save_button_pressed():
	UUID_CARD_TABLE[ACTIVE_CARD]["name"] = %NameField.text
	UUID_CARD_TABLE[ACTIVE_CARD]["uuid"] = %UUIDField.text
	UUID_CARD_TABLE[ACTIVE_CARD]["type"] = %TypeDropdown.get_item_text(%TypeDropdown.get_selected_id())
	UUID_CARD_TABLE[ACTIVE_CARD]["damage"] = %DamageField.text
	UUID_CARD_TABLE[ACTIVE_CARD]["mana"] = %ManaField.text
	UUID_CARD_TABLE[ACTIVE_CARD]["tooltip"] = %TooltipField.text
	save_card_file()

func load_card(index: int) -> void:
	ACTIVE_CARD = IDX_UUID_TABLE[index]
	handle_load_card(UUID_CARD_TABLE[ACTIVE_CARD])

func _on_new_card_button_pressed() -> void:
	%TypeDropdown.clear()
	for type in TYPES.keys():
		%TypeDropdown.add_item(type, TYPES[type])
	%CardNameLabel.text = ""
	%NameField.text = ""
	%UUIDField.text = ""
	%DamageField.text = ""
	%ManaField.text = ""
	%TooltipField.text = ""


func _on_image_button_pressed() -> void:
	var command = load_txt_file("res://addons/card_editor/image_editor.txt").replace("%FILE%", ProjectSettings.globalize_path("res://Cards/images/" + ACTIVE_CARD + ".svg"))
	OS.execute(command.split(" ")[0], command.split(" ").slice(1, len(command.split(" "))))

func _on_script_button_pressed() -> void:
	if not ResourceLoader.exists("res://Cards/scripts/" + ACTIVE_CARD + ".gd"):
		var new_script = GDScript.new()
		new_script.source_code = "# " + UUID_CARD_TABLE[ACTIVE_CARD]["name"] + "\n"
		ResourceSaver.save(new_script, "res://Cards/scripts/" + ACTIVE_CARD + ".gd")
	EditorInterface.edit_resource(load("res://Cards/scripts/" + ACTIVE_CARD + ".gd"))
func _on_copy_uuid_button_pressed() -> void:
	DisplayServer.clipboard_set(ACTIVE_CARD)
