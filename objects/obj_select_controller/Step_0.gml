/// obj_select_controller - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (tip_timer > 0) tip_timer--;

if (mouse_check_button_pressed(mb_left))
{
    // 开始游戏（右上角）
    if (mx >= start_x1 && mx <= start_x2
    &&  my >= start_y1 && my <= start_y2)
    {
        if (array_length(global.party) >= 1)
        {
            // 记录这一局的牌库、金币和队伍血量，进入第 1 层地图
global.card_collection = build_card_pool(global.party);
global.map_floor = 1;
global.gold = 0;
global.map = undefined;     // 新的一局：重新生成地图
global.battle_count = 0;    // 前两次普通战斗是弱怪区
global.go_battle = false;
global.armor_bonus = 0;

global.party_hp = [];
global.party_max_hp = [];

for (var pj = 0; pj < array_length(global.party); pj++)
{
    var mhp = character_base_max_hp(character_get_num(global.party[pj]));

    array_push(global.party_hp, mhp);
    array_push(global.party_max_hp, mhp);
}

room_goto(rm_map);
        }
        else
        {
            tip_text = "请至少选择一个角色";
            tip_timer = 90;
        }
    }
    // 确定（只有选中角色时才有这个按钮）
    else if (selected != -1
    &&  mx >= confirm_x1 && mx <= confirm_x2
    &&  my >= confirm_y1 && my <= confirm_y2)
    {
        global.party[array_length(global.party)] = char_objs[selected];
        selected = -1;
    }
    // 点选角色
    else
    {
        var hit = -1;

        for (var i = 0; i < array_length(char_objs); i++)
        {
            var r = get_char_rect(i);

            if (abs(mx - r[0]) <= r[2] * 0.5
            &&  abs(my - r[1]) <= r[3] * 0.5)
            {
                hit = i;
            }
        }

        if (hit == -1)
        {
            // 点空白处：取消选择
            selected = -1;
        }
        else if (is_chosen(hit))
        {
            tip_text = "这个角色已经选过了";
            tip_timer = 90;
        }
        else if (array_length(global.party) >= max_party)
        {
            tip_text = "队伍已满";
            tip_timer = 90;
        }
        else
        {
            selected = hit;
        }
    }
}