extends RefCounted
class_name Database

var db  # SQLite instance
var cols: Array = ["username", "password", "rank"]

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
	var value_str: String
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		value_str = str(value)  # no quotes
	else:
		value_str = "'%s'" % str(value).replace("'", "''")  # escape quotes in strings

	var sql = "UPDATE %s SET %s=%s WHERE username='%s'" % [table, column, value_str, username]
	db.query(sql)

func _db_get(table: String, column: String, username: String) -> Variant:
	var res = db.select_rows(table, "username='%s'" % username, [column])
	if res.size() > 0:
		return res[0].get(column)
	return null

# ------------------------------
# User-specific functions
# ------------------------------

func add_user(username: String, password: String, rank: int = 0) -> void:
	var sql = "INSERT INTO users (username, password, rank) VALUES ('%s', '%s', %d)" % [username, password.sha256_text(), rank]
	db.query(sql)

func user_exists(username: String) -> bool:
	return db.select_rows("users", "username='%s'" % username, ["username"]).size() > 0

func validate_password(username: String, password: String) -> bool:
	return _db_get("users", "password", username) == password.sha256_text()

func set_user_rank(username: String, rank: int):
	_db_set("users", "rank", username, rank)
	
func get_user_rank(username: String) -> int:
	return int(_db_get("users", "rank", username) or 0)

func set_user_password(username: String, password: String):
	_db_set("users", "password", username, password.sha256_text())

func increment_user_rank(username: String, delta: int = 1):
	var current_rank = _db_get("users", "rank", username) or 0
	set_user_rank(username, current_rank + delta)

func delete_user(username: String):
	db.query("DELETE FROM users WHERE username='%s'" % [username])

func get_leaderboard(limit: int = 10) -> Array:
	var sql = "SELECT username, rank FROM users ORDER BY rank DESC LIMIT %d" % limit
	db.query(sql)
	return db.fetch_all()  # returns array of rows


## UTILS
func make_safe(string: String) -> String:
	return string.replace("'", "''")
