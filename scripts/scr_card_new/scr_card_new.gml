/// scr_card_new
/// 苏灵兮的新卡牌：基础信息、效果、描述、稀有度，以及战斗奖励的卡池

enum Rarity
{
    NONE,        // 不进奖励池（初始牌、通用牌、异常牌、特殊牌）
    COMMON,
    RARE,
    LEGENDARY
}

// 基础信息：类型、费用、稀有度、是否消耗、指向类型、需要手牌里有的牌编号（0 = 不需要）
function card_make_info(_type, _cost, _rarity, _exhaust, _target, _need)
{
    return { type: _type, cost: _cost, rarity: _rarity, exhaust: _exhaust, target: _target, need: _need };
}

function card_info(_id)
{
    switch (_id)
    {
        // ---- 普通 ----
        case 5:  return card_make_info(CardType.SKILL,  2, Rarity.COMMON, false, TargetKind.NONE, 0);    // 专注
        case 11: return card_make_info(CardType.SKILL,  2, Rarity.COMMON, false, TargetKind.NONE, 0);    // 风墙
        case 12: return card_make_info(CardType.SKILL,  2, Rarity.COMMON, false, TargetKind.NONE, 0);    // 熔岩加护
        case 13: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);    // 疾风步
        case 14: return card_make_info(CardType.SKILL,  0, Rarity.COMMON, false, TargetKind.NONE, 0);    // 品尝美食
        case 15: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);    // 召集元素
        case 16: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, true,  TargetKind.NONE, 0);    // 凝聚魔力
        case 17: return card_make_info(CardType.SKILL,  0, Rarity.COMMON, false, TargetKind.NONE, 0);    // 风回
        case 18: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);    // 四象
        case 19: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.ENEMY, 0);   // 引燃
        case 21: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);    // 元素更迭
        case 22: return card_make_info(CardType.ATTACK, 2, Rarity.COMMON, false, TargetKind.NONE, 0);    // 霜碎
        case 23: return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);       // 星火与燎原


        // ---- 稀有 ----
        case 7:  return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);      // 元素共鸣
        case 24: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 2);      // 风助火势（需要风刃）
        case 25: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);      // 千风所指
        case 26: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);      // 聚能
        case 27: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);      // 掌中微日
        case 28: return card_make_info(CardType.ATTACK, 2, Rarity.RARE, false, TargetKind.NONE, 0);       // 火凝·连珠
        case 29: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 0);       // 火凝·燎原
        case 30: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 0);       // 狂风·凝盾
        case 31: return card_make_info(CardType.ATTACK, 0, Rarity.RARE, false, TargetKind.NONE, 0);       // 狂风·流羽
        case 32: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 0);       // 冰寒·落雨

        case 35: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);       // 地岳·镇垒
        case 33: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.ENEMY, 3);     // 冰寒·霜索（需要霜落）
        case 34: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 4);      // 地岳·磐缚（需要岩盾）
        case 36: return card_make_info(CardType.SKILL,  0, Rarity.RARE, false, TargetKind.NONE, 0);      // 安宁
        case 37: return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);      // 阅读
        case 39: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);      // 灵光一现
        case 38: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);      // 随性发挥

        // ---- 传说 ----
        case 40: return card_make_info(CardType.SKILL,  3, Rarity.LEGENDARY, true, TargetKind.NONE, 0); // 元素亲和
        case 41: return card_make_info(CardType.SKILL,  3, Rarity.LEGENDARY, true,  TargetKind.NONE, 0); // 唯魔法与美食不可辜负
        case 42: return card_make_info(CardType.SKILL,  1, Rarity.LEGENDARY, false, TargetKind.NONE, 0); // 平凡即安乐
        case 43: return card_make_info(CardType.STATUS, 1, Rarity.LEGENDARY, false, TargetKind.NONE, 0); // 女巫吟唱
        case 45: return card_make_info(CardType.ATTACK, 2, Rarity.LEGENDARY, true, TargetKind.NONE, 0);  // 吃我火球术哒！
        case 46: return card_make_info(CardType.SKILL,  1, Rarity.LEGENDARY, true, TargetKind.NONE, 0);  // 压缩

        case 44: return card_make_info(CardType.STATUS, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0); // 风息庭
    }

    return undefined;
}

