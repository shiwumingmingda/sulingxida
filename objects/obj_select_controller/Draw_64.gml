/// obj_select_controller - Draw GUI

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

draw_set_font(global.chinese_font);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// 背景
draw_set_color(make_color_rgb(25, 30, 45));
draw_rectangle(0, 0, room_width, room_height, false);

// 标题
draw_set_color(c_white);
draw_text_transformed(
    room_width * 0.4, 50,
    "选择出战角色  " + string(array_length(global.party)) + "/" + string(max_party),
    1.5, 1.5, 0
);

// 四个角色
for (var i = 0; i < array_length(char_objs); i++)
{
    var spr = object_get_sprite(char_objs[i]);
    var r = get_char_rect(i);

    var chosen = is_chosen(i);
    var hovered = (abs(mx - r[0]) <= r[2] * 0.5 && abs(my - r[1]) <= r[3] * 0.5);

    // 悬停时略微放大
    var s = char_scale * ((hovered && !chosen) ? 1.05 : 1);

    // 按精灵原点换算，保证图片中心落在 (r[0], r[1])
    var dx = r[0] - (sprite_get_width(spr)  * 0.5 - sprite_get_xoffset(spr)) * s;
    var dy = r[1] - (sprite_get_height(spr) * 0.5 - sprite_get_yoffset(spr)) * s;

    // 已选的角色变暗
    draw_sprite_ext(spr, 0, dx, dy, s, s, 0,
        chosen ? c_gray : c_white, chosen ? 0.5 : 1);

    // 已选标记：显示是第几个选的（1 = 前场，2 = 后场上方，3 = 后场下方）
    if (chosen)
    {
        for (var k = 0; k < array_length(global.party); k++)
        {
            if (global.party[k] == char_objs[i])
            {
                draw_set_color(c_white);
                draw_text_transformed(r[0], r[1], string(k + 1), 3, 3, 0);
            }
        }
    }

    // 选中框
    if (i == selected)
    {
        draw_set_color(make_color_rgb(255, 220, 80));

        for (var o = 0; o < 3; o++)
        {
            draw_rectangle(
                r[0] - r[2] * 0.5 - 6 - o, r[1] - r[3] * 0.5 - 6 - o,
                r[0] + r[2] * 0.5 + 6 + o, r[1] + r[3] * 0.5 + 6 + o,
                true
            );
        }
    }
}

// 确定按钮（选中角色后才出现）
if (selected != -1)
{
    draw_set_color(make_color_rgb(60, 150, 80));
    draw_rectangle(confirm_x1, confirm_y1, confirm_x2, confirm_y2, false);

    draw_set_color(c_white);
    draw_rectangle(confirm_x1, confirm_y1, confirm_x2, confirm_y2, true);
    draw_text((confirm_x1 + confirm_x2) * 0.5, (confirm_y1 + confirm_y2) * 0.5, "确定");
}

// 开始游戏按钮（队伍为空时是灰色）
var can_start = (array_length(global.party) >= 1);

draw_set_color(can_start ? make_color_rgb(45, 105, 170) : make_color_rgb(70, 70, 70));
draw_rectangle(start_x1, start_y1, start_x2, start_y2, false);

draw_set_color(c_white);
draw_rectangle(start_x1, start_y1, start_x2, start_y2, true);
draw_text((start_x1 + start_x2) * 0.5, (start_y1 + start_y2) * 0.5, "开始游戏");

// 底部说明
draw_set_color(make_color_rgb(180, 190, 210));
draw_text(room_width * 0.5, room_height - 40,
    "最多选2人。出场顺序：第1个在前场，第2个在后场上方");

// 提示（最后 30 帧渐隐）
if (tip_timer > 0)
{
    draw_set_alpha(clamp(tip_timer / 30, 0, 1));
    draw_set_color(make_color_rgb(255, 110, 110));
    draw_text(room_width * 0.5, room_height * 0.8, tip_text);
    draw_set_alpha(1);
}

// 恢复默认设置
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);