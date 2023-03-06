extends Control

func _ready():
	$VBoxContainer/Search/SearchText.text = OS.get_executable_path().get_base_dir()

func _on_search_pressed():
	%FileList.search(%SearchText.text)

func _on_filter_text_text_changed():
	%FileList.filter(%FilterText.text)
