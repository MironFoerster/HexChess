extends RefCounted
class_name Database

var db  # SQLite instance

func _init():
	db = SQLite.new()
	db.path = "./server_data.db"
	db.open_db()

	# Users table: username as primary key, password hash, rank
	db.query("""
	CREATE TABLE IF NOT EXISTS users (
		username TEXT PRIMARY KEY,
		password TEXT NOT NULL,
		rank INTEGER DEFAULT 0
	)
	""")

# ------------------------------
# Generic getters/setters
# ------------------------------

func _db_set(table: String, column: String, username: String, value) -> void:
	db.query("UPDATE %s SET %s=? WHERE username=?" % [table, column], value, username)

func _db_get(table: String, column: String, username: String) -> Variant:
	var res = db.select_rows(table, "username='%s'" % username)
	if res.size() > 0:
		return res[0].get(column)
	return null

# ------------------------------
# User-specific functions
# ------------------------------

func add_user(username: String, password: String, rank: int = 0) -> void:
	db.query("INSERT INTO users (username, password, rank) VALUES (?, ?, ?)", username, password.sha256_text(), rank)

func user_exists(username: String) -> bool:
	return db.select_rows("users", "username='%s'" % username).size() > 0

func validate_password(username: String, password: String) -> bool:
	return _db_get("users", "password", username) == password.sha256_text()

func set_user_rank(username: String, rank: int):
	_db_set("users", "rank", username, rank)
	
func get_user_rank(username: String) -> int:
	return _db_get("users", "rank", username)

func set_user_password(username: String, password: String):
	_db_set("users", "password", username, password.sha256_text())

func increment_user_rank(username: String, delta: int = 1):
	var current_rank = _db_get("users", "rank", username) or 0
	set_user_rank(username, current_rank + delta)

func delete_user(username: String):
	db.query("DELETE FROM users WHERE username=?", username)

func get_leaderboard(limit: int = 10) -> Array:
	var rows = db.select_rows("users", "", "rank DESC", limit)
	return rows
