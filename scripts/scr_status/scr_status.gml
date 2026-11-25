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
	BLOOD,       // 血色：与心羽的天赋计数共用
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
    TEMP_STRENGTH,    // 临时力量：本回合物理伤害 +1/层
    STARFIRE,     // 星火与燎原：本回合第一张初始牌合成强化
    FROST_RAIN,   // 冰寒·落雨：下一张霜落对其他敌人重复
    ROCK_WALL,    // 地岳·镇垒：本回合岩盾前场化且护甲翻倍
    WITCH_CHANT,  // 女巫吟唱：本局每回合第一次初始牌延迟重放
    VULNERABLE,   // 脆弱：受到的伤害提高50%，层数表示剩余回合
    COUNT        // 状态种类总数（放在最后，新状态加在它前面）
	
}

// 状态图标
function status_get_sprite(_type)
{
    switch (_type)
    {
        case StatusType.CHILL:
        case StatusType.FROST_RAIN: return spr_chill;

        case StatusType.FROZEN: return spr_frozen;
        case StatusType.RESONANCE:
        case StatusType.OVERCHARGE: return spr_resonance;

        case StatusType.STRENGTH_DOWN:
        case StatusType.VULNERABLE: return spr_strength_down;
        case StatusType.MAGIC_DOWN: return spr_magic_down;

        case StatusType.STRENGTH:
        case StatusType.LAVA_WARD: return spr_strength;

        case StatusType.DEXTERITY:
        case StatusType.ARMOR_KEEP:
        case StatusType.ROCK_WALL: return spr_dexterity;

        case StatusType.SWORD_FORM:
        case StatusType.WIND_COURT:
        case StatusType.WITCH_CHANT: return spr_sword_form;

        case StatusType.BLOOD: return spr_blood;
        case StatusType.DILIGENCE: return spr_diligence;

        case StatusType.MAGIC_POWER:
        case StatusType.TEMP_MAGIC: return spr_status_magic_power;
        case StatusType.TEMP_STRENGTH: return spr_strength;

        case StatusType.INK: return spr_status_ink;
        case StatusType.CORPSE_THIEF: return spr_status_corpse;

        case StatusType.READING:
        case StatusType.STARFIRE: return spr_star;
    }

    return -1;
}

// 这个状态是否在图标上显示层数
function status_shows_count(_type)
{
    switch (_type)
    {
        case StatusType.CHILL:
        case StatusType.RESONANCE:
        case StatusType.STRENGTH_DOWN:
        case StatusType.MAGIC_DOWN:
        case StatusType.VULNERABLE:
        case StatusType.STRENGTH:
        case StatusType.DEXTERITY:
        case StatusType.SWORD_FORM:
        case StatusType.BLOOD:
        case StatusType.DILIGENCE:
        case StatusType.MAGIC_POWER:
        case StatusType.TEMP_MAGIC:
        case StatusType.TEMP_STRENGTH:
            return true;
    }

    return false;
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
    var magic_down = get_status(_enemy, StatusType.MAGIC_DOWN);

    for (var i = 0; i < array_length(hits); i++)
    {
        var h = hits[i];

        // 物理攻击扣力量下降，魔法攻击扣魔力下降；连续攻击的每一击都会计算减益。
        var reduce = (h.dtype == DamageType.PHYSICAL) ? strength_down : magic_down;
        deal_damage(target, max(h.damage - reduce, 0), h.dtype);
    }

    // 力量/魔力下降只影响这名敌人的下一次行动。
    if (strength_down > 0) clear_status(_enemy, StatusType.STRENGTH_DOWN);
    if (magic_down > 0) clear_status(_enemy, StatusType.MAGIC_DOWN);
}
// 读取层数
function get_status(_unit, _type)
{
    if (!instance_exists(_unit)) return 0;

    // 心羽的血色与天赋计数共用同一个数值，不再作为第二个独立状态保存。
    if (_type == StatusType.BLOOD && variable_instance_exists(_unit, "talent_count"))
        return _unit.talent_count;

    if (!variable_instance_exists(_unit, "status_stacks")) return 0;
    return _unit.status_stacks[_type];
}

