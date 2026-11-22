/// obj_map_controller - Draw GUI

draw_set_font(global.chinese_font);

var n = map.w * map.h;

// 背景
draw_set_color(make_color_rgb(25, 30, 45));
draw_rectangle(0, 0, room_width, room_height, false);

// ---------- 线路 ----------
if (show_all_lines)
{
    draw_set_color(make_color_rgb(70, 78, 105));

    for (var i = 0; i < n; i++)
    {
        if (map_has_link(map, i, 1))
        {
            draw_line_width(cell_x(i), cell_y(i), cell_x(i + 1), cell_y(i + 1), 3);
        }

        if (map_has_link(map, i, 2))
        {
            draw_line_width(cell_x(i), cell_y(i), cell_x(i + map.w), cell_y(i + map.w), 3);
        }
    }
}

// 当前视野内的线（粗、亮）
draw_set_color(make_color_rgb(150, 160, 195));

for (var i = 0; i < n; i++)
{
    if (reach[i] == -1) continue;
    if (i != map.pos && map.type[i] != NodeType.EMPTY) continue;

    for (var d = 0; d < 4; d++)
    {
        if (!map_has_link(map, i, d)) continue;

        var j = map_neighbor(map, i, d);

        draw_line_width(cell_x(i), cell_y(i), cell_x(j), cell_y(j), 5);
    }
}

// ---------- 所有格子 ----------
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

for (var i = 0; i < n; i++)
{
    var px = cell_x(i);
    var py = cell_y(i);

    var can_reach = (reach[i] != -1);
    var affordable = can_reach && (reach[i] <= map.ap);
    var a = affordable ? 1 : (can_reach ? 0.4 : 0.7);

    draw_node_sprite(map_cell_sprite(map, i), px, py, node_size, a);

    // 到达这个格子要花的行动力
    if (can_reach && i != map.pos)
    {
        draw_set_color(c_white);
        draw_text_transformed(px, py + node_size * 0.5 + 12, string(reach[i]), 0.7, 0.7, 0);
    }
}

// 首领先锋
for (var k = 0; k < array_length(map.pursuers); k++)
{
    var pp = map.pursuers[k].pos;

    draw_set_color(make_color_rgb(230, 70, 60));
    draw_circle(cell_x(pp), cell_y(pp), node_size * 0.6, true);
    draw_node_sprite(spr_vanguard, cell_x(pp), cell_y(pp), node_size * 0.9, 1);
}

// 当前位置：黄色圆环
draw_set_color(make_color_rgb(255, 220, 80));

for (var o = 0; o < 3; o++)
{
    draw_circle(cell_x(map.pos), cell_y(map.pos), node_size * 0.6 + 4 + o, true);
}

// 选中的节点：白色圆环
if (sel != -1)
{
    draw_set_color(c_white);

    for (var o = 0; o < 2; o++)
    {
        draw_circle(cell_x(sel), cell_y(sel), node_size * 0.6 + 10 + o, true);
    }
}

// ---------- 右侧：行动力（大）----------
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(180, 190, 215));
draw_text(side_x2, bar_h + 14, "行动力");

draw_set_color(make_color_rgb(255, 220, 80));
draw_text_transformed(side_x2, bar_h + 40, string(map.ap), 2.8, 2.8, 0);

// ---------- 右侧：节点描述 ----------
var desc_y1 = bar_h + 130;
var desc_y2 = room_height - bar_h - 30;

draw_set_color(make_color_rgb(40, 48, 72));
draw_rectangle(side_x1, desc_y1, side_x2, desc_y2, false);
draw_set_color(make_color_rgb(110, 120, 155));
draw_rectangle(side_x1, desc_y1, side_x2, desc_y2, true);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// 文字换行宽度（不含缩放：文字画 0.8 倍，所以除以 0.8）
var wrap_px = (side_x2 - side_x1 - 32) / 0.8;

