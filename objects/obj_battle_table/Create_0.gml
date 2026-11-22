
// =====================================
// 战场角色：进入房间时生成
// =====================================

// 我方后场初始位置
player_back_x = room_width * 0.5;
player_back_y = room_height * 0.72;

// 我方前场位置
player_front_x = room_width * 0.5;
player_front_y = room_height * 0.56;

// 创建一个我方角色

// 记录角色所在区域
player_character.battle_position = "back";

// 记录角色阵营
player_character.is_player = true;

// 拖牌状态
dragging_card = noone;
dragging_active = false;
