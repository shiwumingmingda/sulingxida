/// obj_enemy_1 - Draw

draw_self();

draw_set_font(global.chinese_font);

var bar_x = x - hp_bar_width * 0.5;
var bar_y = y + hp_bar_offset_y;

// 血条背景
draw_set_color(make_color_rgb(55, 55, 55));
draw_rectangle(bar_x, bar_y, bar_x + hp_bar_width, bar_y + hp_bar_height, false);

// 红色血条
var hp_ratio = clamp(hp / max_hp, 0, 1);

if (hp_ratio > 0)
{
    draw_set_color(make_color_rgb(220, 45, 45));
    draw_rectangle(bar_x, bar_y, bar_x + hp_bar_width * hp_ratio, bar_y + hp_bar_height, false);
}

// 白色边框
draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + hp_bar_width, bar_y + hp_bar_height, true);

// 血条中间的数字
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, bar_y + hp_bar_height * 0.5, string(hp) + "/" + string(max_hp));

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// 护甲条（有护甲才显示），状态图标放在它下面（初始自带的墨化、窃尸也在这里）
var status_y = bar_y + hp_bar_height + 4;

if (draw_unit_armor_bar(id, bar_x, status_y, hp_bar_width, hp_bar_height))
{
    status_y += hp_bar_height + 4;
}

draw_status_icons(id, bar_x, status_y);

// 头顶：下一个行动的意图（图标 + 数字）
draw_monster_intent(id);