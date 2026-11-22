/// obj_character_2 - Draw

// 先画角色本体和血条（父类的 Draw）
event_inherited();

if (is_dead) exit;

// 星光图标：血条右侧（位置与 obj_character_1 的血条一致）
var bar_x = x - hp_bar_width * 0.5;
var bar_y = y + hp_bar_offset_y + 60;

var star_x = bar_x + hp_bar_width + 24;
var star_y = bar_y + hp_bar_height * 0.5;

// 本回合已用过星光：图标变灰
var star_col = starlight_used ? c_gray : c_white;

draw_sprite_ext(spr_star, 0, star_x, star_y,
    star_scale, star_scale, 0, star_col, 1);

// 图标中间显示数字（黑色描边，保证看得清）
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_black);
draw_text(star_x + 1, star_y + 1, string(starlight));

draw_set_color(c_white);
draw_text(star_x, star_y, string(starlight));

// 恢复默认设置
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);