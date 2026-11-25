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
    // 烬战、杀念等授予的临时0费优先于卡牌自身的动态费用。
    if (variable_instance_exists(_inst, "cost_temporary") && _inst.cost_temporary)
        return 0;

    if (_inst.card_id == 132 && instance_exists(obj_hand_controller)
    && instance_exists(obj_hand_controller.char_2))
        return max(7 - obj_hand_controller.char_2.attack_cards_used_battle, 0);

    if (instance_exists(obj_hand_controller) && instance_exists(obj_hand_controller.char_3))
    {
        var heart = obj_hand_controller.char_3;

        // 追斩：本回合已使用两张攻击牌后变为0费。
        if (_inst.card_id == 232 && character3_attack_count_this_turn() >= 2) return 0;

        // 血袭：每层力量使费用降低1点。
        if (_inst.card_id == 240)
            return max(3 - get_status(heart, StatusType.STRENGTH), 0);

        // 剑鸣：接下来的两张剑招不消耗费用。
        if (card_has_tag(_inst.card_id, CardTag.SWORD) && heart.sword_song_charges > 0)
            return 0;
    }

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
    switch (_inst.card_id)
    {
        // 苏灵兮新卡牌描述
        case 5:  return "抽" + string(card_current_draw(_inst)) + "张牌。倒计时1：获得2费";
        case 7:  return "每回合开始时，倒计时1：将一张随机的元素牌洗入你的抽牌堆";
        case 11: return "获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲和"
                      + string(card_current_armor_of(_inst, ArmorType.MAGIC)) + "点魔法护甲";
        case 12: return "获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL))
                      + "点护甲，直到下回合开始之前，当你损失护甲后，将一张【火球】置入抽牌堆";
        case 13: return "获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL))
                      + "点护甲，移动至前场，你的护甲可以保留至下回合";
        case 14: return "倒计时1：移动至后场，发现一张本角色的牌";
        case 15: return "获得1费。倒计时1：获得1费";
        case 16: return "消耗，获得1点魔力，倒计时1：获得1点魔力。倒计时2：获得1点魔力";
        case 17: return "移动，获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲。若你本回合使用过【风刃】，抽一张牌";
        case 18: return "选择一张初始牌并将其置入你的手牌";
        case 19: return "对敌方角色造成" + string(card_current_damage(_inst)) + "点伤害。若击杀目标则将一张0费的【火球】置入手牌";
        case 21: return "抽" + string(card_current_draw(_inst)) + "张牌，获得" + string(card_current_status(_inst, StatusType.TEMP_MAGIC)) + "点临时魔力。若你本回合使用过两种不同的初始牌，获得" + string(card_current_value(_inst, EffectType.GAIN_ENERGY)) + "点费用";
        case 22: return "造成" + string(card_effect_at(_inst, 0)) + "点魔法伤害。若目标被冻结，则额外造成"
                      + string(card_effect_at(_inst, 1)) + "点魔法伤害";
        case 24: return "消耗一张【风刃】，令你手牌中的所有【火球】造成的伤害+3";
        case 25: return "从抽牌堆抽取五张【风刃】";
        case 26: return "本角色使用的下一张技能牌额外结算1次";
        case 27: return "倒计时2：将三张【火球】置入手牌，并令其均变为0费和伤害+2";
        case 23: return "你每回合打出的第一张初始牌视为进行一次合成强化";
        case 28: return "获得五张伤害-2的【火球】，并将其依次打出";
        case 29: return "消耗一张【火球】，对所有敌人造成等同于该【火球】的伤害";
        case 30: return "消耗任意张【风刃】，获得等同于其伤害总和两倍的护甲";
        case 31: return "消耗一张【风刃】，令敌方前排移动。本回合【风刃】伤害+2";
        case 32: return "你使用的下一张【霜落】会对其他敌方角色各重复一次";
        case 33: return "消耗一张【霜落】，令一名敌人获得冻结";
        case 34: return "消耗一张【岩盾】，造成等同于你所有护甲总和的物理伤害";
        case 36: return "令你手中的所有牌获得保留一回合";
        case 35: return "将你的一张手牌变为【岩盾】。本回合【岩盾】还会令角色移动至前场，且获得的所有护甲翻倍";
        case 37: return "回合开始时，发现一张本角色的牌，若你在本回合使用，获得1费";
        case 39: return "令本角色所有的倒计时-1";
        case 38: return "随机视为使用一张本角色的初始牌，并将该初始牌的复制置入手牌";
        case 41: return "消耗，将本角色的所有初始牌各一张置入你的手牌，将其变为0费。然后回复" + string(card_current_value(_inst, EffectType.HEAL)) + "点体力值";
        case 40: return "消耗。令你手牌、抽牌堆、弃牌堆中的所有苏灵兮初始牌各进行一次合成强化";
        case 42: return "所有友方角色获得倒计时1：若本角色上回合没有使用过攻击牌，获得10点护甲（实际护甲还会受到各角色敏捷影响）";
        case 43: return "在本局对战剩余时间内，每回合当本角色第一次从手牌中打出初始牌时，倒计时1：视为使用该初始牌";
        case 45: return "将你手牌、抽牌堆和弃牌堆中的所有【火球】合成为一张，然后使用并消耗";
        case 46: return "消耗。选择手牌中的一张初始牌，将其消耗。倒计时2：将一张其合成强化后的置入手牌";
        case 44: return "将十张【风刃】置入你的手牌。每回合开始时，将一张【风刃】置入你的手牌";


        
        // 尘：星星的孩子
        case 101: return "造成" + string(card_current_damage(_inst)) + "点法术伤害";
        case 102: return "对前场敌人造成" + string(card_current_damage(_inst)) + "点法术伤害，\n对其他敌人造成" + string(card_current_others(_inst)) + "点法术伤害";
        case 103: return "获得" + string(card_current_xingguang(_inst)) + "点星光";
        case 104: return "令一名敌方角色下回合的力量和魔力各降低6点";
        case 105: return "造成" + string(card_current_damage(_inst)) + "点法术伤害；若本回合其他角色使用过攻击牌，此伤害额外+6";
        case 106: return "造成" + string(card_current_damage(_inst)) + "点物理伤害，令所有后场友方角色获得5点护甲（实际护甲还会受到各角色敏捷影响）";
        case 107: return "占卜" + string(card_current_value(_inst, EffectType.SCRY)) + "，然后抽" + string(card_current_draw(_inst)) + "张牌";
        case 108: return "占卜" + string(card_current_value(_inst, EffectType.SCRY)) + "，然后投射星星：每置入牌堆底1张牌，造成2点伤害";
        case 109: return "造成" + string(card_current_damage(_inst)) + "点物理伤害";
        case 110: return "令一名其他友方角色和尘各获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点护甲";
        case 111: return "造成" + string(card_current_damage(_inst)) + "点物理伤害，获得" + string(card_current_xingguang(_inst)) + "点星光";
        case 112: return "令一名敌方角色进入前场，然后造成" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点伤害";
        case 113: return "观看弃牌堆中随机5张牌，选择至多" + string(card_current_value(_inst, EffectType.CUSTOM)) + "张置入手牌";
        case 114: return "造成" + string(card_current_damage(_inst)) + "点法术伤害（每有1点星光，此伤害额外提高1点）";
        case 115: return "固有。造成" + string(card_current_damage(_inst)) + "点物理伤害；若此牌是本回合使用的第一张牌，获得" + string(card_current_xingguang(_inst)) + "点星光";
        case 116: return "获得" + string(card_current_xingguang(_inst)) + "点星光和" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲，并进入前场。当本牌被占卜置入牌堆底时，改为置入手牌";
        case 117: return "抽" + string(card_current_draw(_inst)) + "张牌，然后弃置2张牌。被弃置的牌获得【繁星】";
        case 118: return "获得" + string(card_current_status(_inst, StatusType.DEXTERITY)) + "点敏捷";
        case 119: return "选择一张其他角色的手牌，本回合此牌可以将星光当作费用使用";
        case 120: return "在本场战斗剩余时间内，每回合开始时，尘占卜" +
            string(2 + (instance_exists(obj_hand_controller.char_2) ? obj_hand_controller.char_2.scry_bonus : 0));
        case 121: return "虚无。抽到此牌时，下回合获得2费";
        case 122: return "对所有敌人造成" + string(card_current_damage(_inst)) + "点伤害，每击杀一个敌人，获得1点星光";
        case 123: return "本场战斗中，你队伍造成的所有伤害+" + string(card_current_value(_inst, EffectType.CUSTOM));
        case 124: return "消耗。令一名友方角色获得【长明】";
        case 125: return "消耗。选择一名敌方角色，令其退至后场；当尘使用攻击牌时，再次令其退至后场";
        case 126: return "追猎。造成" + string(card_current_damage(_inst)) + "点伤害";
        case 127: return "令一名敌方角色移动。当此牌被占卜置入牌堆底时，改为置入手牌";
        case 128: return "虚无。抽到此牌时，获得10点物理护甲和10点法术护甲";
        case 129: return "本回合所有友方角色获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点力量和" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点魔力";
        case 130: return "追猎。移除目标" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点任意护甲";
        case 131: return "对随机敌人造成7点法术伤害，重复" + string(max(card_current_times(_inst) - 1, 1)) + "次。每当抽到此牌时，额外重复1次（最多7次）";
        case 132: return "造成" + string(card_current_damage(_inst)) + "点物理伤害。尘每使用过一张攻击牌，此牌费用降低1点";
        case 133: return "进入前场，获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点护甲。若下回合开始前未受到伤害，额外获得3点护甲";
        case 134: return "令所有敌方角色失去" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点力量和" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点魔力，然后此牌费用+1";
        case 135: return "令一名其他友方角色移动，并获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点临时魔力";
        case 136: return "令自己移动，然后为抽牌堆中的一张牌施加【繁星】";
        case 137: return "造成" + string(card_current_damage(_inst)) + "点法术伤害。当本牌被占卜置入牌堆底时，此伤害额外提高3点";
        case 138: return "固有。你的下一张攻击牌造成的伤害额外+" + string(card_current_value(_inst, EffectType.CUSTOM));
        case 139: return "令一名其他友方角色获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点护甲；直到下回合开始前，其受到的溢出伤害由尘承担";
        case 140: return "消耗。每场战斗限一次：获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "费，并随机获得两张尘的牌，本回合变为0费";
        case 141: return "下个倒计时阶段开始时，额外抽" + string(card_current_countdown_value(_inst, EffectType.DRAW)) + "张牌并获得" + string(card_current_countdown_value(_inst, EffectType.STARLIGHT)) + "点星光";
        case 142: return "消耗1点星光，发现一张尘的攻击牌、技能牌和状态牌。所选牌保留一回合";
        case 143: return "消耗。造成" + string(card_current_damage(_inst)) + "点魔法伤害，令目标下回合无法行动";
        case 144: return "消耗2点星光。本场战斗中，友方角色使用攻击牌后，尘投射5点伤害";
        case 145: return "消耗。所有友方角色回复" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点体力，并获得10点法术护甲";
        case 146: return "固有，消耗。获得" + string(card_current_xingguang(_inst)) + "点星光";
        case 147: return "本场战斗中，每回合每名友方角色使用的第一张技能牌或攻击牌额外结算一次";
        case 148: return "消耗。为所有手牌施加【繁星】，然后弃置所有手牌并抽取等量的牌";
        case 149: return "在本场战斗中，当一名友方角色受到攻击时，令其获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点护甲";
        case 150: return "获得" + string(card_current_xingguang(_inst)) + "点星光，然后获得等同于当前星光数量的魔力和护甲";
        case 151: return "获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲。令其他友方角色获得等同于尘当前护甲总和的护甲";
        case 152: return "每回合结束时，为抽牌堆中的一张牌施加【繁星】；本场战斗中，星光补费不再限次";
        case 153: return "在本场战斗剩余时间内，你的所有占卜数量额外+1";
        case 154: return "虚无。抽到此牌时，获得8点护甲";
        case 155: return "在本场战斗剩余时间内，每回合结束时，你可以将一张手牌洗入抽牌堆";
        case 156: return "选择一张手牌置入牌堆顶，然后抽3张牌";

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

        // 心羽：星星的孩子
        case 201: return "剑招。造成" + string(card_current_damage(_inst)) + "点物理伤害";
        case 202: return "剑招，追猎。造成" + string(card_current_damage(_inst)) + "点物理伤害";
        case 203: return "剑招。获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲（包括剑招加成）";
        case 204: return "剑招。造成" + string(card_current_damage(_inst)) + "点物理伤害，令敌方下回合失去等量的力量";
        case 205: return "造成" + string(card_current_damage(_inst)) + "点魔法伤害，将一张【猩红】置入抽牌堆";
        case 206: return "造成" + string(card_current_damage(_inst)) + "点物理伤害，弃置你手中所有的【猩红】";
        case 207: return "消耗。失去3点体力，获得3层血色";
        case 208: return "消耗。获得1点力量和1点敏捷，回复1点体力";
        case 209: return "在本局对战剩余时间内，将【血.极】加入你的剑招中";
        case 210: return "每回合开始时，将一张0费的【练心】置入你的手牌";

        case 211: return "获得6点护甲；若心羽上回合未因敌方攻击损失体力，额外获得4点护甲";
        case 212: return "保留。心羽进入前场，抽1张牌";
        case 213: return "本回合获得" + string(card_current_status(_inst, StatusType.TEMP_STRENGTH)) + "点力量";
        case 214: return "消耗。获得2点费用，将两张【猩红】置入抽牌堆";
        case 215: return "造成" + string(card_current_damage(_inst)) + "点物理伤害。若本回合此前使用过攻击牌，抽1张牌";
        case 216: return "造成" + string(card_current_damage(_inst)) + "点物理伤害，获得" + string(card_current_armor_of(_inst, ArmorType.GENERAL)) + "点护甲";
        case 217: return "造成" + string(card_current_damage(_inst)) + "点物理伤害；若目标没有护甲，额外造成3点伤害";
        case 218: return "获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点护甲；若本回合使用过至少两张攻击牌，抽1张牌";
        case 219: return "造成" + string(card_current_damage(_inst)) + "点物理伤害。若此次伤害不小于15，令目标获得2层脆弱";
        case 220: return "造成" + string(card_current_damage(_inst)) + "点物理伤害。若此次伤害不小于8，获得1点费用";
        case 221: return "令前场角色获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "点物理护甲，将一张【猩红】置入抽牌堆";
        case 222: return "消耗一张【猩红】，获得1点费用";
        case 223: return "随机将一张本角色的攻击牌和一张【猩红】置入手牌，本回合变为0费";
        case 224: return "失去2点体力，造成" + string(card_current_damage(_inst)) + "点物理伤害";
        case 225: return "在本场对战剩余时间内，每回合开始时，获得1点力量并将一张虚无的【猩红】置入抽牌堆";

        case 226: return "追猎。造成" + string(card_current_damage(_inst)) + "点物理伤害；若击杀目标，获得2点费用并抽1张牌";
        case 227: return "在本场对战剩余时间内，每当你抽到【猩红】，获得1点力量";
        case 228: return "获得" + string((instance_exists(obj_hand_controller) && obj_hand_controller.battle_round == 1) ? 6 : 2) + "层血色";
        case 229: return "获得2点护甲。先锋：本回合心羽无法使用攻击牌，下回合获得3点力量";
        case 230: return "获得1层血色；若力量大于3，额外获得2层。然后将一张【猩红】置入抽牌堆";
        case 231: return "剑招。造成" + string(card_current_damage(_inst)) + "点物理伤害，视为使用抽牌堆顶的两张牌，并将一张【猩红】置入弃牌堆";
        case 232: return "剑招。造成" + string(card_current_damage(_inst)) + "点物理伤害；若本回合已使用至少两张攻击牌，此牌费用变为0";
        case 233: return "在本场对战剩余时间内，每回合开始时，将一张【猩红】置入抽牌堆；抽到【猩红】时，消耗并回复2点体力";
        case 234: return "消耗。接下来两张剑招不消耗费用";
        case 235: return "造成" + string(card_current_damage(_inst)) + "点魔法伤害。若此牌在回合结束时仍在手牌，将一张【猩红】置入弃牌堆";
        case 236: return "令一名角色获得5点护甲；每有1层血色，额外获得1点护甲";
        case 237: return "令我方后场上方的角色进入前场并获得13点护甲";
        case 238: return "令一名敌方角色失去10点护甲；若其原本没有护甲，获得1层脆弱";
        case 239: return "在本场对战剩余时间内，每当你使用攻击牌，本回合获得1点力量";
        case 240: return "造成" + string(card_current_damage(_inst)) + "点物理伤害。每有1点力量，此牌费用降低1点";

        case 241: return "剑招，消耗。造成" + string(card_current_damage(_inst)) + "点物理伤害，获得" + string(card_current_value(_inst, EffectType.ARMOR)) + "点护甲，令目标下回合力量和魔力各降低6点";
        case 242: return "剑招，消耗。对所有敌人造成" + string(card_current_damage(_inst)) + "点物理伤害";
        case 243: return "剑招，消耗，远程，追猎。造成" + string(card_current_damage(_inst)) + "点物理伤害";
        case 244: return "剑招，消耗。造成" + string(card_current_damage(_inst)) + "点物理伤害，重复" + string(card_current_times(_inst)) + "次";
        case 245: return "剑招，消耗。在本场对战剩余时间内，你的剑招伤害+" + string(card_current_status(_inst, StatusType.SWORD_FORM));
        case 246: return "剑招，消耗。造成" + string(card_current_damage(_inst)) + "点物理伤害";

        case 247: return "造成" + string(card_current_damage(_inst)) + "点魔法伤害。目标下次受到伤害时，心羽获得1层血色";
        case 248: return "在本场对战剩余时间内，你的剑招造成的伤害+2";
        case 249: return "消耗。造成" + string(card_current_damage(_inst)) + "点物理伤害，对其他敌人造成等同于溢出的伤害";
        case 250: return "在本场对战剩余时间内，每回合心羽在前场首次受到伤害时，移动至后场并防止本次伤害";
        case 251: return "下回合你的剑招造成的伤害+" + string(card_current_value(_inst, EffectType.CUSTOM));
        case 252: return "造成" + string(card_current_damage(_inst)) + "点物理伤害。每有一张手牌中的【猩红】，额外造成6点伤害；然后消耗所有手牌中的【猩红】";
        case 253: return "在本场对战剩余时间内，你每回合使用的第一张剑招额外结算一次";
        case 254: return "消耗。造成" + string(card_current_damage(_inst)) + "点物理伤害，回复等同于实际伤害一半的体力";
        case 255: return "在本场对战剩余时间内，每回合开始时将三张【猩红】置入抽牌堆；【猩红】具有保留。手牌中每张【猩红】使你拥有3点力量";
        case 256: return "倒计时1：造成" + string(card_current_countdown_value(_inst, EffectType.DAMAGE)) + "点物理伤害；若触发时手牌中没有【猩红】，视为使用此牌";
        case 257: return "在本场对战剩余时间内，每回合首次抽到异常牌时，将其消耗，抽1张牌并获得1点费用";
        case 258: return "发现一张特殊剑招。在本场对战剩余时间内，每回合开始时获得" + string(card_current_value(_inst, EffectType.CUSTOM)) + "层血色";
        case 259: return "抽取两张本角色的攻击牌，本回合这两张牌变为0费";

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
    var star_cost = card_star_cost(_inst.card_id);
    var cost_col = (shown_cost > base_cost) ? make_color_rgb(255, 90, 90) : c_white;
    var cost_text = string(shown_cost);
    if (star_cost > 0) cost_text += " ★" + string(star_cost);

    card_text_shadow(p_cost[0], p_cost[1], cost_text, ts * 1.4, _a, cost_col);

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