// 稀有度：新卡牌看 card_info，旧卡牌：初始牌、特殊牌、通用牌、异常牌不进奖励，其余当作普通
function card_rarity(_id)
{
    var info = card_info(_id);
    if (!is_undefined(info)) return info.rarity;

    if (_id <= 4) return Rarity.NONE;
    if (_id >= 101 && _id <= 104) return Rarity.NONE;
    if (_id >= 201 && _id <= 204) return Rarity.NONE;
    if (_id >= 241) return Rarity.NONE;

    return Rarity.COMMON;
}

// 打出这张牌需要手牌里有哪张牌（0 = 不需要）
function card_requirement(_id)
{
    var info = card_info(_id);

    return is_undefined(info) ? 0 : info.need;
}

// 是否是初始牌
function card_is_starter(_id)
{
    return ((_id >= 1 && _id <= 4) || (_id >= 101 && _id <= 104) || (_id >= 201 && _id <= 204));
}

// 发现、奖励的池子里能不能出现（剑招特殊牌只能靠心羽的天赋发现）
function card_in_pool(_id)
{
    return !(_id >= 241 && _id <= 246);
}

// 本回合打出过几种不同的初始牌
function turn_distinct_starters()
{
    var seen = [];
    var list = obj_hand_controller.turn_played_ids;

    for (var i = 0; i < array_length(list); i++)
    {
        var cid = list[i];

        if (!card_is_starter(cid)) continue;

        var dup = false;

        for (var k = 0; k < array_length(seen); k++)
        {
            if (seen[k] == cid) dup = true;
        }

        if (!dup) seen[array_length(seen)] = cid;
    }

    return array_length(seen);
}

// 某张牌第 _k 个效果的当前数值
function card_effect_at(_inst, _k)
{
    var effects = card_current_effects(_inst);

    return card_effect_final(effects[_k], _inst, noone);
}

// 给一组效果里的所有伤害加 _n 点（返回副本）
function effects_add_damage(_effects, _n)
{
    var result = card_copy_effects(_effects);

    for (var i = 0; i < array_length(result); i++)
    {
        if (result[i].type == EffectType.DAMAGE || result[i].type == EffectType.DAMAGE_OTHERS)
        {
            result[i].amount = max(result[i].amount + _n, 0);
        }
    }

    return result;
}

// ---------- 效果数据 ----------

