extends Control

var _games := {}
var _game_dict := {}
var app_path : String = ""

func _ready():
	for data_path in ["PSV", "PSM", "PSX"]:
		var ps_data := FileAccess.open("res://%s_GAMES.tsv" % data_path, FileAccess.READ)
		if ps_data:
			while (!ps_data.eof_reached()):
				var line := ps_data.get_csv_line('\t')
				_game_dict[line[0]] = line[2]
		
	var psp_data := FileAccess.open("res://PSP_GAMES.tsv", FileAccess.READ)
	if psp_data:
		while (!psp_data.eof_reached()):
			var line := psp_data.get_csv_line('\t')
			_game_dict[line[0]] = line[3]

func search(path:String):
	app_path = path.replace('\\','/');
	if !app_path.ends_with('/'):
		app_path += "/"
	
	$Tree.clear()
	var root_item : TreeItem = $Tree.create_item();
	root_item.set_text(0, "Games");
	
	# Iterate through regular folders
	for subpath in ["addcont/", "app/", "patch/", "pspemu/PSP/GAME/", "repatch", "pspemu/PSP/SAVEDATA", "user/00/savedata/"]:
		var game_names := []
		
		var dir := DirAccess.open(app_path + subpath)
		if (dir == null):
			continue
		dir.include_hidden = true
		
		for game_id in dir.get_directories():
			if (_game_dict.has(game_id)):
				game_names.append(["%s (%s)" % [_game_dict[game_id], game_id], game_id])
			else:
				game_names.append([game_id, game_id])
		
		if game_names.size() > 0:
			var tree_branch : TreeItem = $Tree.create_item(root_item);
			tree_branch.collapsed = true
			tree_branch.set_text(0, subpath);
			
			game_names.sort()
			for game in game_names:
				var sub_item : TreeItem = tree_branch.create_child()
				sub_item.set_text(0, game[0])
				_games[sub_item] = subpath + game[1]
	
	# Check out the ISOs as well!
	var psp_isos : PackedStringArray = DirAccess.get_files_at(app_path + "pspemu/ISO/")
	if psp_isos.size() > 0:
		var tree_branch : TreeItem = $Tree.create_item(root_item)
		tree_branch.collapsed = true
		tree_branch.set_text(0, "pspemu/ISO/")
		
		psp_isos.sort()
		for game in psp_isos:
			var sub_item : TreeItem = tree_branch.create_child()
			sub_item.set_text(0, game)
			_games[sub_item] = "pspemu/ISO/"
	
func filter(text:String):
	if ($Tree.get_root() == null || $Tree.get_root().get_children_count() <= 0):
		return
		
	text = text.trim_prefix(' ').trim_suffix(' ').to_lower()
	for roots in $Tree.get_root().get_children():
		for game in roots.get_children():
			game.visible = text == '' || game.get_text(0).to_lower().contains(text)

func _on_tree_item_activated():
	if _games.has($Tree.get_selected()):
		#print(app_path + _games[$Tree.get_selected()])
		OS.shell_open(app_path + _games[$Tree.get_selected()])
