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
    spr = card_get_rarity_sprite(hc, spr);

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
        if (card_requires_other_friend(drag_card.card_id)
        && tgt == obj_hand_controller.char_2)
            tgt = noone;

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
        var dspr = card_get_rarity_sprite(dopt, dopt.sprite_index);

        draw_sprite_ext(dspr, 0, dopt.x, dopt.y, dxs, dys, 0, c_white, 1);
        card_draw_text(dopt, dspr, dopt.x, dopt.y, dxs, dys, 0);
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
        var hovered = (qcard == selection_hover_card);
        var qy = qcard.y - (hovered ? 22 : 0);
        var qscale = hovered ? 1.12 : 1;
        var qxs = qcard.image_xscale * qscale;
        var qys = qcard.image_yscale * qscale;
        var qalpha = selected ? 1 : 0.82;
        var qspr = card_get_rarity_sprite(qcard, qcard.sprite_index);

        draw_set_alpha(qalpha);
        draw_sprite_ext(qspr, qcard.image_index,
            qcard.x, qy, qxs, qys, qcard.image_angle, c_white, 1);
        card_draw_text(qcard, qspr,
            qcard.x, qy, qxs, qys, qcard.image_angle);
        card_draw_merge_frame(qcard, qspr,
            qcard.x, qy, qxs, qys, qcard.image_angle);

        if (selected || hovered)
        {
            draw_set_alpha(1);
            var old_y = qcard.y;
            qcard.y = qy;
            draw_rotated_card_outline(qcard, qscale,
                selected ? make_color_rgb(255, 220, 90) : c_white);
            qcard.y = old_y;
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
        var wspr = card_get_rarity_sprite(wopt, wopt.sprite_index);

        draw_sprite_ext(wspr, 0, wopt.x, wopt.y, wxs, wys, 0, c_white, 1);
        card_draw_text(wopt, wspr, wopt.x, wopt.y, wxs, wys, 0);
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


// ---------------------------------
// 尘：占卜界面
// ---------------------------------
if (scry_active)
{
    draw_set_alpha(0.94);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(32, 42, 65));
    draw_rectangle(room_width * 0.06, room_height * 0.12,
        room_width * 0.94, room_height * 0.53, false);
    draw_set_color(make_color_rgb(65, 45, 55));
    draw_rectangle(room_width * 0.06, room_height * 0.56,
        room_width * 0.94, room_height * 0.82, false);

    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(room_width * 0.5, room_height * 0.075, "占卜", 1.8, 1.8, 0);
    draw_text(room_width * 0.5, room_height * 0.16, "牌堆顶  ·  从左往右依次抽取");
    draw_text(room_width * 0.5, room_height * 0.59, "牌堆底");

    // 牌堆顶区域
    for (var i = 0; i < array_length(scry_top); i++)
    {
        var card = scry_top[i];
        if (!instance_exists(card) || card == scry_drag_card) continue;
        var card_scale = (card == scry_hover_card) ? scry_scale * 1.18 : scry_scale;
        var top_spr = card_get_rarity_sprite(card, card.sprite_index);
        draw_sprite_ext(top_spr, card.image_index, card.x, card.y,
            card_scale, card_scale, card.image_angle, c_white, 1);
        card_draw_text(card, top_spr, card.x, card.y, card_scale, card_scale, card.image_angle);
        card_draw_merge_frame(card, top_spr, card.x, card.y,
            card_scale, card_scale, card.image_angle);
    }

    // 牌堆底区域
    for (var i = 0; i < array_length(scry_bottom); i++)
    {
        var card = scry_bottom[i];
        if (!instance_exists(card) || card == scry_drag_card) continue;
        var card_scale = (card == scry_hover_card) ? scry_scale * 1.18 : scry_scale;
        var bottom_spr = card_get_rarity_sprite(card, card.sprite_index);
        draw_sprite_ext(bottom_spr, card.image_index, card.x, card.y,
            card_scale, card_scale, card.image_angle, c_white, 1);
        card_draw_text(card, bottom_spr, card.x, card.y, card_scale, card_scale, card.image_angle);
        card_draw_merge_frame(card, bottom_spr, card.x, card.y,
            card_scale, card_scale, card.image_angle);
    }

    // 正在拖动的牌绘制在最上层。
    if (instance_exists(scry_drag_card))
    {
        var card = scry_drag_card;
        var drag_spr = card_get_rarity_sprite(card, card.sprite_index);
        draw_sprite_ext(drag_spr, card.image_index, card.x, card.y,
            scry_scale, scry_scale, card.image_angle, c_white, 1);
        card_draw_text(card, drag_spr, card.x, card.y, scry_scale, scry_scale, card.image_angle);
        card_draw_merge_frame(card, drag_spr, card.x, card.y,
            scry_scale, scry_scale, card.image_angle);
    }

    // 悬停时在屏幕另一侧显示清晰的大卡预览。
    if (instance_exists(scry_hover_card) && !instance_exists(scry_drag_card))
    {
        var preview_card = scry_hover_card;
        var preview_spr = card_get_preview_sprite(preview_card.card_id);
        if (preview_spr == -1) preview_spr = preview_card.sprite_index;
        preview_spr = card_get_rarity_sprite(preview_card, preview_spr);

        var preview_h = room_height * 0.42;
        var preview_s = preview_h / sprite_get_height(preview_spr);
        var preview_w = sprite_get_width(preview_spr) * preview_s;
        var preview_cx = (preview_card.x < room_width * 0.5)
            ? room_width * 0.78 : room_width * 0.22;
        preview_cx = clamp(preview_cx, preview_w * 0.5 + 12,
            room_width - preview_w * 0.5 - 12);
        var preview_cy = room_height * 0.50;

        draw_set_alpha(0.90);
        draw_set_color(c_black);
        draw_rectangle(preview_cx - preview_w * 0.5 - 10,
            preview_cy - preview_h * 0.5 - 10,
            preview_cx + preview_w * 0.5 + 10,
            preview_cy + preview_h * 0.5 + 10, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(170, 185, 220));
        draw_rectangle(preview_cx - preview_w * 0.5 - 10,
            preview_cy - preview_h * 0.5 - 10,
            preview_cx + preview_w * 0.5 + 10,
            preview_cy + preview_h * 0.5 + 10, true);

        var preview_x = preview_cx
            - (sprite_get_width(preview_spr) * 0.5 - sprite_get_xoffset(preview_spr)) * preview_s;
        var preview_y = preview_cy
            - (sprite_get_height(preview_spr) * 0.5 - sprite_get_yoffset(preview_spr)) * preview_s;
        draw_sprite_ext(preview_spr, 0, preview_x, preview_y,
            preview_s, preview_s, 0, c_white, 1);
        card_draw_text(preview_card, preview_spr, preview_x, preview_y,
            preview_s, preview_s, 0);
        card_draw_merge_frame(preview_card, preview_spr, preview_x, preview_y,
            preview_s, preview_s, 0);
    }

    // 确认按钮
    draw_set_color(make_color_rgb(45, 105, 145));
    draw_rectangle(scry_confirm_x1, scry_confirm_y1, scry_confirm_x2, scry_confirm_y2, false);
    draw_set_color(c_white);
    draw_rectangle(scry_confirm_x1, scry_confirm_y1, scry_confirm_x2, scry_confirm_y2, true);
    draw_text((scry_confirm_x1 + scry_confirm_x2) * 0.5,
        (scry_confirm_y1 + scry_confirm_y2) * 0.5, "确认");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}


