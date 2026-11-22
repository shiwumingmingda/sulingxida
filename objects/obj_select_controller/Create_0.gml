/// obj_select_controller - Create

display_set_gui_size(room_width, room_height);

// 每次进入选人界面时重新初始化随机数种子，避免每次新开局生成相同地图。
randomize();
max_party = 2;   // 最多选 2 个角色
// 中文字体只加载一次（别处已经加载过就跳过）
if (!variable_global_exists("chinese_font"))
{
    global.chinese_font = font_add("QingNiaoHuaGuangJianMeiHei-2.ttf", 24, false, false, 32, 65535);
}

// 四个可选角色（编号 1~4）
char_objs = [obj_character_1, obj_character_2, obj_character_3, obj_character_4];

// 队伍：保存在全局变量里，战斗房间读取。每次进入选人界面都会重置
global.party = [];
// 重新选人：清掉上一局记录的牌库，进入战斗时会按新队伍重新记录
global.card_collection = undefined;
max_party = 3;

// 当前点中、等待"确定"的角色下标（-1 = 没有）
selected = -1;

// 显示位置（屏幕比例）和角色图缩放，按你的图大小调
char_scale = 1;
char_slot_x = [0.12, 0.30, 0.48, 0.66];
char_slot_y = 0.45;

// 右边：确定按钮
confirm_x1 = room_width * 0.80;
confirm_x2 = room_width * 0.95;
confirm_y1 = room_height * 0.45 - 35;
confirm_y2 = room_height * 0.45 + 35;

// 右上角：开始游戏按钮
start_x1 = room_width - 210;
start_x2 = room_width - 25;
start_y1 = 25;
start_y2 = 85;

// 提示文字
tip_text = "";
tip_timer = 0;

// 这个角色是否已经在队伍里
is_chosen = function(_i)
{
    for (var k = 0; k < array_length(global.party); k++)
    {
        if (global.party[k] == char_objs[_i]) return true;
    }

    return false;
};

// 角色 _i 在屏幕上的 [中心x, 中心y, 宽, 高]
get_char_rect = function(_i)
{
    var spr = object_get_sprite(char_objs[_i]);

    return [
        room_width * char_slot_x[_i],
        room_height * char_slot_y,
        sprite_get_width(spr) * char_scale,
        sprite_get_height(spr) * char_scale
    ];
};