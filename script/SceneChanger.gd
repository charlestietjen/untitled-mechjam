extends Node


func goto_scene(path):
	var loader = ResourceLoader.load_interactive(path)
	
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			get_tree().call_deferred("change_scene_to", resource)
			break
#		if err == OK:
#			var progress = float(loader.get_stage())/loader.get_stage_count()
#			print(progress)
