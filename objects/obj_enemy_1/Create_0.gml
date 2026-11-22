// 敌人最大生命值与当前生命值
max_hp = 20;
hp = 20;

// 血条尺寸
hp_bar_width = 150;
hp_bar_height = 16;
hp_bar_offset_y = 50;
// 攻击伤害与攻击信号
attack_damage = 5;
attack_now = false;
attack_damage = 5;
attack_type = DamageType.PHYSICAL;   // 敌人1、3：物理
attack_now = false;

armor_general = 0;
armor_physical = 0;
armor_magic = 0;
ink_pending = false;
has_acted = false;
monster_id = -1;
cycle = [];
cycle_i = 0;