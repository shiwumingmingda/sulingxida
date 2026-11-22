/// obj_damage_text - Draw

// 最后 20 帧逐渐变透明
var a = clamp(life / 20, 0, 1);

draw_set_alpha(a);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// 黑色阴影
draw_set_color(c_black);
draw_text_transformed(x + 2, y + 2, text, 2, 2, 0);

// 红色文字
// Draw 里，原来是：draw_set_color(make_color_rgb(255, 70, 70));
// 改成：
draw_set_color(col);
draw_text_transformed(x, y, text, 2, 2, 0);

// 恢复默认设置
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);