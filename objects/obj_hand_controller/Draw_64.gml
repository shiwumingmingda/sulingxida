draw_set_font(global.chinese_font);
/// obj_hand_controller - Draw GUI Event

// 按钮颜色
draw_set_color(make_color_rgb(45, 75, 110));
draw_rectangle(
    button_x1,
    button_y1,
    button_x2,
    button_y2,
    false
);

// 按钮边框
draw_set_color(make_color_rgb(130, 190, 240));
draw_rectangle(
    button_x1,
    button_y1,
    button_x2,
    button_y2,
    true
);

// 按钮文字
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(
    (button_x1 + button_x2) * 0.5,
    (button_y1 + button_y2) * 0.5,
    "DRAW CARD"
);

// 恢复文字对齐方式
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

/// obj_hand_controller - Draw GUI

// 左侧：抽牌按钮
draw_set_color(make_color_rgb(45, 105, 170));
draw_rectangle(
    button_x1, button_y1,
    button_x2, button_y2,
    false
);

draw_set_color(c_white);
draw_rectangle(
    button_x1, button_y1,
    button_x2, button_y2,
    true
);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(
    (button_x1 + button_x2) * 0.5,
    (button_y1 + button_y2) * 0.5,
    "DRAW CARD"
);

// 右侧：回合结束按钮
draw_set_color(make_color_rgb(170, 75, 55));
draw_rectangle(
    end_button_x1, end_button_y1,
    end_button_x2, end_button_y2,
    false
);

draw_set_color(c_white);
draw_rectangle(
    end_button_x1, end_button_y1,
    end_button_x2, end_button_y2,
    true
);

draw_text(
    (end_button_x1 + end_button_x2) * 0.5,
    (end_button_y1 + end_button_y2) * 0.5,
    "END TURN"
);

// 恢复默认文字对齐
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// 保留原来的收起手牌提示
if (hand_collapsed)
{
    draw_set_color(make_color_rgb(50, 75, 100));
    draw_rectangle(
        room_width - 155,
        room_height - 155,
        room_width - 20,
        room_height - 20,
        false
    );

    draw_set_color(c_white);
    draw_text(
        room_width - 145,
        room_height - 145,
        "CLICK TO OPEN"
    );
}
else
{
    draw_set_color(c_white);
    draw_text(
        room_width - 155,
        room_height - 145,
        "COLLAPSE HAND"
    );
}

