extends Node

const abilities_dir: String = "res://data/abilities/"
const items_dir: String = "res://data/items/"
const patterns_dir: String = "res://data/patterns/"
const statuses_dir: String = "res://data/statuses/"
const terrains_dir: String = "res://data/terrains/"
const units_dir: String = "res://data/units/"


var abilities: Dictionary[Types.AbilityType, Resource] = {
	Types.AbilityType.MOVE_ALONG_AXIS: preload(abilities_dir + "move_along_axis.tres"),
}
var items: Dictionary[Types.ItemType, Resource] = {
	Types.ItemType.CHEST_PLATE: preload(items_dir + "chest_plate.tres"),
	Types.ItemType.SWORD: preload(items_dir + "sword.tres"),
}
var patterns: Dictionary[Types.PatternType, Resource] = {
	Types.PatternType.INFINITE_STAR: preload(patterns_dir + "infinite_star.tres"),
}
var statuses: Dictionary[Types.StatusType, Resource] = {
	Types.StatusType.POISON: preload(statuses_dir + "poison.tres"),
}
var terrains: Dictionary[Types.TerrainType, Resource] = {
	Types.TerrainType.FOREST: preload(terrains_dir + "forest.tres"),
}
var units: Dictionary[Types.UnitType, Resource] = {
	Types.UnitType.WARRIOR: preload(units_dir + "warrior.tres"),
}
