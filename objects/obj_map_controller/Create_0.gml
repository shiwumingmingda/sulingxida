/// obj_map_controller - Create

display_set_gui_size(room_width, room_height);

// 中文字体只加载一次（别处已经加载过就跳过）
if (!variable_global_exists("chinese_font"))
{
    global.chinese_font = font_add("QingNiaoHuaGuangJianMeiHei-2.ttf", 24, false, false, 32, 65535);
}

// 没经过选人界面、直接运行地图房间时的默认值，方便测试
if (!variable_global_exists("party"))
{
    global.party = [obj_character_1, obj_character_2];
}

if (!variable_global_exists("card_collection") || is_undefined(global.card_collection))
{
    global.card_collection = build_card_pool(global.party);
}

if (!variable_global_exists("party_hp"))
{
    global.party_hp = [];
    global.party_max_hp = [];

    for (var pj = 0; pj < array_length(global.party); pj++)
    {
        var mhp = character_base_max_hp(character_get_num(global.party[pj]));

        array_push(global.party_hp, mhp);
        array_push(global.party_max_hp, mhp);
    }
}

if (!variable_global_exists("map_floor")) global.map_floor = 1;
if (!variable_global_exists("gold")) global.gold = 0;
if (!variable_global_exists("armor_bonus")) global.armor_bonus = 0;

// 行动力耗尽进入首领战时，首领会狂暴（之后做首领战时读取这个标记）
global.boss_enraged = false;
if (!variable_global_exists("battle_count")) global.battle_count = 0;
if (!variable_global_exists("go_battle")) global.go_battle = false;

// 三层的尺寸（宽、高）和行动力
var floor_sizes = [[5, 6], [5, 6], [5, 6]];
var floor_ap = [9, 11, 14];
var fi = clamp(global.map_floor, 1, 3) - 1;
// 地图保存在全局变量里：进战斗再回来时不重新生成
if (!variable_global_exists("map") || is_undefined(global.map))
{
    global.map = map_generate(floor_sizes[fi][0], floor_sizes[fi][1], floor_ap[fi], 0.85, 0.15, global.map_floor);
}

map = global.map;

// 进入地图时视野内的节点先揭露
reach = map_reveal_reach(map);

// ---------- 屏幕布局 ----------
bar_h = 56;   // 上、下横条的高度

// 地图区域：左边 70%，在两条横条之间
area_x1 = 50;
area_x2 = room_width * 0.70;
area_y1 = bar_h + 50;
area_y2 = room_height - bar_h - 50;

spacing = min((area_x2 - area_x1) / max(map.w - 1, 1), (area_y2 - area_y1) / max(map.h - 1, 1));
origin_x = (area_x1 + area_x2) * 0.5 - (map.w - 1) * spacing * 0.5;
origin_y = (area_y1 + area_y2) * 0.5 - (map.h - 1) * spacing * 0.5;
node_size = min(64, spacing * 0.75);

// 右侧：行动力和节点描述
side_x1 = room_width * 0.74;
side_x2 = room_width - 30;

// 下方横条里的三个按钮
bot_y1 = room_height - bar_h + 8;
bot_y2 = room_height - 8;
bag_x1 = 20;                bag_x2 = 150;
relic_x1 = 165;             relic_x2 = 295;
roster_x1 = room_width - 150; roster_x2 = room_width - 20;

// ---------- 状态 ----------
show_all_lines = true;   // false = 只显示当前视野内的线
sel = -1;                // 当前选中（正在看描述）的节点
panel = "";              // 打开的面板："bag" / "relic" / "roster" / ""
roster_cards = [];       // 阵容面板里显示用的卡牌实例

tip_text = "";
tip_timer = 0;

// 格子 _i 的屏幕坐标
cell_x = function(_i)
{
    return origin_x + (_i mod map.w) * spacing;
};

cell_y = function(_i)
{
    return origin_y + (_i div map.w) * spacing;
};

// 关闭面板（同时销毁阵容里临时生成的卡牌实例）
close_panel = function()
{
    for (var i = 0; i < array_length(roster_cards); i++)
    {
        if (instance_exists(roster_cards[i]))
        {
            with (roster_cards[i])
            {
                instance_destroy();
            }
        }
    }

    roster_cards = [];
    panel = "";
};

// 打开面板（已经打开别的面板会先关掉）
open_panel = function(_name)
{
    close_panel();
    panel = _name;

    // 阵容：为所有牌生成不可见的卡牌实例，用来画卡面和文字
    if (_name == "roster")
    {
        for (var i = 0; i < array_length(global.card_collection); i++)
        {
            var c = card_spawn_from_entry(card_make_entry(global.card_collection[i]), -1000, -1000);
            c.visible = false;
            roster_cards[array_length(roster_cards)] = c;
        }
    }
};

// 走向节点 _hit（已经确认能到达、行动力足够）
move_to = function(_hit)
{
    map.ap -= reach[_hit];
    map.pos = _hit;

    var floor_done = false;

    // 踩到先锋：触发先锋作战；否则触发节点本身
    var touch_k = map_pursuer_index_at(map, _hit);

    if (touch_k != -1)
    {
        map_vanguard_touch(map, touch_k, _hit);
    }
    else
    {
        floor_done = map_on_arrive(map, _hit);
    }

    // 到达后的新视野，里面的节点全部揭露
    reach = map_reveal_reach(map);

    // 先锋追击：每个先锋沿线路追 2 步，追上就触发先锋作战
    if (!floor_done)
    {
        var chased_k = map_move_pursuers(map, 2);

        if (chased_k != -1)
        {
            map_vanguard_touch(map, chased_k, map.pos);
            reach = map_reveal_reach(map);
        }
    }

    // 行动力耗尽：立即进入首领战（暂时直接进入下一层），首领狂暴
    if (!floor_done && map.ap <= 0)
    {
        global.boss_enraged = true;
        floor_done = true;
    }

    if (floor_done)
    {
        map_next_floor();
    }
	// 触发了战斗节点：进入战斗房间
if (!floor_done && global.go_battle)
{
    global.go_battle = false;
    room_goto(rm_battle);
}
};