draw_set_color(c_green);
// 显示抽牌堆和弃牌堆的数量
draw_set_color(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(
    25,
    room_height - 55,
    "抽牌堆: " + string(
        array_length(deck) - deck_index
    )
);

draw_text(
    25,
    room_height - 30,
    "弃牌堆: " + string(
        array_length(discard_pile)
    )
);
// ---------------------------------
// 费用显示
// ---------------------------------
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(make_color_rgb(40, 60, 110));
draw_circle(energy_x, energy_y, 42, false);

draw_set_color(make_color_rgb(120, 190, 255));
draw_circle(energy_x, energy_y, 42, true);

draw_set_color(c_white);
draw_text_transformed(
    energy_x, energy_y,
    string(energy) + "/" + string(max_energy),
    1.5, 1.5, 0
);
draw_text(energy_x, energy_y - 60, "费用");

// ---------------------------------
// "费用不足"提示（最后 30 帧渐隐）
// ---------------------------------
if (warning_timer > 0)
{
    draw_set_alpha(clamp(warning_timer / 30, 0, 1));

    draw_set_color(c_black);
    draw_text_transformed(
        room_width * 0.5 + 2, room_height * 0.55 + 2,
        warning_text, 2, 2, 0
    );

    draw_set_color(make_color_rgb(255, 70, 70));
    draw_text_transformed(
        room_width * 0.5, room_height * 0.55,
        warning_text, 2, 2, 0
    );

    draw_set_alpha(1);
}

// 恢复默认设置
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---------------------------------
// 悬停预览：在牌的上方显示清晰的正放大图
// ---------------------------------
if (hover_card != noone && instance_exists(hover_card))
{
    var hc = hover_card;

    // 取高清图；没有高清图就用牌自己的图
    var spr = card_get_preview_sprite(hc.card_id);
    if (spr == -1) spr = hc.sprite_index;

    var s  = preview_height / sprite_get_height(spr);
    var pw = sprite_get_width(spr) * s;
    var ph = preview_height;

    // 预览中心：在这张牌正上方，左右不超出屏幕
    var cx = clamp(hc.rest_x, pw * 0.5, room_width - pw * 0.5);
    var cy = max(hc.bbox_top - 15 - ph * 0.5, ph * 0.5 + 10);

    // 按精灵原点换算绘制位置
    var dx = cx - (sprite_get_width(spr)  * 0.5 - sprite_get_xoffset(spr)) * s;
    var dy = cy - (sprite_get_height(spr) * 0.5 - sprite_get_yoffset(spr)) * s;

    draw_sprite_ext(spr, 0, dx, dy, s, s, 0, c_white, 1);

    // 在大卡上画文字
    card_draw_text(hc, spr, dx, dy, s, s, 0);
	card_draw_merge_frame(hc, spr, dx, dy, s, s, 0);
}

// ---------------------------------
// 指向型卡牌：绘制箭头
// ---------------------------------
if (drag_card != noone && instance_exists(drag_card))
{
    if (card_needs_target(drag_card.card_id))
    {
        var amx = device_mouse_x_to_gui(0);
        var amy = device_mouse_y_to_gui(0);

        // 鼠标下面有没有友方角色
        // 指向我方的牌高亮我方角色，指向敌方的牌高亮敌人
		var tobj = (card_target_kind(drag_card.card_id) == TargetKind.ENEMY) ? obj_enemy_1 : obj_character_1;
		var tgt = instance_position(amx, amy, tobj);

        var arrow_col = c_white;

        if (tgt != noone)
        {
            arrow_col = make_color_rgb(90, 230, 120);

            // 给目标角色画一个绿色高亮框
            draw_set_color(arrow_col);
            for (var o = 0; o < 3; o++)
            {
                draw_rectangle(
                    tgt.bbox_left - o, tgt.bbox_top - o,
                    tgt.bbox_right + o, tgt.bbox_bottom + o,
                    true
                );
            }
        }

        // 箭头从这张牌在手牌里的位置出发，指向鼠标
        draw_target_arrow(
            drag_card.rest_x, drag_card.rest_y - 70,
            amx, amy,
            arrow_col
        );

        draw_set_color(c_white);
    }
}



// 测试按钮（临时）
draw_set_font(global.chinese_font);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(make_color_rgb(90, 60, 130));
draw_rectangle(test_x1, test_y1, test_x2, test_y2, false);

draw_set_color(c_white);
draw_rectangle(test_x1, test_y1, test_x2, test_y2, true);
draw_text((test_x1 + test_x2) * 0.5, (test_y1 + test_y2) * 0.5, "测试：发现");

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// 怪物意图的详细说明：鼠标放在意图图标上时显示
var tmx = device_mouse_x_to_gui(0);
var tmy = device_mouse_y_to_gui(0);

for (var ti = 0; ti < array_length(enemies); ti++)
{
    if (instance_exists(enemies[ti]))
    {
        draw_monster_tooltip(enemies[ti], tmx, tmy);
    }
}

// 本回合第一张牌的费用加成提示
if (first_cost_up > 0)
{
    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(255, 110, 110));
    draw_text(energy_x, energy_y - 90, "第一张牌费用+" + string(first_cost_up));
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
// ---------------------------------
// 发现界面：暗色遮罩 + 三张备选牌
// ---------------------------------
if (discover_active)
{
    // 暗色遮罩
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    // 标题
    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(room_width * 0.5, room_height * 0.14, "发现：选择一张牌", 1.6, 1.6, 0);

    // 三张备选牌（鼠标悬停时略微放大）
    var dmx = device_mouse_x_to_gui(0);
    var dmy = device_mouse_y_to_gui(0);

    for (var di = 0; di < array_length(discover_options); di++)
    {
        var dopt = discover_options[di];

        if (!instance_exists(dopt)) continue;

        var dk = position_meeting(dmx, dmy, dopt) ? 1.08 : 1;
        var dxs = dopt.image_xscale * dk;
        var dys = dopt.image_yscale * dk;

        draw_sprite_ext(dopt.sprite_index, 0, dopt.x, dopt.y, dxs, dys, 0, c_white, 1);
        card_draw_text(dopt, dopt.sprite_index, dopt.x, dopt.y, dxs, dys, 0);
    }

    // 恢复默认设置
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
// ---------------------------------
// 通用手牌选择：暗色遮罩 + 可选手牌 + 确认按钮
// ---------------------------------
if (selection_active)
{
    draw_set_alpha(0.72);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);

    var select_title = "请选择手牌";
    switch (selection_action.kind)
    {
        case "fireball_aoe": select_title = "选择一张【火球】消耗"; break;
        case "wind_shield": select_title = "选择任意张【风刃】消耗"; break;
        case "wind_feather": select_title = "选择一张【风刃】消耗"; break;
        case "convert_rockshield": select_title = "选择一张手牌，将其变为【岩盾】"; break;
        case "compress": select_title = "选择一张初始牌消耗"; break;
    }
    draw_text_transformed(room_width * 0.5, room_height * 0.14, select_title, 1.5, 1.5, 0);

    for (var qi = 0; qi < array_length(hand); qi++)
    {
        var qcard = hand[qi];
        if (!instance_exists(qcard) || !selection_can_select(qcard)) continue;

        var selected = selection_has(qcard);
        var qy = qcard.y;
        var qalpha = selected ? 1 : 0.82;

        draw_set_alpha(qalpha);
        draw_sprite_ext(qcard.sprite_index, qcard.image_index,
            qcard.x, qy, qcard.image_xscale, qcard.image_yscale,
            qcard.image_angle, c_white, 1);
        card_draw_text(qcard, qcard.sprite_index,
            qcard.x, qy, qcard.image_xscale, qcard.image_yscale, qcard.image_angle);
        card_draw_merge_frame(qcard, qcard.sprite_index,
            qcard.x, qy, qcard.image_xscale, qcard.image_yscale, qcard.image_angle);

        if (selected)
        {
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(255, 220, 90));
            draw_rectangle(qcard.bbox_left, qcard.bbox_top,
                qcard.bbox_right, qcard.bbox_bottom, true);
            draw_set_color(c_white);
        }
    }

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(65, 125, 85));
    draw_rectangle(end_button_x1, end_button_y1, end_button_x2, end_button_y2, false);
    draw_set_color(c_white);
    draw_rectangle(end_button_x1, end_button_y1, end_button_x2, end_button_y2, true);
    draw_text((end_button_x1 + end_button_x2) * 0.5,
        (end_button_y1 + end_button_y2) * 0.5, "确定 (" +
        string(array_length(selection_cards)) + "/" +
        ((selection_max >= 999) ? "任意" : string(selection_max)) + ")");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
