// 角色最大生命值与当前生命值
max_hp = 35;
hp = 35;

// 血条尺寸
hp_bar_width = 150;
hp_bar_height = 16;

// 血条位于角色下方的距离
hp_bar_offset_y = 50;
in_front = false;
// 护甲
armor_general = 0;    // 通用护甲（白）
armor_physical = 0;   // 物理护甲（黄）
armor_magic = 0;      // 魔法护甲（紫）

armor_bar_height = 8; // 护甲条高度
is_dead = false;
// dead_spr = spr_xxx_dead;   // ← 失去作战能力的形态，每个角色对象各写一个，没写就变成深灰色