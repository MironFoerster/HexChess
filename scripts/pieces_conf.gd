extends Object

var PIECES = {
	"swordsman": {
		"model_path": "res://models/pieces/warrior_model.tscn",
		"base_scale": Vector3(0.01,0.01,0.01),
		"base_transform": Vector3(0,0,0),
		"animations": {
			"idle": "mixamo_com"
		},
		"abilities": {
			"attack": {
				"damage": 1
			}
		},
		"patterns": {
			"attack": {
				"direction": CubeCoordinates.new(0, -1, 1),
				"pattern": [
					CubeCoordinates.new(0, -1, 1),
					CubeCoordinates.new(1, -2, 1),
					CubeCoordinates.new(-1, -1, 2),
					CubeCoordinates.new(0, -2, 2),
				]
			},
			"move": {
				"distance": 2,
			}
		}
	},
	"goblin": {
		"model_path": "res://models/pieces/goblin_model.tscn",
		"base_scale": Vector3(1,1,1),
		"base_transform": Vector3(0,0,0),
		"animations": {
			"idle": "Idle1"
		},
		"abilities": {
			"attack": {
				"damage": 1
			}
		},
		"patterns": {
			"attack": {
				"direction": CubeCoordinates.new(0, -1, 1),
				"pattern": [
					CubeCoordinates.new(0, -1, 1),
					CubeCoordinates.new(1, -2, 1),
					CubeCoordinates.new(-1, -1, 2),
					CubeCoordinates.new(0, -2, 2),
				]
			},
			"move": {
				"distance": 2,
			}
		}
	}
}
