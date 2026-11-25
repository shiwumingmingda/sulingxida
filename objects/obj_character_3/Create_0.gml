event_inherited();

// 心羽基础生命值
max_hp = 45;
hp = 45;

// 天赋：每获得6层血色，消耗6层，失去2点体力并发现一张特殊剑招。
talent_spr = spr_blood;
talent_count = 0;
talent_need = 6;

// 战斗内专属机制
hp_lost_this_turn = false;
hp_lost_last_turn = false;
ancient_battlefield_active = false;
blood_beast_active = false;
red_tide_active = false;
blood_boil_active = false;
no_attack_this_turn = false;
next_strength_bonus = 0;
sword_song_charges = 0;
sword_shadow_active = false;
sword_shadow_used = false;
unload_active = false;
unload_used = false;
scarlet_retain_active = false;
history_active = false;
history_used = false;
endless_blood_war_active = false;
pending_sword_form = 0;
temp_sword_form = 0;
temp_sword_form_active = false;
