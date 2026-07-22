// Embedded static map: Aquia Creek (simplified). No JSON.
// Glyphs: . plain  ^ hill  ~ river  A mountain  : sand  # town  = road  v valley  * rock
// Expanded grid for smaller honeycomb cells (~30% smaller hex → more tiles).
#pragma once

namespace cwl {
namespace data {

// 20 x 16 — denser honeycomb fill for 960x640 @ hex_size≈20
inline constexpr const char* kAquiaCreekRows[] = {
    "....................",  // 0
    "......^^^^..........",  // 1
    ".....^^^^^^.........",  // 2
    "....~~.^^^^.........",  // 3
    "...~~~~.^^..........",  // 4
    "..~~~~~~............",  // 5 river band
    ".~~~~...............",  // 6
    "......##==..........",  // 7 town + road
    "......#===^.........",  // 8
    ".......===^^........",  // 9
    "....vvv..~~.........",  // 10 valley
    "...vvvv.~~~.........",  // 11
    "....****............",  // 12 rock field
    "...******...........",  // 13
    "..A...::::..........",  // 14 mountain + sand
    "....................",  // 15
};

inline constexpr int kAquiaCreekRowCount =
    static_cast<int>(sizeof(kAquiaCreekRows) / sizeof(kAquiaCreekRows[0]));

}  // namespace data
}  // namespace cwl