// ---------------------------------
// 拾愿：从弃牌堆随机展示五张并选择至多两张
// ---------------------------------
if (discard_choice_active)
{
    draw_set_alpha(0.94);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(room_width * 0.5, room_height * 0.16, "拾愿", 1.8, 1.8, 0);
    draw_text(room_width * 0.5, room_height * 0.25, "选择至多两张置入手牌");

    for (var i = 0; i < array_length(discard_choice_options); i++)
    {
        var opt = discard_choice_options[i];
        if (!instance_exists(opt.card)) continue;
        var card = opt.card;
        var hovered = (card == discard_choice_hover_card);
        var draw_scale = hovered ? 1.08 : 1;
        var draw_y = card.y - (hovered ? 24 : 0);
        var xs = card.image_xscale * draw_scale;
        var ys = card.image_yscale * draw_scale;
        var discard_spr = card_get_rarity_sprite(card, card.sprite_index);
        draw_sprite_ext(discard_spr, card.image_index, card.x, draw_y,
            xs, ys, card.image_angle, c_white, 1);
        card_draw_text(card, discard_spr, card.x, draw_y,
            xs, ys, card.image_angle);
        if (opt.selected || hovered)
        {
            var old_y = card.y;
            card.y = draw_y;
            draw_rotated_card_outline(card, draw_scale,
                opt.selected ? make_color_rgb(255, 220, 100) : c_white);
            card.y = old_y;
        }
        if (opt.selected)
        {
            var h = sprite_get_height(card.sprite_index) * abs(ys) * 0.5;
            draw_text(card.x, draw_y - h - 24, "已选择");
        }
    }

    draw_set_color(make_color_rgb(45, 105, 145));
    draw_rectangle(discard_choice_x1, discard_choice_y1, discard_choice_x2, discard_choice_y2, false);
    draw_set_color(c_white);
    draw_rectangle(discard_choice_x1, discard_choice_y1, discard_choice_x2, discard_choice_y2, true);
    draw_text((discard_choice_x1 + discard_choice_x2) * 0.5,
        (discard_choice_y1 + discard_choice_y2) * 0.5, "确认");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
