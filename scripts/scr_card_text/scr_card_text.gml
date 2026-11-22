/// scr_card_text
/// 在卡牌上绘制文字：自动跟随卡牌的位置、旋转、缩放

// 把"卡牌上的比例位置"换算成屏幕坐标
// _fx、_fy：0~1，(0,0) 是卡牌图片左上角，(1,1) 是右下角
function card_local_to_world(_spr, _x, _y, _xs, _ys, _a, _fx, _fy)
{
    var lx = (_fx * sprite_get_width(_spr)  - sprite_get_xoffset(_spr)) * _xs;
    var ly = (_fy * sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * _ys;

    var d   = point_distance(0, 0, lx, ly);
    var dir = point_direction(0, 0, lx, ly) + _a;

    return [_x + lengthdir_x(d, dir), _y + lengthdir_y(d, dir)];
}

// 带阴影的文字
function card_text_shadow(_x, _y, _str, _ts, _a, _col)
{
    draw_set_color(c_black);
    draw_text_transformed(_x + _ts, _y + _ts, _str, _ts, _ts, _a);

    draw_set_color(_col);
    draw_text_transformed(_x, _y, _str, _ts, _ts, _a);
}

// 带阴影、可自动换行的文字
function card_text_shadow_ext(_x, _y, _str, _wrap, _ts, _a, _col)
{
    draw_set_color(c_black);
    draw_text_ext_transformed(_x + _ts, _y + _ts, _str, -1, _wrap, _ts, _ts, _a);

    draw_set_color(_col);
    draw_text_ext_transformed(_x, _y, _str, -1, _wrap, _ts, _ts, _a);
}

// 读取卡牌"当前"的费用和伤害（优先用牌自己的变量，没有就查表）
function card_current_cost(_inst)
{
    if (variable_instance_exists(_inst, "cost")) return _inst.cost;
    return card_get_cost(_inst.card_id);
}


// 每行最多 _n 个字符自动换行；文字里的 "\n" 会按手动换行处理
function card_wrap_text(_str, _n)
{
    var result = "";
    var len = string_length(_str);
    var line_len = 0;

    for (var i = 1; i <= len; i++)
    {
        var ch = string_char_at(_str, i);

        // 手动换行：行内计数清零
        if (ch == "\n")
        {
            result += ch;
            line_len = 0;
            continue;
        }

        // 这一行满了：先换行再写下一个字
        if (line_len >= _n)
        {
            result += "\n";
            line_len = 0;
        }

        result += ch;
        line_len++;
    }

    return result;
}

// 每张牌的描述文字（数值全部实时读取，效果被修改后文字会同步变化）
// 返回 "" 表示这张牌暂时不画字
function card_get_description(_inst)
{
    // 新卡先读取新描述表；没有新描述时再使用旧卡牌描述
    var new_desc = card_get_description_new(_inst);

    if (new_desc != "")
    {
        return new_desc;
    }

    switch (_inst.card_id)
    {
        // 1号牌：对前场敌人造成 6 点法术伤害，对其他敌人造成 3 点法术伤害
        case 1:
            return "造成" + string(card_current_damage(_inst)) + "点法术伤害，"
                 + "对其他敌人造成" + string(card_current_others(_inst)) + "点法术伤害";

        // 2号牌：造成 2 点法术和物理伤害
        case 2:
        {
            var magic_dmg    = card_current_damage_of(_inst, DamageType.MAGIC);
            var physical_dmg = card_current_damage_of(_inst, DamageType.PHYSICAL);

            // 两种伤害数值一样就合并成一句，不一样就分开写
            if (magic_dmg == physical_dmg)
            {
                return "造成" + string(magic_dmg) + "点法术和物理伤害";
            }

            return "造成" + string(magic_dmg) + "点法术伤害和"
                 + string(physical_dmg) + "点物理伤害";
        }
		// 3号牌：造成 6 点法术伤害，令敌人获得 1 层寒冷
		case 3:
			return "造成" + string(card_current_damage(_inst)) + "点法术伤害，"
         + "令敌人获得" + string(card_current_status(_inst, StatusType.CHILL)) + "层寒冷";
// 4号牌：获得通用护甲和物理护甲
		case 4:
			return "获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲和"
         + string(card_current_armor_of(_inst, ArmorType.PHYSICAL)) + "点物理护甲";
        // 5号牌：抽 3 张牌，下回合额外获得 1 费
        case 5:
            return "抽" + string(card_current_draw(_inst)) + "张牌，"
                 + "下回合额外获得" + string(card_current_next_energy(_inst)) + "费";
// 7号牌：获得元素共鸣
		case 7:
			return "回合开始时，将一张随机的初始牌洗入你的抽牌堆";
        // 11号牌：造成 8 点法术伤害
        case 101:
            return "造成" + string(card_current_damage(_inst)) + "点法术伤害";

        // 12号牌：造成物理伤害，获得星光
        case 102:
            return "造成" + string(card_current_damage(_inst)) + "点物理伤害，"
                 + "获得" + string(card_current_xingguang(_inst)) + "点星光";

        // 15号牌：获得星光
        case 105:
            return "获得" + string(card_current_xingguang(_inst)) + "点星光";
			
			
		case 201:
			 return "剑招，造成" + string(card_current_damage(_inst)) + "点物理伤害";

		case 202:
			return "剑招，追猎，造成" + string(card_current_damage(_inst)) + "点物理伤害";

		case 203:
			return "剑招，获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲";

		case 204:
			return "剑招，造成" + string(card_current_damage(_inst)) + "点物理伤害，令敌方下回合失去等量的力量";

		case 205:
			return "造成" + string(card_current_damage(_inst)) + "点魔法伤害，将一张【猩红】置入手牌";

		case 206:
			return "造成" + string(card_current_damage(_inst)) + "点物理伤害，弃置你手中所有的【猩红】";

		case 207:
			return "消耗，失去" + string(card_current_value(_inst, EffectType.LOSE_HP)) + "点生命，"
         + "获得" + string(card_current_status(_inst, StatusType.BLOOD)) + "层血色";

		case 208:
			return "消耗，获得" + string(card_current_status(_inst, StatusType.STRENGTH)) + "点力量和"
         + string(card_current_status(_inst, StatusType.DEXTERITY)) + "点敏捷，"
         + "回复" + string(card_current_value(_inst, EffectType.HEAL)) + "点生命";

		case 210:
			return "每回合开始时，将一张0费的【练心】置入你的手牌";
		case 301:
			return "令一名友方角色造成" + string(card_current_damage(_inst)) + "点物理伤害";

		case 302:
			return "令一名友方角色获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲";

		case 303:
			return "保留，令一名友方角色进入前场";

		case 304:
			return "抽" + string(card_current_value(_inst, EffectType.DRAW)) + "张牌";
		case 401:
			return "无法被打出。出牌阶段结束时，扣除3点生命，获得1层血色";
	
		case 209:
			return "在本局对战剩余时间内，将【血.极】加入你的剑招中";
			// 44号牌
		// 41号牌
		case 241:
			return "造成" + string(card_current_damage(_inst)) + "点物理伤害，"
         + "获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲，"
         + "令目标下回合力量和魔力-" + string(card_current_status(_inst, StatusType.STRENGTH_DOWN));

// 42号牌
		case 242:
			return "对所有敌人造成" + string(card_current_damage(_inst)) + "点物理伤害";

// 43号牌
		case 243:
			return "指定一名敌人，造成" + string(card_current_damage(_inst)) + "点物理伤害";
	
		case 244:
			return "造成" + string(card_current_damage(_inst)) + "点物理伤害，"
			+ "重复" + string(card_current_times(_inst)) + "次";

// 45号牌
		case 245:
			return "获得" + string(card_current_status(_inst, StatusType.STRENGTH)) + "点力量和敏捷，"
				+ "本场战斗剩余时间内，你的剑招伤害+" + string(card_current_status(_inst, StatusType.SWORD_FORM));

// 46号牌
		case 246:
			return "造成" + string(card_current_damage(_inst)) + "点物理伤害";
			
			case 402:
    return "无法被使用。结束阶段，若此牌在你手牌，前排的角色受到2点伤害";
		}
		

    return "";
}
// 绘制某张牌的文字（费用 + 描述）
// _inst：卡牌实例；_spr：正在画的图片（手牌用自己的图，预览用高清图）
// _x、_y、_xs、_ys、_a：这张图的绘制位置、缩放和角度
// 卡面上显示的费用：基础费用，加上敌人"本回合第一张牌费用+N"的加成
// （只在战斗房间里有加成；地图里的阵容界面不受影响）
function card_display_cost(_inst)
{
    var c = card_current_cost(_inst);

    if (instance_exists(obj_hand_controller))
    {
        c += obj_hand_controller.first_cost_up;
    }

    return c;
}
function card_draw_text(_inst, _spr, _x, _y, _xs, _ys, _a)
{
    // 没有写描述的牌不画字
    var desc = card_get_description(_inst);
    if (desc == "") return;

    // ===== 可调参数 =====
    var text_k = 0.4;       // 文字整体大小：1 = 字体原始大小(24)，越小字越小
    var wrap_chars = 10;    // 每行最多多少个字符，超过就换行

    // 这张图实际显示的宽度 ÷ 原始卡牌图的宽度，再乘文字大小系数
    var base_w = sprite_get_width(_inst.sprite_index);
    var ts = (sprite_get_width(_spr) * _xs) / base_w * text_k;

    draw_set_font(global.chinese_font);
    draw_set_halign(fa_center);

    // 费用：右上角
    draw_set_valign(fa_middle);
    var p_cost = card_local_to_world(_spr, _x, _y, _xs, _ys, _a, 0.87, 0.09);
    var shown_cost = card_display_cost(_inst);
var base_cost = card_current_cost(_inst);
    var cost_col = (shown_cost > base_cost) ? make_color_rgb(255, 90, 90) : c_white;

card_text_shadow(p_cost[0], p_cost[1],
    string(shown_cost), ts * 1.4, _a, cost_col);

    // 描述：从卡牌 62% 的高度开始往下，每 10 个字符换行
    draw_set_valign(fa_top);
    var p_desc = card_local_to_world(_spr, _x, _y, _xs, _ys, _a, 0.50, 0.62);
    card_text_shadow(p_desc[0], p_desc[1],
        card_wrap_text(desc, wrap_chars), ts, _a, c_white);

    // 恢复默认绘制设置
    draw_set_font(global.chinese_font);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// 合成过的牌：在卡牌边缘画一圈彩色边框
// 合成 1 次 = 淡金色，2 次及以上 = 金色
function card_draw_merge_frame(_inst, _spr, _x, _y, _xs, _ys, _a)
{
    var lvl = card_merge_level(_inst);
    if (lvl <= 0) return;

    var col = (lvl == 1) ? make_color_rgb(235, 220, 160) : make_color_rgb(255, 200, 40);

    // 边框粗细随卡牌显示大小缩放
    var k = (sprite_get_width(_spr) * _xs) / sprite_get_width(_inst.sprite_index);
    var lw = max(2, 4 * k);

    // 四个角（向内缩一点，让边框压在卡牌边缘上）
    var m = 0.012;
    var p1 = card_local_to_world(_spr, _x, _y, _xs, _ys, _a, m,     m);
    var p2 = card_local_to_world(_spr, _x, _y, _xs, _ys, _a, 1 - m, m);
    var p3 = card_local_to_world(_spr, _x, _y, _xs, _ys, _a, 1 - m, 1 - m);
    var p4 = card_local_to_world(_spr, _x, _y, _xs, _ys, _a, m,     1 - m);

    draw_set_color(col);

    draw_line_width(p1[0], p1[1], p2[0], p2[1], lw);
    draw_line_width(p2[0], p2[1], p3[0], p3[1], lw);
    draw_line_width(p3[0], p3[1], p4[0], p4[1], lw);
    draw_line_width(p4[0], p4[1], p1[0], p1[1], lw);

    // 四个角补上圆点，避免线条拐角处有缺口
    draw_circle(p1[0], p1[1], lw * 0.5, false);
    draw_circle(p2[0], p2[1], lw * 0.5, false);
    draw_circle(p3[0], p3[1], lw * 0.5, false);
    draw_circle(p4[0], p4[1], lw * 0.5, false);

    draw_set_color(c_white);
}