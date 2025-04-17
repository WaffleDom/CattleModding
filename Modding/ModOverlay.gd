extends Node2D
var consoleFocused = false
var consoleOpen = false

func _ready():
	print("Loaded")
	
func toggleConsole():
	consoleOpen = not consoleOpen
	$Console.visible = consoleOpen
	$Console.text = ""
	if consoleOpen:
		focusConsole()

func focusConsole():
	consoleFocused = true
	$Console.grab_focus()

func unfocusConsole():
	consoleFocused = false
	$Console.release_focus()

var Commands = {
	"jump": func(params:PackedStringArray):
		if params.is_empty(): params = PackedStringArray(["false"])
		var enabled = params[0].to_lower() == "1"
		if enabled:
			Global.jumpingEnabled = true
		else:
			Global.jumpingEnabled = false
		return "Jumping was set to %s" % Global.jumpingEnabled,
		
	"god": func(_params):
		Global.godMode = not Global.godMode
		return "God mode was set to %s" % Global.godMode,
	"help" : func(_params):
		return "Commands: %s"%str(Commands.keys()),
	"fov": func(params):
		if params.is_empty(): params = PackedStringArray(["75"])
		if not get_viewport().get_camera_3d(): return
		var fov = int(params[0])
		if not fov:
			fov = 75
		get_viewport().get_camera_3d().fov += 20.0
		print(typeof(float(fov)) == Variant.Type.TYPE_FLOAT)
		print(get_viewport().get_camera_3d().fov, fov)
		return "Set fov to %s" % fov
}

func runConsoleCommand(cmdString:String):
	if cmdString == "":
		return "Ey bro u kinda inputted sum wrong"
	var split:PackedStringArray = cmdString.split(" ")
	var cmd = split[0]
	if not cmd in Commands.keys():
		return 'No command found "%s"' % cmd
	split.remove_at(0)
	return Commands[str(cmd)].call(split)

func _process(_dt):
	if Input.is_action_just_pressed("console"):
		if not consoleOpen:
			toggleConsole()
			return
		if consoleFocused and consoleOpen:
			toggleConsole()
		focusConsole()
	if Input.is_action_just_pressed("enter"):
		if consoleOpen:
			unfocusConsole()
			var info = runConsoleCommand($Console.text)
			$Console/Output.text = info