function card_get_effects_new(_id)
{
    switch (_id)
    {
        // 5 专注：抽三张牌。倒计时1：获得2费
        case 5:
            return [
                { type: EffectType.DRAW, amount: 3 },
                { type: EffectType.COUNTDOWN, amount: 1, owner: 1,
                  effects: [ { type: EffectType.GAIN_ENERGY, amount: 2 } ] }
            ];

        // 11 风墙：获得8点护甲和9点魔法护甲
        case 11:
            return [
                { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 8, on_char: 1 },
                { type: EffectType.ARMOR, armor: ArmorType.MAGIC,   amount: 9, on_char: 1 }
            ];

        // 12 熔岩加护：获得10点护甲，直到下回合开始之前，当你损失护甲后，将一张火球置入抽牌堆
        case 12:
            return [
                { type: EffectType.ARMOR,  armor: ArmorType.GENERAL, amount: 10, on_char: 1 },
                { type: EffectType.STATUS, status: StatusType.LAVA_WARD, amount: 1, on_char: 1 }
            ];

        // 13 疾风步：获得5点护甲，移动至前场，你的护甲可以保留至下回合
        case 13:
            return [
                { type: EffectType.ARMOR,          armor: ArmorType.GENERAL, amount: 5, on_char: 1 },
                { type: EffectType.BRING_TO_FRONT, amount: 1, on_char: 1 },
                { type: EffectType.STATUS,         status: StatusType.ARMOR_KEEP, amount: 1, on_char: 1 }
            ];

        // 14 品尝美食：倒计时1：移动至后场，发现一张本角色的牌
        case 14:
            return [
                { type: EffectType.COUNTDOWN, amount: 1, owner: 1,
                  effects: [
                      { type: EffectType.MOVE_TO_BACK, amount: 1, on_char: 1 },
                      { type: EffectType.DISCOVER_OWN, amount: 1, on_char: 1 }
                  ] }
            ];

        // 15 召集元素：获得1费。倒计时1：获得1费
        case 15:
            return [
                { type: EffectType.GAIN_ENERGY, amount: 1 },
                { type: EffectType.COUNTDOWN, amount: 1, owner: 1,
                  effects: [ { type: EffectType.GAIN_ENERGY, amount: 1 } ] }
            ];

        // 16 凝聚魔力：消耗，获得1点魔力。倒计时1：获得1点魔力。倒计时2：获得1点魔力
        case 16:
            return [
                { type: EffectType.STATUS, status: StatusType.MAGIC_POWER, amount: 1, on_char: 1 },
                { type: EffectType.COUNTDOWN, amount: 1, owner: 1,
                  effects: [ { type: EffectType.STATUS, status: StatusType.MAGIC_POWER, amount: 1, on_char: 1 } ] },
                { type: EffectType.COUNTDOWN, amount: 2, owner: 1,
                  effects: [ { type: EffectType.STATUS, status: StatusType.MAGIC_POWER, amount: 1, on_char: 1 } ] }
            ];

        // 17 风回：移动，获得3点护甲；若本回合使用过风刃，抽一张牌
        case 17:
            return [
                { type: EffectType.ROTATE_SELF, amount: 1, on_char: 1 },
                { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 3, on_char: 1 },
                { type: EffectType.DRAW_IF_PLAYED, amount: 1, card_id: 2 }
            ];

        // 18 四象：选择一张初始牌并将其置入你的手牌
        case 18:
            return [
                { type: EffectType.DISCOVER_LIST, amount: 1, card_ids: [1, 2, 3, 4], count: 4 }
            ];

        // 19 引燃：对敌方角色造成7点伤害。若击杀目标则将一张0费的火球置入手牌
        case 19:
            return [
                { type: EffectType.DAMAGE, amount: 7, dtype: DamageType.MAGIC, on_kill_id: 1, on_kill_cost: 0 }
            ];

        // 21 元素更迭：抽一张牌，获得1点临时魔力。若你本回合使用过两种不同的初始牌，获得1点费用
        case 21:
            return [
                { type: EffectType.DRAW,        amount: 1 },
                { type: EffectType.STATUS,      status: StatusType.TEMP_MAGIC, amount: 1, on_char: 1 },
                { type: EffectType.GAIN_ENERGY, amount: 1, need_starters: 2 }
            ];

        // 22 霜碎：造成15点魔法伤害。若目标被冻结，则额外造成10点魔法伤害
        case 22:
            return [
                { type: EffectType.DAMAGE, amount: 15, dtype: DamageType.MAGIC },
                { type: EffectType.DAMAGE, amount: 10, dtype: DamageType.MAGIC, if_frozen: true }
            ];

        // 24 风助火势：消耗一张风刃，令你手牌中的所有火球造成的伤害+3
        case 24:
            return [
                { type: EffectType.CONSUME_FROM_HAND, amount: 1, card_id: 2 },
                { type: EffectType.BUFF_HAND_DAMAGE,  amount: 3, card_id: 1 }
            ];

        // 25 千风所指：从抽牌堆抽取五张风刃
        case 25:
            return [
                { type: EffectType.DRAW_CARD_ID, amount: 5, card_id: 2 }
            ];

        // 26 聚能：本角色使用的下一张技能牌额外结算1次
        case 26:
            return [
                { type: EffectType.STATUS, status: StatusType.OVERCHARGE, amount: 1, on_char: 1 }
            ];

        // 27 掌中微日：倒计时2：将三张火球置入手牌，并令其均变为0费和伤害+2
        case 27:
            return [
                { type: EffectType.COUNTDOWN, amount: 2, owner: 1,
                  effects: [ { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 1, count: 3, cost: 0, dmg_bonus: 2 } ] }
            ];

        // 33 冰寒·霜索：消耗一张霜落，令一名敌人获得冻结
        // 23 星火与燎原：本回合第一张初始牌视为合成强化一次
        case 23:
            return [ { type: EffectType.STATUS, status: StatusType.STARFIRE, amount: 1, on_char: 1 } ];

        // 28 火凝·连珠：生成五张伤害-2的火球并依次打出
        case 28:
            return [ { type: EffectType.FIREBALL_VOLLEY, amount: 5, damage_bonus: -2 } ];

        // 29 火凝·燎原：消耗一张火球，对所有敌人造成等同于火球的伤害
        case 29:
            return [ { type: EffectType.SELECT_HAND, filter_id: 1, mode: "single", min: 1, max: 1, action: { kind: "fireball_aoe" } } ];

        // 30 狂风·凝盾：消耗任意张风刃，获得其伤害总和两倍的护甲
        case 30:
            return [ { type: EffectType.SELECT_HAND, filter_id: 2, mode: "multi", min: 0, max: 999, action: { kind: "wind_shield" } } ];

        // 31 狂风·流羽：消耗一张风刃，敌方前排移动；本回合风刃伤害+2
        case 31:
            return [ { type: EffectType.SELECT_HAND, filter_id: 2, mode: "single", min: 1, max: 1, action: { kind: "wind_feather" } } ];

        // 32 冰寒·落雨：下一张霜落会对其他敌人各重复一次
        case 32:
            return [ { type: EffectType.STATUS, status: StatusType.FROST_RAIN, amount: 1, on_char: 1 } ];

        case 33:
            return [
                { type: EffectType.CONSUME_FROM_HAND, amount: 1, card_id: 3 },
                { type: EffectType.STATUS, status: StatusType.FROZEN, amount: 1 }
            ];

        // 34 地岳·磐缚：消耗一张岩盾，造成等同于你所有护甲总和的物理伤害
        case 34:
            return [
                { type: EffectType.CONSUME_FROM_HAND,  amount: 1, card_id: 4 },
                { type: EffectType.DAMAGE_ARMOR_TOTAL, amount: 1, dtype: DamageType.PHYSICAL, on_char: 1 }
            ];

        // 36 安宁：令你手中的所有牌获得保留一回合
        // 35 地岳·镇垒：将一张手牌变为岩盾
        case 35:
            return [ { type: EffectType.SELECT_HAND, filter_id: 0, mode: "single", min: 1, max: 1, action: { kind: "convert_rockshield" } } ];

        case 36:
            return [
                { type: EffectType.RETAIN_HAND, amount: 1 }
            ];

        // 37 阅读：回合开始时，发现一张本角色的牌。若你在本回合使用，获得1费
        case 37:
            return [
                { type: EffectType.STATUS,      status: StatusType.READING, amount: 1, on_char: 1 },
                { type: EffectType.GAIN_ENERGY, amount: 1 }
            ];

        // 39 灵光一现：令本角色所有的倒计时-1
        // 38 随性发挥：随机视为使用一张本角色初始牌，并复制一张到手牌
        case 38:
            return [ { type: EffectType.RANDOM_STARTER, amount: 1, on_char: 1 } ];

        case 39:
            return [
                { type: EffectType.COUNTDOWN_SHIFT, amount: 1, on_char: 1 }
            ];

        // 41 唯魔法与美食不可辜负：消耗，将本角色的所有初始牌各一张置入手牌并变为0费，然后回复5点体力值
        // 40 元素亲和：消耗，强化所有区域里的苏灵兮初始牌
        case 40:
            return [ { type: EffectType.UPGRADE_ALL_STARTERS, amount: 1, on_char: 1 } ];

        case 41:
            return [
                { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 1, count: 1, cost: 0 },
                { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 2, count: 1, cost: 0 },
                { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 3, count: 1, cost: 0 },
                { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 4, count: 1, cost: 0 },
                { type: EffectType.HEAL,        amount: 5, on_char: 1 }
            ];

        // 44 风息庭：将十张风刃置入你的手牌。每回合开始时，将一张风刃置入你的手牌
        // 42 平凡即安乐：友方角色倒计时1，若上回合没用攻击牌，获得10护甲
        case 42:
            return [ { type: EffectType.COUNTDOWN_ALL_FRIENDS, amount: 1, effects: [ { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 10, conditional_no_attack: true } ] } ];

        // 43 女巫吟唱：本场战斗中，每回合第一次打出初始牌时，倒计时1重放
        case 43:
            return [ { type: EffectType.STATUS, status: StatusType.WITCH_CHANT, amount: 1, on_char: 1 } ];

        // 45 吃我火球术哒！：消耗所有区域里的火球，合成一张并打出
        case 45:
            return [ { type: EffectType.MERGE_ALL_FIREBALLS, amount: 1 } ];

        // 46 压缩：消耗一张初始牌，倒计时2将其强化后的版本加入手牌
        case 46:
            return [ { type: EffectType.SELECT_HAND, filter_id: -1, mode: "single", min: 1, max: 1, action: { kind: "compress" } } ];

        case 44:
            return [
                { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 2, count: 10 },
                { type: EffectType.STATUS,      status: StatusType.WIND_COURT, amount: 1, on_char: 1 }
            ];
    }

    return [];
}