// 增加层数
function character3_add_blood(_unit, _amount)
{
    if (!instance_exists(_unit)) return;
    if (!variable_instance_exists(_unit, "talent_count")) return;
    if (!variable_instance_exists(_unit, "talent_need") || _unit.talent_need <= 0) return;

    _unit.talent_count += _amount;

    var controller = instance_find(obj_hand_controller, 0);
    if (!instance_exists(controller) || controller.char_3 != _unit) return;

    // 达到阈值时消耗6层血色，失去2点体力，并发现一张特殊剑招。
    while (_unit.talent_count >= _unit.talent_need)
    {
        _unit.talent_count -= _unit.talent_need;
        lose_hp(_unit, 2);
        controller.request_discover(discover_pool_xinyu(controller.discover_46_unlocked), 3);
    }
}

function add_status(_unit, _type, _stacks)
{
    if (!instance_exists(_unit)) return;

    // 心羽获得血色时，直接增加天赋进度，不再生成重复的独立状态图标。
    if (_type == StatusType.BLOOD && variable_instance_exists(_unit, "talent_count"))
    {
        if (variable_instance_exists(_unit, "status_stacks"))
        {
            _unit.talent_count += _unit.status_stacks[StatusType.BLOOD];
            _unit.status_stacks[StatusType.BLOOD] = 0;
        }
        character3_add_blood(_unit, _stacks);
        return;
    }

    status_init(_unit);
    _unit.status_stacks[_type] += _stacks;
}

