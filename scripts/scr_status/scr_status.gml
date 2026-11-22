/// scr_status
/// 状态（debuff）系统：寒冷、冻结……

enum StatusType
{
    CHILL,       // 寒冷
    FROZEN,      // 冻结
    RESONANCE,   // 元素共鸣：每个我方回合开始，把随机一张牌洗入抽牌堆
	STRENGTH_DOWN,   // 力量下降：下回合每次物理攻击伤害减少 N 点
	MAGIC_DOWN,      // 魔力下降：下回合每次魔法攻击伤害减少 N 点
	STRENGTH,     // 力量：你造成的物理伤害额外 +1/层
	DEXTERITY,    // 敏捷：你获得的护甲额外 +1/层
	SWORD_FORM,   // 剑招：带剑招标签的牌造成的伤害 +N
	BLOOD,       // 血色
	DILIGENCE,   // 精进：每回合开始，往手牌里放一张 0 费的练心（每层一张）
	MAGIC_POWER,    // 魔力：魔法伤害 +1/层
	INK,            // 墨化（怪物自带）
	CORPSE_THIEF,   // 窃尸（怪物自带）
	ARMOR_KEEP,   // 护甲保留：下个回合开始时护甲不清零（只保留一次）
	LAVA_WARD,    // 熔岩加护：直到下回合开始之前，损失护甲后将火球置入抽牌堆
	OVERCHARGE,   // 聚能：本角色下一张技能牌额外结算 1 次
	WIND_COURT,   // 风息庭：每回合开始，将一张风刃置入手牌
	READING,      // 阅读：每回合开始，发现一张本角色的牌
	TEMP_MAGIC,   // 临时魔力：本回合魔法伤害 +1/层
    COUNT        // 状态种类总数（放在最后，新状态加在它前面）
	
}

// 状态图标
function status_get_sprite(_type)
{
    switch (_type)
    {
        case StatusType.CHILL:  return spr_chill;
        case StatusType.FROZEN: return spr_frozen;
		case StatusType.RESONANCE: return spr_resonance;
		case StatusType.STRENGTH_DOWN: return spr_strength_down;
		case StatusType.MAGIC_DOWN:    return spr_magic_down;
		case StatusType.STRENGTH:   return spr_strength;
		case StatusType.DEXTERITY:  return spr_dexterity;
		case StatusType.SWORD_FORM: return spr_sword_form;
		case StatusType.BLOOD:     return spr_blood;
		case StatusType.DILIGENCE: return spr_diligence;
		case StatusType.MAGIC_POWER:  return spr_status_magic_power;
		case StatusType.INK:          return spr_status_ink;
		case StatusType.CORPSE_THIEF: return spr_status_corpse;
		case StatusType.ARMOR_KEEP: return spr_dexterity;
		case StatusType.LAVA_WARD:  return spr_strength;
		case StatusType.OVERCHARGE: return spr_resonance;
		case StatusType.WIND_COURT: return spr_sword_form;
		case StatusType.READING:    return spr_star;
		case StatusType.TEMP_MAGIC: return spr_status_magic_power;
    }

    return -1;
}

// 这个状态是否在图标上显示层数
function status_shows_count(_type)
{
    return (_type == StatusType.CHILL
         || _type == StatusType.RESONANCE
         || _type == StatusType.STRENGTH_DOWN
         || _type == StatusType.MAGIC_DOWN
         || _type == StatusType.STRENGTH
         || _type == StatusType.DEXTERITY
         || _type == StatusType.SWORD_FORM
		 || _type == StatusType.BLOOD
         || _type == StatusType.DILIGENCE
		 || _type == StatusType.MAGIC_POWER)
		 || _type == StatusType.TEMP_MAGIC
}

