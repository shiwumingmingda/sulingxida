/// obj_character_2 - Create
event_inherited();

max_hp = 50;   // 想要不同血量就改这里
hp = 50;



// 星光
starlight = 0;            // 当前星光
starlight_used = false;   // 本回合是否已经用过星光
starlight_unlimited = false;
scry_bonus = 0;
mingche_active = false;
attack_cards_used_battle = 0;
enemy_debuff_turns = 0;
enemy_damage_reduction = 3;
enemy_damage_taken_bonus = 4;
showmanship_active = false;
showmanship_hit = false;
next_attack_bonus = 0;
purple_star = false;
star_damage_bonus_active = false;
star_bond_active = false;
team_echo_active = false;
night_guard_active = false;
star_walk_active = false;
assist_star_used = false;
retreat_mark_target = noone;

// 星星图标
star_scale = 1;           // 图标缩放，按你的图片大小调