// Embedded static map: Aquia Creek (simplified). No JSON.
// Glyphs: . plain  ^ hill  ~ river  A mountain  : sand  # town  = road  v valley  * rock
// Mostly plain / hill / river for Phase 1 visibility; all 9 kinds appear at least once.
#pragma once

namespace cwl {
namespace data {

// 12 x 10 — small campaign-scale hex map (not historical accuracy).
inline constexpr const char* kAquiaCreekRows[] = {
    "............",  // 0
    "...^^^......",  // 1 hills
    "..~~.^^.....",  // 2 river + hills
    ".~~~........",  // 3 river
    "....#=......",  // 4 town + road
    "....==^.....",  // 5 road + hill
    "...vv.~~....",  // 6 valley + river
    "..****......",  // 7 rock
    ".A..::......",  // 8 mountain + sand
    "............",  // 9
};

inline constexpr int kAquiaCreekRowCount =
    static_cast<int>(sizeof(kAquiaCreekRows) / sizeof(kAquiaCreekRows[0]));

}  // namespace data
}  // namespace cwl