// ---------- 卡面描述（空字符串 = 不是新卡牌）----------

function card_get_description_new(_inst)
{
    switch (_inst.card_id)
    {
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
        case 17: return "移动，获得3点护甲。若你本回合使用过【风刃】，抽一张牌";
        case 18: return "选择一张初始牌并将其置入你的手牌";
        case 19: return "对敌方角色造成" + string(card_current_damage(_inst)) + "点伤害。若击杀目标则将一张0费的【火球】置入手牌";
        case 21: return "抽一张牌，获得1点临时魔力。若你本回合使用过两种不同的初始牌，获得1点费用";
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
        case 41: return "消耗，将本角色的所有初始牌各一张置入你的手牌，将其变为0费。然后回复5点体力值";
        case 40: return "消耗。令你手牌、抽牌堆、弃牌堆中的所有苏灵兮初始牌各进行一次合成强化";
        case 42: return "所有友方角色获得倒计时1：若本角色上回合没有使用过攻击牌，获得10点护甲";
        case 43: return "在本局对战剩余时间内，每回合当本角色第一次从手牌中打出初始牌时，倒计时1：视为使用该初始牌";
        case 45: return "将你手牌、抽牌堆和弃牌堆中的所有【火球】合成为一张，然后使用并消耗";
        case 46: return "消耗。选择手牌中的一张初始牌，将其消耗。倒计时2：将一张其合成强化后的置入手牌";
        case 44: return "将十张【风刃】置入你的手牌。每回合开始时，将一张【风刃】置入你的手牌";
    }

    return "";
}

