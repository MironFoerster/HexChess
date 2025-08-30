extends Resource
class_name PlayerData

var nickname: String
var rank: int

func _init(_nickname: String, _rank: int = 0):
	nickname = _nickname
	rank = _rank
