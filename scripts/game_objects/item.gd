extends Object
class_name Item

var item_type: String
var durability_left: int
# TODO: EffectData for item effects, status effects, attack effects?

func _init(_item_type: String = "", _durability_left: int = 0, _status: Array[Status] = [], _items: Array[Item] = []):
	item_type = _item_type
	durability_left = _durability_left

func to_dict() -> Dictionary[StringName, Variant]:
	return {
		"item_type": item_type,
		"durability_left": durability_left
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Item:
	var cell = Cell.new()
	cell.item_type = data.get("item_type", "")
	cell.durability_left = data.get("durability_left", 0)
	
	return cell