// 移除某个状态的全部层数
function clear_status(_unit, _type)
{
    if (!instance_exists(_unit)) return;

    if (_type == StatusType.BLOOD && variable_instance_exists(_unit, "talent_count"))
        _unit.talent_count = 0;

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

function status_get_name(_type)
{
    switch (_type)
    {
        case StatusType.CHILL: return "寒冷";
        case StatusType.FROZEN: return "冻结";
        case StatusType.RESONANCE: return "元素共鸣";
        case StatusType.STRENGTH_DOWN: return "力量下降";
        case StatusType.MAGIC_DOWN: return "魔力下降";
        case StatusType.VULNERABLE: return "脆弱";
        case StatusType.STRENGTH: return "力量";
        case StatusType.DEXTERITY: return "敏捷";
        case StatusType.SWORD_FORM: return "剑招";
        case StatusType.BLOOD: return "血色";
        case StatusType.DILIGENCE: return "精进";
        case StatusType.MAGIC_POWER: return "魔力";
        case StatusType.INK: return "墨化";
        case StatusType.CORPSE_THIEF: return "窃尸";
        case StatusType.ARMOR_KEEP: return "护甲保留";
        case StatusType.LAVA_WARD: return "熔岩加护";
        case StatusType.OVERCHARGE: return "聚能";
        case StatusType.WIND_COURT: return "风息庭";
        case StatusType.READING: return "阅读";
        case StatusType.TEMP_MAGIC: return "临时魔力";
        case StatusType.TEMP_STRENGTH: return "临时力量";
        case StatusType.STARFIRE: return "星火与燎原";
        case StatusType.FROST_RAIN: return "落雨";
        case StatusType.ROCK_WALL: return "镇垒";
        case StatusType.WITCH_CHANT: return "女巫吟唱";
    }
    return "状态";
}

function status_get_description(_type)
{
    switch (_type)
    {
        case StatusType.CHILL: return "回合开始时，若寒冷达到3层，清除寒冷并施加冻结。";
        case StatusType.FROZEN: return "下次行动跳过一次，随后移除冻结。";
        case StatusType.RESONANCE: return "每个我方回合开始时，倒计时1：将一张随机元素牌洗入抽牌堆。";
        case StatusType.STRENGTH_DOWN: return "下次行动期间，每次物理攻击伤害减少对应层数。";
        case StatusType.MAGIC_DOWN: return "下次行动期间，每次魔法攻击伤害减少对应层数。";
        case StatusType.VULNERABLE: return "受到的伤害提高50%，层数表示剩余回合数。";
        case StatusType.STRENGTH: return "每层使造成的物理伤害提高1点。";
        case StatusType.DEXTERITY: return "每层使获得的护甲提高1点。";
        case StatusType.SWORD_FORM: return "带有剑招标签的牌造成的伤害提高对应层数。";
        case StatusType.BLOOD: return "与心羽的天赋计数共用。打出符合条件的攻击牌或获得血色都会推进计数；达到阈值时发现心羽的牌。";
        case StatusType.DILIGENCE: return "每个我方回合开始时，每层将一张0费的【练心】置入手牌。";
        case StatusType.MAGIC_POWER: return "每层使造成的魔法伤害提高1点。";
        case StatusType.INK: return "墨灵受到伤害降至10点以下后，在下回合开始时触发墨化护甲。";
        case StatusType.CORPSE_THIEF: return "盗尸者的特殊状态。";
        case StatusType.ARMOR_KEEP: return "下个回合开始时保留护甲一次。";
        case StatusType.LAVA_WARD: return "持续期间每次损失护甲，都会将一张【火球】置入抽牌堆。";
        case StatusType.OVERCHARGE: return "下一张技能牌额外结算一次。";
        case StatusType.WIND_COURT: return "每个我方回合开始时，将一张【风刃】置入手牌。";
        case StatusType.READING: return "每个我方回合开始时，发现一张本角色的牌。";
        case StatusType.TEMP_MAGIC: return "本回合魔法伤害提高1点/层。";
        case StatusType.TEMP_STRENGTH: return "本回合物理伤害提高1点/层。";
        case StatusType.STARFIRE: return "本回合第一张初始牌会进行一次合成强化。";
        case StatusType.FROST_RAIN: return "下一张【霜落】会对其他敌人重复结算。";
        case StatusType.ROCK_WALL: return "本回合【岩盾】会令角色移动至前场，且护甲翻倍。";
        case StatusType.WITCH_CHANT: return "本局每回合第一次使用初始牌时，倒计时1：延迟重放该牌。";
    }
    return "查看该状态的当前效果。";
}

function draw_status_tooltip(_type, _count, _spr)
{
    if (_spr == -1 || !sprite_exists(_spr)) return;

    var box_w = 390;
    // GML 绘图换行使用 #；## 形成真正的空白行。
    var desc = string_replace_all(status_get_description(_type), "。", "。##");
    var text_w = box_w - 124;
    var text_scale = 0.70;
    var text_sep = 6;
    var desc_h = string_height_ext(desc, text_sep, text_w / text_scale) * text_scale;
    var box_h = max(118, desc_h + 66);
    var tx = clamp(mouse_x + 18, 8, room_width - box_w - 8);
    var ty = clamp(mouse_y - box_h - 16, 8, room_height - box_h - 8);

    draw_set_alpha(0.94);
    draw_set_color(make_color_rgb(18, 22, 34));
    draw_rectangle(tx, ty, tx + box_w, ty + box_h, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(145, 165, 205));
    draw_rectangle(tx, ty, tx + box_w, ty + box_h, true);

    var icon_size = 80;
    var icon_scale = icon_size / max(sprite_get_width(_spr), sprite_get_height(_spr));
    var icon_x = tx + 12 + sprite_get_xoffset(_spr) * icon_scale;
    var icon_y = ty + 12 + sprite_get_yoffset(_spr) * icon_scale;
    draw_sprite_ext(_spr, 0, icon_x, icon_y, icon_scale, icon_scale, 0, c_white, 1);

    draw_set_font(global.chinese_font);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text(tx + 108, ty + 10, status_get_name(_type) + "  ×" + string(_count));
    draw_text_ext_transformed(tx + 108, ty + 42, desc,
        text_sep, text_w / text_scale, text_scale, text_scale, 0);

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// 在 (_x, _y)（图标行的左上角）处，横向画出这个单位的天赋和身上的所有状态图标
function draw_status_icons(_unit, _x, _y)
{
    var icon_size = 24;   // 图标大小（像素）
    var gap = 6;          // 图标之间的间距
    var cx = _x;
    var hovered_type = -1;
    var hovered_count = 0;
    var hovered_sprite = -1;

    // 天赋：始终显示，数值是 0 也在
    if (variable_instance_exists(_unit, "talent_spr"))
    {
        draw_icon_with_count(_unit.talent_spr, cx, _y, icon_size, _unit.talent_count);
        if (point_in_rectangle(mouse_x, mouse_y, cx, _y, cx + icon_size, _y + icon_size))
        {
            hovered_type = StatusType.BLOOD;
            hovered_count = _unit.talent_count;
            hovered_sprite = _unit.talent_spr;
        }
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
            if (point_in_rectangle(mouse_x, mouse_y, cx, _y, cx + icon_size, _y + icon_size))
            {
                hovered_type = t;
                hovered_count = n;
                hovered_sprite = spr;
            }
            cx += icon_size + gap;
        }
    }

    if (hovered_type >= 0)
        draw_status_tooltip(hovered_type, hovered_count, hovered_sprite);

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
                    case EffectType.ARMOR:
                        if (variable_struct_exists(e, "conditional_no_attack") && e.conditional_no_attack)
                        {
                            part = "若上回合未使用攻击牌，获得" + string(e.amount) + "点护甲";
                        }
                        else
                        {
                            part = "获得" + string(e.amount) + "点护甲";
                        }
                    break;
                    case EffectType.GAIN_ENERGY: part = "获得" + string(e.amount) + "费"; break;
                    case EffectType.DRAW: part = "抽" + string(e.amount) + "张牌"; break;
                    case EffectType.DAMAGE: part = "造成" + string(e.amount) + "点伤害"; break;
                    case EffectType.DAMAGE_OTHERS: part = "对其他敌人造成" + string(e.amount) + "点伤害"; break;
                    case EffectType.DAMAGE_ARMOR_TOTAL: part = "造成等同于护甲总和的伤害"; break;
                    case EffectType.MOVE_TO_BACK: part = "移动至后场"; break;
                    case EffectType.BRING_TO_FRONT: part = "移动至前场"; break;
                    case EffectType.DISCOVER_OWN: part = "发现一张本角色的牌"; break;
                    case EffectType.ADD_TO_HAND:
                    {
                        var n = variable_struct_exists(e, "count") ? e.count : 1;
                        var card_name = "牌";
                        if (variable_struct_exists(e, "card_id"))
                        {
                            switch (e.card_id)
                            {
                                case 1: card_name = "【火球】"; break;
                                case 2: card_name = "【风刃】"; break;
                                case 3: card_name = "【霜落】"; break;
                                case 4: card_name = "【岩盾】"; break;
                            }
                        }
                        part = "将" + string(n) + "张" + card_name + "置入手牌";
                    }
                    break;
                    case EffectType.STATUS:
                    {
                        var status_name = "状态";
                        switch (e.status)
                        {
                            case StatusType.MAGIC_POWER: status_name = "魔力"; break;
                            case StatusType.STRENGTH: status_name = "力量"; break;
                            case StatusType.DEXTERITY: status_name = "敏捷"; break;
                            case StatusType.CHILL: status_name = "寒冷"; break;
                            case StatusType.FROZEN: status_name = "冻结"; break;
                            case StatusType.ARMOR_KEEP: status_name = "护甲保留"; break;
                            case StatusType.TEMP_MAGIC: status_name = "临时魔力"; break;
                        }
                        part = "获得" + string(e.amount) + "层" + status_name;
                    }
                    break;
                    case EffectType.REPLAY_STARTER:
                    {
                        var starter_name = "初始牌";
                        switch (e.card_id)
                        {
                            case 1: starter_name = "【火球】"; break;
                            case 2: starter_name = "【风刃】"; break;
                            case 3: starter_name = "【霜落】"; break;
                            case 4: starter_name = "【岩盾】"; break;
                        }
                        part = "视为使用" + starter_name;
                    }
                    break;
                    case EffectType.ADD_ENTRY_TO_HAND: part = "将强化后的牌加入手牌"; break;
                    case EffectType.SHUFFLE_ELEMENT: part = "将一张随机元素牌洗入抽牌堆"; break;
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
    // 尘的战斗常驻状态：不占普通状态牌位置，也不会被另一张状态牌顶掉。
    return (_id == 209 || _id == 43 || _id == 120 || _id == 123
        || _id == 144 || _id == 147 || _id == 149 || _id == 152
        || _id == 153 || _id == 155);
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

    // 元素共鸣被其他状态牌替换时，取消已经排队的随机元素牌倒计时
    if (_card_id == 7 && instance_exists(obj_hand_controller))
    {
        with (obj_hand_controller)
        {
            countdown_remove_effect(1, EffectType.SHUFFLE_ELEMENT);
        }
    }

    // 尘的战斗常驻状态：被另一张状态牌替换时移除
    if (_card_id == 120) _char.purple_star = false;
    if (_card_id == 123) _char.star_damage_bonus_active = false;
    if (_card_id == 144) _char.star_bond_active = false;
    if (_card_id == 147) _char.team_echo_active = false;
    if (_card_id == 149) _char.night_guard_active = false;
    if (_card_id == 152)
    {
        _char.star_walk_active = false;
        _char.starlight_unlimited = false;
    }
}

// 这个角色使用了一张状态牌：顶掉旧的状态牌效果，普通状态牌成为新的当前状态
function state_card_played(_char, _card_id)
{
    if (!instance_exists(_char)) return;

    // 永久状态牌不占普通状态位置，也不应顶掉已有的普通状态牌。
    if (card_state_is_permanent(_card_id)) return;

    // 新的普通状态牌替换当前普通状态牌。
    var current = variable_instance_exists(_char, "state_card_id") ? _char.state_card_id : 0;
    if (current != 0)
        state_remove(_char, current);

    _char.state_card_id = _card_id;
}