// 确保这个单位身上有状态数组
function status_init(_unit)
{
    if (!variable_instance_exists(_unit, "status_stacks"))
    {
        _unit.status_stacks = array_create(StatusType.COUNT, 0);
    }
}
// 敌人出手：每一次攻击都按类型扣除力量/魔力下降，伤害最低为 0
function enemy_perform_attack(_enemy)
{
    var target = obj_hand_controller.front_char;

    if (target == noone || !instance_exists(target)) return;

    // 敌人的攻击列表；没写 attack_hits 的敌人就是一次攻击
    var hits;

    if (variable_instance_exists(_enemy, "attack_hits"))
    {
        hits = _enemy.attack_hits;
    }
    else
    {
        hits = [ { damage: _enemy.attack_damage, dtype: _enemy.attack_type } ];
    }

    var strength_down = get_status(_enemy, StatusType.STRENGTH_DOWN);
    var magic_down    = get_status(_enemy, StatusType.MAGIC_DOWN);

    for (var i = 0; i < array_length(hits); i++)
    {
        var h = hits[i];

        // 物理攻击扣力量下降，魔法攻击扣魔力下降；连续攻击每一次都扣
        var reduce = (h.dtype == DamageType.PHYSICAL) ? strength_down : magic_down;

        deal_damage(target, max(h.damage - reduce, 0), h.dtype);
    }
}
// 读取层数
function get_status(_unit, _type)
{
    if (!instance_exists(_unit)) return 0;
    if (!variable_instance_exists(_unit, "status_stacks")) return 0;

    return _unit.status_stacks[_type];
}

// 增加层数
function add_status(_unit, _type, _stacks)
{
    if (!instance_exists(_unit)) return;

    status_init(_unit);
    _unit.status_stacks[_type] += _stacks;
}

// 移除某个状态的全部层数
function clear_status(_unit, _type)
{
    if (!instance_exists(_unit)) return;

    status_init(_unit);
    _unit.status_stacks[_type] = 0;
}

// 单位的回合开始结算，返回 true 表示这个单位本回合无法行动
function status_turn_start(_unit)
{
    var skip = false;

    // 1. 冻结触发：无法行动，跳过这个回合，冻结移除
    if (get_status(_unit, StatusType.FROZEN) > 0)
    {
        clear_status(_unit, StatusType.FROZEN);
        skip = true;
    }

    // 2. 寒冷：回合开始时不少于 3 层 → 获得冻结，消除所有寒冷
    //    （想让满 3 层的当回合就被跳过：把 1 和 2 两段的位置对调）
    if (get_status(_unit, StatusType.CHILL) >= 3)
    {
        clear_status(_unit, StatusType.CHILL);
        add_status(_unit, StatusType.FROZEN, 1);
    }

    return skip;
}