if (sel == -1)
{
    draw_set_color(make_color_rgb(150, 160, 190));
    draw_text_transformed(side_x1 + 16, desc_y1 + 16,
        wrap_text_pixels("点击一个节点查看描述，再次点击进入", wrap_px), 0.8, 0.8, 0);
}
else
{
    var t = map.type[sel];
    var rev = map.revealed[sel];
    var title = node_title(t, rev);
    var desc = node_description(t, rev);

    // 这个节点上有首领先锋
    if (map_pursuer_index_at(map, sel) != -1)
    {
        title = "首领先锋";
        desc = "每次移动2步，会追逐角色。触碰后进入战斗，先锋会在4回合之后逃跑并令你行动力-1。击败先锋可以获得1点行动力和必定带有补给品的普通战斗奖励。";
    }

    draw_set_color(c_white);
    draw_text_transformed(side_x1 + 16, desc_y1 + 14, title, 1.4, 1.4, 0);

    draw_set_color(make_color_rgb(200, 208, 228));
    draw_text_transformed(side_x1 + 16, desc_y1 + 60, wrap_text_pixels(desc, wrap_px), 0.8, 0.8, 0);

    // 花费和操作提示（在面板底部，分两行）
    var cost_text = "";

    if (sel == map.pos)
    {
        cost_text = "当前位置";
    }
    else if (reach[sel] == -1)
    {
        cost_text = "无法到达";
    }
    else
    {
        cost_text = "花费行动力：" + string(reach[sel]) + "\n再次点击进入";
    }

    draw_set_color(make_color_rgb(255, 220, 80));
    draw_text_transformed(side_x1 + 16, desc_y2 - 70, wrap_text_pixels(cost_text, wrap_px), 0.8, 0.8, 0);
}

// ---------- 上方横条 ----------
draw_set_color(make_color_rgb(16, 20, 32));
draw_rectangle(0, 0, room_width, bar_h, false);
draw_set_color(make_color_rgb(70, 78, 105));
draw_line_width(0, bar_h, room_width, bar_h, 2);

draw_set_valign(fa_middle);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(room_width * 0.5, bar_h * 0.5, "第" + string(global.map_floor) + "层", 1.3, 1.3, 0);

draw_set_halign(fa_right);
draw_set_color(make_color_rgb(255, 215, 90));
draw_text(room_width - 30, bar_h * 0.5, "金币：" + string(global.gold));

// ---------- 下方横条 ----------
draw_set_color(make_color_rgb(16, 20, 32));
draw_rectangle(0, room_height - bar_h, room_width, room_height, false);
draw_set_color(make_color_rgb(70, 78, 105));
draw_line_width(0, room_height - bar_h, room_width, room_height - bar_h, 2);

// 三个按钮：背包 / 奇物 / 阵容（打开着的会高亮）
var btn_x1 = [bag_x1, relic_x1, roster_x1];
var btn_x2 = [bag_x2, relic_x2, roster_x2];
var btn_name = ["背包", "奇物", "阵容"];
var btn_panel = ["bag", "relic", "roster"];

draw_set_halign(fa_center);

for (var bi = 0; bi < 3; bi++)
{
    draw_set_color(panel == btn_panel[bi] ? make_color_rgb(80, 100, 160) : make_color_rgb(40, 48, 72));
    draw_rectangle(btn_x1[bi], bot_y1, btn_x2[bi], bot_y2, false);

    draw_set_color(make_color_rgb(150, 160, 195));
    draw_rectangle(btn_x1[bi], bot_y1, btn_x2[bi], bot_y2, true);

    draw_set_color(c_white);
    draw_text((btn_x1[bi] + btn_x2[bi]) * 0.5, (bot_y1 + bot_y2) * 0.5, btn_name[bi]);
}