if (turn_state == "won" || turn_state == "lost")
{
    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);

    draw_text_transformed(room_width * 0.5, room_height * 0.3,
        (turn_state == "won") ? "战斗胜利" : "战斗失败", 3, 3, 0);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ---------------------------------
// 战斗奖励页面：金币 + 三选一卡牌 + 跳过
// ---------------------------------
if (turn_state == "reward")
{
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(c_white);
    draw_text_transformed(room_width * 0.5, room_height * 0.10, "战斗胜利", 2, 2, 0);

    draw_set_color(make_color_rgb(255, 215, 90));
    draw_text_transformed(room_width * 0.5, room_height * 0.20, "获得金币 +" + string(reward_gold), 1.4, 1.4, 0);

    draw_set_color(c_white);
    draw_text(room_width * 0.5, room_height * 0.27, "选择一张卡牌加入牌组，或者跳过");

    var rmx = device_mouse_x_to_gui(0);
    var rmy = device_mouse_y_to_gui(0);

    for (var wi = 0; wi < array_length(reward_options); wi++)
    {
        var wopt = reward_options[wi];

        if (!instance_exists(wopt)) continue;

        var wk = position_meeting(rmx, rmy, wopt) ? 1.08 : 1;
        var wxs = wopt.image_xscale * wk;
        var wys = wopt.image_yscale * wk;

        draw_sprite_ext(wopt.sprite_index, 0, wopt.x, wopt.y, wxs, wys, 0, c_white, 1);
        card_draw_text(wopt, wopt.sprite_index, wopt.x, wopt.y, wxs, wys, 0);
    }

    // 跳过按钮
    draw_set_color(make_color_rgb(80, 80, 100));
    draw_rectangle(skip_x1, skip_y1, skip_x2, skip_y2, false);
    draw_set_color(c_white);
    draw_rectangle(skip_x1, skip_y1, skip_x2, skip_y2, true);
    draw_text((skip_x1 + skip_x2) * 0.5, (skip_y1 + skip_y2) * 0.5, "跳过");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}