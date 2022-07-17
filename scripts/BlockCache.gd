class_name BlockCache

const Sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var _file:Sqlite

func _init(_path):
	_file = Sqlite.new()
	_file.verbosity_level = 0
	_file.path = _path

func get_tracks():
	_file.open_db()
	_file.query("SELECT * FROM ScheduledTrack")
	_file.close_db()
	return _file.query_result

func get_style_at_ts(ts:int):
	_file.open_db()
	_file.query("SELECT * FROM ScheduledUIItem WHERE StartTimeStamp == {x}".format({"x":ts}))
	_file.close_db()
	if len(_file.query_result) == 1: return _file.query_result[0]
	return null

func is_style_at_ts(ts:int):
	_file.open_db()
	_file.query("SELECT * FROM ScheduledUIItem WHERE StartTimeStamp == {x}".format({"x":ts}))
	_file.close_db()
	return len(_file.query_result) > 0