// 在 (_x, _y)（图标行的左上角）处，横向画出这个单位身上的所有状态图标
// 画一个小图标，_n >= 0 时在右下角显示数字（_n = -1 不显示数字）
function draw_icon_with_count(_spr, _x, _y, _size, _n)
{
    // 缩放到 _size，并按精灵原点换算，让图标左上角落在 (_x, _y)
    var s = _size / max(sprite_get_width(_spr), sprite_get_height(_spr));
    var dx = _x + sprite_get_xoffset(_spr) * s;
    var dy = _y + sprite_get_yoffset(_spr) * s;

    draw_sprite_ext(_spr, 0, dx, dy, s, s, 0, c_white, 1);

    if (_n >= 0)
    {
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);

        draw_set_color(c_black);
        draw_text_transformed(_x + _size + 1, _y + _size + 1, string(_n), 0.6, 0.6, 0);

        draw_set_color(c_white);
        draw_text_transformed(_x + _size, _y + _size, string(_n), 0.6, 0.6, 0);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

// 在 (_x, _y)（图标行的左上角）处，横向画出这个单位的天赋和身上的所有状态图标
function draw_status_icons(_unit, _x, _y)
{
    var icon_size = 24;   // 图标大小（像素）
    var gap = 6;          // 图标之间的间距
    var cx = _x;

    // 天赋：始终显示，数值是 0 也在
    if (variable_instance_exists(_unit, "talent_spr"))
    {
        draw_icon_with_count(_unit.talent_spr, cx, _y, icon_size, _unit.talent_count);
        cx += icon_size + gap;
    }

    // 状态
    if (variable_instance_exists(_unit, "status_stacks"))
    {
        for (var t = 0; t < StatusType.COUNT; t++)
        {
            var n = _unit.status_stacks[t];
            if (n <= 0) continue;

            var spr = status_get_sprite(t);
            if (spr == -1) continue;

            draw_icon_with_count(spr, cx, _y, icon_size, status_shows_count(t) ? n : -1);
            cx += icon_size + gap;
        }
    }

    draw_set_color(c_white);
}

// 在角色状态图标下方绘制倒计时。临时使用元素共鸣图标，之后可替换成专用计时 Sprite。
function draw_countdown_icons(_owner, _x, _y)
{
    if (!instance_exists(obj_hand_controller)) return;

    var cds = obj_hand_controller.countdowns;
    var icon_size = 22;
    var gap = 6;
    var index = 0;

    for (var i = 0; i < array_length(cds); i++)
    {
        var cd = cds[i];
        if (cd.owner != _owner) continue;

        var ix = _x + index * (icon_size + gap);
        var iy = _y;
        var spr = spr_resonance;

        draw_sprite_stretched(spr, 0, ix, iy, icon_size, icon_size);

        draw_set_font(global.chinese_font);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_set_color(c_black);
        draw_text(ix + icon_size + 1, iy + icon_size + 1, string(cd.turns));
        draw_set_color(c_white);
        draw_text(ix + icon_size, iy + icon_size, string(cd.turns));

        // 鼠标悬停时显示倒计时和即将释放的效果
        if (point_in_rectangle(mouse_x, mouse_y, ix, iy, ix + icon_size, iy + icon_size))
        {
            var detail = "";
            for (var k = 0; k < array_length(cd.effects); k++)
            {
                var e = cd.effects[k];
                var part = "触发效果";

                switch (e.type)
                {
                    case EffectType.ARMOR: part = "获得" + string(e.amount) + "点护甲"; break;
                    case EffectType.GAIN_ENERGY: part = "获得" + string(e.amount) + "费"; break;
                    case EffectType.DRAW: part = "抽" + string(e.amount) + "张牌"; break;
                    case EffectType.DAMAGE: part = "造成" + string(e.amount) + "点伤害"; break;
                    case EffectType.MOVE_TO_BACK: part = "移动至后场"; break;
                    case EffectType.BRING_TO_FRONT: part = "移动至前场"; break;
                    case EffectType.DISCOVER_OWN: part = "发现一张本角色的牌"; break;
                    case EffectType.ADD_TO_HAND:
                        var n = variable_struct_exists(e, "count") ? e.count : 1;
                        part = "将" + string(n) + "张牌置入手牌";
                    break;
                    case EffectType.STATUS: part = "获得状态"; break;
                }

                if (detail != "") detail += "；";
                detail += part;
            }

            var tip = "倒计时" + string(cd.turns) + "：" + string(cd.turns)
                    + "回合后，释放" + detail;

            var tx = clamp(mouse_x + 18, 8, room_width - 360);
            var ty = clamp(mouse_y - 48, 8, room_height - 54);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(c_black);
            draw_rectangle(tx - 6, ty - 5, tx + 360, ty + 40, false);
            draw_set_color(c_white);
            draw_rectangle(tx - 6, ty - 5, tx + 360, ty + 40, true);
            draw_text(tx, ty, tip);
        }

        index++;
    }

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// 永久状态牌：不占状态位置，也不会被顶掉
function card_state_is_permanent(_id)
{
    return (_id == 10 || _id == 209);
}

// 移除一张状态牌给这个角色带来的效果（图标也会消失）
function state_remove(_char, _card_id)
{
    var effects = card_get_effects(_card_id);

    for (var i = 0; i < array_length(effects); i++)
    {
        var e = effects[i];

        // 这张牌给自己加的状态（比如元素共鸣）：清掉
        if (e.type == EffectType.STATUS && variable_struct_exists(e, "on_char"))
        {
            clear_status(_char, e.status);
        }
    }

    // 以后状态牌有别的持续效果（不是状态图标的），在这里补上对应的移除
}

// 这个角色使用了一张状态牌：顶掉旧的状态牌效果，普通状态牌成为新的当前状态
function state_card_played(_char, _card_id)
{
    if (!instance_exists(_char)) return;

    // （如果不想让 29 也顶掉当前状态：在这里加一行 if (_card_id == 29) return;）

    // 这个角色当前的状态牌编号（0 = 没有）
    var current = variable_instance_exists(_char, "state_card_id") ? _char.state_card_id : 0;

    // 使用任何状态牌，都会让当前的状态牌效果消失
    if (current != 0)
    {
        state_remove(_char, current);
        _char.state_card_id = 0;
    }

    // 永久牌（10、29）不占位置；普通状态牌成为新的当前状态
    if (!card_state_is_permanent(_card_id))
    {
        _char.state_card_id = _card_id;
    }
}