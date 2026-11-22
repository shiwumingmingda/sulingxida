/// obj_map_controller - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (tip_timer > 0) tip_timer--;

if (mouse_check_button_pressed(mb_left))
{
    // ---- 下方三个按钮：任何时候都能点；再次点击已打开的面板就关闭 ----
    if (my >= bot_y1 && my <= bot_y2 && mx >= bag_x1 && mx <= bag_x2)
    {
        if (panel == "bag") close_panel(); else open_panel("bag");
    }
    else if (my >= bot_y1 && my <= bot_y2 && mx >= relic_x1 && mx <= relic_x2)
    {
        if (panel == "relic") close_panel(); else open_panel("relic");
    }
    else if (my >= bot_y1 && my <= bot_y2 && mx >= roster_x1 && mx <= roster_x2)
    {
        if (panel == "roster") close_panel(); else open_panel("roster");
    }
    // ---- 面板打开时，地图点击不处理 ----
    else if (panel != "")
    {
    }
    // ---- 地图：第一次点击选中并显示描述，再次点击同一个节点才进入 ----
    else if (my > bar_h && my < room_height - bar_h && mx < side_x1 - 10)
    {
        var hit = -1;

        for (var i = 0; i < map.w * map.h; i++)
        {
            if (point_distance(mx, my, cell_x(i), cell_y(i)) <= node_size * 0.6)
            {
                hit = i;
            }
        }

        if (hit == -1)
        {
            // 点空白处：取消选择
            sel = -1;
        }
        else if (hit != sel)
        {
            // 第一次点击：选中，右侧显示描述
            sel = hit;
        }
        else
        {
            // 再次点击同一个节点：进入
            if (hit == map.pos)
            {
                tip_text = "你就在这个位置";
                tip_timer = 90;
            }
            else if (reach[hit] == -1)
            {
                tip_text = "无法到达该节点";
                tip_timer = 90;
            }
            else if (reach[hit] > map.ap)
            {
                tip_text = "行动力不足";
                tip_timer = 90;
            }
            else
            {
                sel = -1;
                move_to(hit);
            }
        }
    }
}