// ---------- 面板（盖在两条横条之间）----------
if (panel != "")
{
    var py1 = bar_h + 2;
    var py2 = room_height - bar_h - 2;

    draw_set_alpha(0.94);
    draw_set_color(make_color_rgb(20, 24, 38));
    draw_rectangle(0, py1, room_width, py2, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    // 背包：容量 = 当前角色数量 × 3 格
    if (panel == "bag")
    {
        var slot_n = array_length(global.party) * 3;

        draw_text_transformed(room_width * 0.5, py1 + 30, "背包（容量 " + string(slot_n) + " 格）", 1.4, 1.4, 0);

        var slot_size = 90;
        var slot_gap = 16;
        var slot_cols = min(slot_n, 6);
        var slot_rows = ceil(slot_n / max(slot_cols, 1));
        var slot_x0 = (room_width - (slot_cols * (slot_size + slot_gap) - slot_gap)) * 0.5;
        var slot_y0 = py1 + 120;

        for (var si = 0; si < slot_n; si++)
        {
            var sx = slot_x0 + (si mod slot_cols) * (slot_size + slot_gap);
            var sy = slot_y0 + (si div slot_cols) * (slot_size + slot_gap);

            draw_set_color(make_color_rgb(40, 48, 72));
            draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, false);
            draw_set_color(make_color_rgb(110, 120, 155));
            draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, true);
        }
    }

    // 奇物：暂时没有内容
    if (panel == "relic")
    {
        draw_text_transformed(room_width * 0.5, py1 + 30, "奇物", 1.4, 1.4, 0);

        draw_set_color(make_color_rgb(150, 160, 190));
        draw_text(room_width * 0.5, py1 + 120, "（暂时没有奇物）");
    }

    // 阵容：上面是角色头像和血量，下面是目前所有的卡牌
    if (panel == "roster")
    {
        var pc = array_length(global.party);
        var av_size = 110;
        var av_gap = 260;
        var av_x0 = room_width * 0.5 - (pc - 1) * av_gap * 0.5;
        var av_cy = py1 + 20 + av_size * 0.5;

        for (var ai = 0; ai < pc; ai++)
        {
            var ax = av_x0 + ai * av_gap;
            var cnum = character_get_num(global.party[ai]);
            var av_spr = character_avatar_sprite(cnum);
			if (av_spr == -1) av_spr = object_get_sprite(global.party[ai]);

            if (av_spr != -1)
            {
                draw_node_sprite(av_spr, ax, av_cy, av_size, 1);
            }

            draw_set_color(c_white);
            draw_text_transformed(ax, av_cy + av_size * 0.5 + 8,
                "HP " + string(global.party_hp[ai]) + "/" + string(global.party_max_hp[ai]), 0.9, 0.9, 0);
        }

        // 所有卡牌：选一个能放下全部卡牌的最大尺寸
        var card_n = array_length(roster_cards);

        if (card_n > 0)
        {
            var area_w = room_width - 80;
            var area_y = av_cy + av_size * 0.5 + 50;
            var area_h = py2 - 10 - area_y;

            var spr0 = roster_cards[0].sprite_index;
            var aspect = sprite_get_height(spr0) / sprite_get_width(spr0);

            var best_w = 0;
            var best_cols = 1;

            for (var cc = 1; cc <= card_n; cc++)
            {
                var rows_try = ceil(card_n / cc);
                var w_try = min(area_w / cc - 10, (area_h / rows_try - 10) / aspect);

                if (w_try > best_w)
                {
                    best_w = w_try;
                    best_cols = cc;
                }
            }

            var cw = best_w;
            var ch = cw * aspect;
            var grid_w = best_cols * (cw + 10) - 10;
            var grid_x0 = (room_width - grid_w) * 0.5;

            for (var ki = 0; ki < card_n; ki++)
            {
                var inst = roster_cards[ki];

                if (!instance_exists(inst)) continue;

                var kcx = grid_x0 + (ki mod best_cols) * (cw + 10) + cw * 0.5;
                var kcy = area_y + (ki div best_cols) * (ch + 10) + ch * 0.5;

                var kspr = inst.sprite_index;
                var ks = cw / sprite_get_width(kspr);
                var kdx = kcx - (sprite_get_width(kspr)  * 0.5 - sprite_get_xoffset(kspr)) * ks;
                var kdy = kcy - (sprite_get_height(kspr) * 0.5 - sprite_get_yoffset(kspr)) * ks;

                draw_sprite_ext(kspr, 0, kdx, kdy, ks, ks, 0, c_white, 1);
                card_draw_text(inst, kspr, kdx, kdy, ks, ks, 0);
            }
        }
    }
}

// 提示（最后 30 帧渐隐）
if (tip_timer > 0)
{
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(clamp(tip_timer / 30, 0, 1));
    draw_set_color(make_color_rgb(255, 110, 110));
    draw_text(room_width * 0.5 - 100, room_height - bar_h - 30, tip_text);
    draw_set_alpha(1);
}

// 恢复默认设置
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);