// ---------- 战斗奖励的卡池 ----------

// 某个稀有度的奖励卡牌编号：队伍里每个角色的编号段里，稀有度匹配、对象已经做好的牌
function reward_pool(_rarity)
{
    var ids = [];

    for (var p = 0; p < array_length(global.party); p++)
    {
        var card_range = character_get_card_range(character_get_num(global.party[p]));

        if (array_length(card_range) == 0) continue;

        for (var cn = card_range[0]; cn <= card_range[1]; cn++)
        {
            if (card_rarity(cn) == _rarity && card_get_object(cn) != -1)
            {
                ids[array_length(ids)] = cn;
            }
        }
    }

    return ids;
}

// 随机 _n 张奖励卡牌的编号：普通 60% / 稀有 30% / 传说 10%，同一次不重复
function reward_roll_cards(_n)
{
    var result = [];
    var guard = 0;

    while (array_length(result) < _n && guard < 100)
    {
        guard++;

        var r = irandom(99);
        var rar = (r < 60) ? Rarity.COMMON : ((r < 90) ? Rarity.RARE : Rarity.LEGENDARY);
        var pool = reward_pool(rar);

        // 这个稀有度没有可选的牌：降一档再找
        while (array_length(pool) == 0 && rar > Rarity.COMMON)
        {
            rar--;
            pool = reward_pool(rar);
        }

        if (array_length(pool) == 0) continue;

        var pick = pool[irandom(array_length(pool) - 1)];
        var dup = false;

        for (var i = 0; i < array_length(result); i++)
        {
            if (result[i] == pick) dup = true;
        }

        if (!dup) result[array_length(result)] = pick;
    }

    return result;
}