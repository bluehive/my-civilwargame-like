extends RefCounted
class_name GameMap
## Terrain map. Port of src/game/map.hpp + aquia_creek.hpp

enum Terrain {
	PLAIN, HILL, MOUNTAIN, SAND, TOWN, ROAD, RIVER, VALLEY, ROCK
}

var width: int = 0
var height: int = 0
var _cells: Array[int] = []

# ~30% fewer cells than 20x16 (320→224 = 16x14)
const AQUIA_ROWS: PackedStringArray = [
	"................",
	"....^^^^........",
	"...^^^^^^.......",
	"..~~.^^^^.......",
	".~~~~.^^........",
	"~~~~~~..........",
	"~~~~............",
	"....##==........",
	"....#===^.......",
	".....===^^......",
	"..vvv..~~.......",
	".vvvv.~~~.......",
	"...****..A......",
	".A..::::........",
]

static func terrain_from_char(c: String) -> int:
	match c:
		".":
			return Terrain.PLAIN
		"^":
			return Terrain.HILL
		"A":
			return Terrain.MOUNTAIN
		":":
			return Terrain.SAND
		"#":
			return Terrain.TOWN
		"=":
			return Terrain.ROAD
		"~":
			return Terrain.RIVER
		"v":
			return Terrain.VALLEY
		"*":
			return Terrain.ROCK
		_:
			return Terrain.PLAIN

static func terrain_glyph(t: int) -> String:
	match t:
		Terrain.PLAIN:
			return "."
		Terrain.HILL:
			return "^"
		Terrain.MOUNTAIN:
			return "A"
		Terrain.SAND:
			return ":"
		Terrain.TOWN:
			return "#"
		Terrain.ROAD:
			return "="
		Terrain.RIVER:
			return "~"
		Terrain.VALLEY:
			return "v"
		Terrain.ROCK:
			return "*"
		_:
			return "?"

static func terrain_name_ja(t: int) -> String:
	match t:
		Terrain.PLAIN:
			return "平地"
		Terrain.HILL:
			return "丘"
		Terrain.MOUNTAIN:
			return "山"
		Terrain.SAND:
			return "砂地"
		Terrain.TOWN:
			return "街"
		Terrain.ROAD:
			return "道路"
		Terrain.RIVER:
			return "川"
		Terrain.VALLEY:
			return "谷"
		Terrain.ROCK:
			return "岩地"
		_:
			return "?"

static func terrain_move_cost(t: int) -> int:
	match t:
		Terrain.PLAIN, Terrain.ROAD, Terrain.TOWN:
			return 1
		Terrain.HILL, Terrain.SAND, Terrain.VALLEY, Terrain.ROCK:
			return 2
		Terrain.RIVER, Terrain.MOUNTAIN:
			return -1
		_:
			return -1

static func terrain_color(t: int) -> Color:
	match t:
		Terrain.PLAIN:
			return Color8(90, 130, 70)
		Terrain.HILL:
			return Color8(110, 120, 60)
		Terrain.MOUNTAIN:
			return Color8(120, 120, 125)
		Terrain.SAND:
			return Color8(190, 175, 110)
		Terrain.TOWN:
			return Color8(150, 90, 70)
		Terrain.ROAD:
			return Color8(150, 140, 100)
		Terrain.RIVER:
			return Color8(50, 100, 170)
		Terrain.VALLEY:
			return Color8(50, 90, 55)
		Terrain.ROCK:
			return Color8(100, 95, 90)
		_:
			return Color8(80, 80, 80)

static func from_rows(rows: PackedStringArray) -> GameMap:
	var m := GameMap.new()
	m.height = rows.size()
	m.width = rows[0].length() if rows.size() > 0 else 0
	m._cells.clear()
	for row in rows:
		for i in row.length():
			m._cells.append(terrain_from_char(row.substr(i, 1)))
	return m


static func make_aquia_creek() -> GameMap:
	return from_rows(AQUIA_ROWS)


static func make_for_level(level: int) -> GameMap:
	return from_rows(CampaignLevel.cleaned_rows(level))

func in_bounds(h: Hex) -> bool:
	return h.q >= 0 and h.r >= 0 and h.q < width and h.r < height

func at(h: Hex) -> int:
	if not in_bounds(h):
		return Terrain.PLAIN
	return _cells[h.r * width + h.q]
