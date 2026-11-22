/// scr_monster
/// 怪物数据、行动、意图显示、遭遇

enum MonsterId
{
    STONE,      // 守墓石像
    FIREFLY,    // 墓穴萤火
    ROBBER,     // 墓穴盗尸者
    CURSER,     // 墓穴诅咒者
    INK_BIRD,   // 墨灵·鸟
    INK_PIG,    // 墨灵·猪
    INK_FISH,   // 墨灵·鱼
    INK_WOLF,   // 墨灵·狼
    INK_FROG    // 墨灵·蛙
}

// 意图图标类型
enum IntentIcon
{
    NONE,
    PHYS,
    MAGIC,
    PHYS_AOE,
    MAGIC_AOE,
    DEBUFF,
    BUFF
}

// 一个行动由若干部分组成
enum ActKind
{
    ATTACK,         // 攻击
    GAIN_STATUS,    // 自己获得状态（力量、魔力……）
    GAIN_ARMOR,     // 自己获得护甲
    HEAL_ALLY,      // 为一名队友恢复生命
    LOSE_HP_SELF,   // 自己失去生命
    CURSE,          // 把诅咒牌置入你的弃牌堆
    COST_UP         // 令你下回合使用的第一张牌费用 +N
}

// ---------- 基础数据 ----------

function intent_sprite(_icon)
{
    switch (_icon)
    {
        case IntentIcon.PHYS:      return spr_intent_phys;
        case IntentIcon.MAGIC:     return spr_intent_magic;
        case IntentIcon.PHYS_AOE:  return spr_intent_phys_aoe;
        case IntentIcon.MAGIC_AOE: return spr_intent_magic_aoe;
        case IntentIcon.DEBUFF:    return spr_intent_debuff;
        case IntentIcon.BUFF:      return spr_intent_buff;
    }

    return -1;
}

function monster_name(_id)
{
    switch (_id)
    {
        case MonsterId.STONE:    return "守墓石像";
        case MonsterId.FIREFLY:  return "墓穴萤火";
        case MonsterId.ROBBER:   return "墓穴盗尸者";
        case MonsterId.CURSER:   return "墓穴诅咒者";
        case MonsterId.INK_BIRD: return "墨灵·鸟";
        case MonsterId.INK_PIG:  return "墨灵·猪";
        case MonsterId.INK_FISH: return "墨灵·鱼";
        case MonsterId.INK_WOLF: return "墨灵·狼";
        case MonsterId.INK_FROG: return "墨灵·蛙";
    }

    return "";
}

function monster_sprite(_id)
{
    switch (_id)
    {
        case MonsterId.STONE:    return spr_monster_stone;
        case MonsterId.FIREFLY:  return spr_monster_firefly;
        case MonsterId.ROBBER:   return spr_monster_robber;
        case MonsterId.CURSER:   return spr_monster_curser;
        case MonsterId.INK_BIRD: return spr_ink_bird;
        case MonsterId.INK_PIG:  return spr_ink_pig;
        case MonsterId.INK_FISH: return spr_ink_fish;
        case MonsterId.INK_WOLF: return spr_ink_wolf;
        case MonsterId.INK_FROG: return spr_ink_frog;
    }

    return -1;
}

function monster_max_hp(_id)
{
    switch (_id)
    {
        case MonsterId.STONE:    return 40;
        case MonsterId.FIREFLY:  return 24;
        case MonsterId.ROBBER:   return 32;
        case MonsterId.CURSER:   return 29;
        case MonsterId.INK_BIRD: return 25;
        case MonsterId.INK_PIG:  return 35;
        case MonsterId.INK_FISH: return 30;
        case MonsterId.INK_WOLF: return 28;
        case MonsterId.INK_FROG: return 32;
    }

    return 20;
}

// ---------- 行动循环 ----------

// 什么也不做
function act_idle()
{
    return { icon: IntentIcon.NONE, text: "什么也不做", parts: [] };
}

// 攻击前排角色：_dmg 点 _dtype 伤害，打 _times 次
function act_attack(_dmg, _dtype, _times, _text)
{
    return {
        icon: (_dtype == DamageType.PHYSICAL) ? IntentIcon.PHYS : IntentIcon.MAGIC,
        text: _text,
        parts: [ { kind: ActKind.ATTACK, dmg: _dmg, dtype: _dtype, times: _times, target: "front" } ]
    };
}

// 自己获得状态
function act_buff_status(_status, _amount, _text)
{
    return {
        icon: IntentIcon.BUFF,
        text: _text,
        parts: [ { kind: ActKind.GAIN_STATUS, status: _status, amount: _amount } ]
    };
}

// 每个怪物的行动循环（想改行动，只改这里）
function monster_cycle(_id)
{
    switch (_id)
    {
        // 守墓石像：四轮循环
        case MonsterId.STONE:
            return [
                act_idle(),
                act_attack(7,  DamageType.PHYSICAL, 1, "造成7点物理伤害"),
                act_attack(12, DamageType.PHYSICAL, 1, "造成12点物理伤害"),
                act_attack(18, DamageType.PHYSICAL, 1, "造成18点物理伤害")
            ];

        // 墓穴萤火：二轮循环
        case MonsterId.FIREFLY:
            return [
                act_attack(4, DamageType.MAGIC, 1, "造成4点魔法伤害"),
                act_buff_status(StatusType.MAGIC_POWER, 2, "获得2点魔力")
            ];

        // 墓穴盗尸者：二轮循环
        case MonsterId.ROBBER:
            return [
                act_attack(9, DamageType.PHYSICAL, 1, "造成9点物理伤害"),
                act_buff_status(StatusType.STRENGTH, 2, "获得1点力量")
            ];

        // 墓穴诅咒者：三轮循环
        case MonsterId.CURSER:
            return [
                
                {
                    icon: IntentIcon.DEBUFF,
                    text: "将两张【贪婪诅咒】置入你的弃牌堆",
                    parts: [ { kind: ActKind.CURSE, card: obj_card_greed, count: 2 } ]
                },
				act_attack(7, DamageType.MAGIC, 1, "造成7点魔法伤害"),
                act_attack(3, DamageType.MAGIC, 3, "造成3次3点魔法伤害")
            ];

        // 墨灵·鸟：三轮循环
        case MonsterId.INK_BIRD:
            return [
                act_attack(2, DamageType.PHYSICAL, 3, "造成3次2点物理伤害"),
                {
                    icon: IntentIcon.BUFF,
                    text: "获得5点护甲和1点力量",
                    parts: [
                        { kind: ActKind.GAIN_ARMOR,  armor: ArmorType.GENERAL, amount: 5 },
                        { kind: ActKind.GAIN_STATUS, status: StatusType.STRENGTH, amount: 1 }
                    ]
                },
                act_attack(7, DamageType.PHYSICAL, 1, "造成7点物理伤害")
            ];

        // 墨灵·猪：二轮循环
        case MonsterId.INK_PIG:
            return [
                act_buff_status(StatusType.STRENGTH, 1, "获得1点力量"),
                {
                    icon: IntentIcon.PHYS,
                    text: "造成14点物理伤害，然后失去5点生命",
                    parts: [
                        { kind: ActKind.ATTACK, dmg: 14, dtype: DamageType.PHYSICAL, times: 1, target: "front" },
                        { kind: ActKind.LOSE_HP_SELF, amount: 5 }
                    ]
                }
            ];

        // 墨灵·鱼：三轮循环
        case MonsterId.INK_FISH:
            return [
                act_attack(6, DamageType.MAGIC, 1, "造成6点魔法伤害"),
                {
                    icon: IntentIcon.BUFF,
                    text: "为一名队友恢复8点生命",
                    parts: [ { kind: ActKind.HEAL_ALLY, amount: 8 } ]
                },
                {
                    icon: IntentIcon.MAGIC,
                    text: "对我方生命最低的角色造成4点魔法伤害",
                    parts: [ { kind: ActKind.ATTACK, dmg: 4, dtype: DamageType.MAGIC, times: 1, target: "lowest" } ]
                }
            ];

        // 墨灵·狼：三轮循环
        case MonsterId.INK_WOLF:
            return [
                act_attack(6, DamageType.PHYSICAL, 1, "造成6点物理伤害"),
                act_buff_status(StatusType.STRENGTH, 1, "获得1点力量"),
                act_attack(10, DamageType.PHYSICAL, 1, "造成10点物理伤害")
            ];

        // 墨灵·蛙：三轮循环
        case MonsterId.INK_FROG:
            return [
                act_attack(5, DamageType.MAGIC, 1, "造成5点魔法伤害"),
                {
                    icon: IntentIcon.BUFF,
                    text: "获得6点魔法护甲和2点魔力",
                    parts: [
                        { kind: ActKind.GAIN_ARMOR,  armor: ArmorType.MAGIC, amount: 6 },
                        { kind: ActKind.GAIN_STATUS, status: StatusType.MAGIC_POWER, amount: 2 }
                    ]
                },
                {
                    icon: IntentIcon.DEBUFF,
                    text: "令你下回合使用的第一张牌费用+1",
                    parts: [ { kind: ActKind.COST_UP, amount: 1 } ]
                }
            ];
    }

    return [ act_idle() ];
}

// ---------- 生成怪物 ----------

// 把一个敌人实例配置成某种怪物
function monster_setup(_e, _id)
{
    _e.monster_id = _id;
    _e.sprite_index = monster_sprite(_id);
    _e.max_hp = monster_max_hp(_id);
    _e.hp = _e.max_hp;
    _e.cycle = monster_cycle(_id);
    _e.cycle_i = 0;

    _e.armor_general = 0;
    _e.armor_physical = 0;
    _e.armor_magic = 0;

    _e.ink_pending = false;
    _e.has_acted = false;

    // 初始自带
    switch (_id)
    {
        case MonsterId.ROBBER:
            add_status(_e, StatusType.CORPSE_THIEF, 1);
            break;

        case MonsterId.INK_BIRD:
        case MonsterId.INK_PIG:
        case MonsterId.INK_FISH:
        case MonsterId.INK_WOLF:
        case MonsterId.INK_FROG:
            add_status(_e, StatusType.INK, 1);
            break;
    }
}

// ---------- 行动的执行 ----------

// 攻击的实际每次伤害：基础 + 力量（物理）/ 魔力（魔法）- 力量下降 / 魔力下降，最低为 0
function monster_attack_damage(_e, _p)
{
    var d = _p.dmg;

    if (_p.dtype == DamageType.PHYSICAL)
    {
        d += get_status(_e, StatusType.STRENGTH) - get_status(_e, StatusType.STRENGTH_DOWN);
    }
    else
    {
        d += get_status(_e, StatusType.MAGIC_POWER) - get_status(_e, StatusType.MAGIC_DOWN);
    }

    return max(d, 0);
}

// 我方存活角色里生命最低的
function party_lowest_hp_char()
{
    var best = noone;

    for (var n = 1; n <= 4; n++)
    {
        var c = variable_instance_get(obj_hand_controller, "char_" + string(n));

        if (!char_is_alive(c)) continue;

        if (best == noone || c.hp < best.hp)
        {
            best = c;
        }
    }

    return best;
}

// 恢复生命的队友：其他敌人里生命比例最低的；只剩自己就恢复自己
function monster_pick_heal_target(_e)
{
    var best = noone;
    var list = obj_hand_controller.enemies;

    for (var i = 0; i < array_length(list); i++)
    {
        var o = list[i];

        if (o == _e || !instance_exists(o)) continue;

        if (best == noone || (o.hp / o.max_hp) < (best.hp / best.max_hp))
        {
            best = o;
        }
    }

    return (best != noone) ? best : _e;
}

// 还有没行动的敌人吗（敌人回合用）
function enemies_any_pending()
{
    var list = obj_hand_controller.enemies;

    for (var i = 0; i < array_length(list); i++)
    {
        if (instance_exists(list[i]) && !list[i].has_acted) return true;
    }

    return false;
}

// 执行当前行动的所有部分
function monster_execute_action(_e)
{
    var act = _e.cycle[_e.cycle_i];

    for (var k = 0; k < array_length(act.parts); k++)
    {
        var p = act.parts[k];

        switch (p.kind)
        {
            case ActKind.ATTACK:
            {
                var dmg = monster_attack_damage(_e, p);
                var target = (p.target == "lowest") ? party_lowest_hp_char() : obj_hand_controller.front_char;

                if (target != noone)
                {
                    for (var h = 0; h < p.times; h++)
                    {
                        if (h == 0)
                        {
                            deal_damage(target, dmg, p.dtype);
                        }
                        else
                        {
                            // 连续攻击：每一下隔 15 帧，飘字不会重叠
                            var pe = {
                                timer: h * 15,
                                effect: { type: EffectType.DAMAGE, dtype: p.dtype },
                                value: dmg,
                                target: noone,
                                enemy: target
                            };

                            with (obj_hand_controller)
                            {
                                array_push(pending_effects, pe);
                            }
                        }
                    }
                }
            }
            break;

            case ActKind.GAIN_STATUS:
                add_status(_e, p.status, p.amount);
                break;

            case ActKind.GAIN_ARMOR:
                add_armor(_e, p.armor, p.amount);
                break;

            case ActKind.HEAL_ALLY:
                heal_hp(monster_pick_heal_target(_e), p.amount);
                break;

            case ActKind.LOSE_HP_SELF:
                lose_hp(_e, p.amount);
                break;

            case ActKind.CURSE:
            {
                with (obj_hand_controller)
                {
                    repeat (p.count)
                    {
                        discard_pile[array_length(discard_pile)] = card_make_entry(p.card);
                    }
                }
            }
            break;

            case ActKind.COST_UP:
            {
                with (obj_hand_controller)
                {
                    pending_cost_up += p.amount;
                }
            }
            break;
        }

        // 行动过程中自己死了（比如墨灵·猪失去生命），后面的部分不用再执行
        if (!instance_exists(_e)) return;
    }
}

// 回合开始：护甲清零，墨化触发
function monster_turn_start(_e)
{
    _e.armor_general = 0;
    _e.armor_physical = 0;
    _e.armor_magic = 0;

    // 墨化：首次低于 10 血后，在下一个回合开始时获得 5 点护甲
    if (_e.ink_pending)
    {
        _e.ink_pending = false;
        clear_status(_e, StatusType.INK);
        add_armor(_e, ArmorType.GENERAL, 5);
    }
}

// 受到伤害后检查：墨化（首次低于 10 血）
function monster_on_damaged(_e)
{
    // 角色没有这个变量，直接跳过
    if (!variable_instance_exists(_e, "ink_pending")) return;
    if (_e.hp <= 0) return;

    if (get_status(_e, StatusType.INK) > 0 && _e.hp < 10 && !_e.ink_pending)
    {
        _e.ink_pending = true;
    }
}

// 一个怪物的完整回合
function monster_take_turn(_e)
{
    _e.has_acted = true;

    // 回合开始：护甲清零，墨化触发
    monster_turn_start(_e);

    // 冻结 / 寒冷
    var frozen_skip = status_turn_start(_e);

    if (!frozen_skip)
    {
        monster_execute_action(_e);

        // 行动完前进到下一个行动（中途死亡的不用）
        if (instance_exists(_e))
        {
            _e.cycle_i = (_e.cycle_i + 1) mod array_length(_e.cycle);
        }
    }

    // 力量 / 魔力下降只影响"下回合"：这次行动结束后移除
    if (instance_exists(_e))
    {
        clear_status(_e, StatusType.STRENGTH_DOWN);
        clear_status(_e, StatusType.MAGIC_DOWN);
    }
}

// ---------- 意图显示 ----------

// 意图图标的位置：怪物头顶 [中心x, 中心y, 大小]
function monster_intent_rect(_e)
{
    var size = 40;

    return [_e.x, _e.bbox_top - size * 0.5 - 8, size];
}

// 意图图标旁边的数字（攻击才有；多段攻击显示 "每次伤害×次数"）
function monster_intent_number_text(_e, _act)
{
    for (var k = 0; k < array_length(_act.parts); k++)
    {
        var p = _act.parts[k];

        if (p.kind == ActKind.ATTACK)
        {
            var d = monster_attack_damage(_e, p);

            return (p.times > 1) ? (string(d) + "×" + string(p.times)) : string(d);
        }
    }

    return "";
}

// 意图的详细说明（鼠标放上去时显示）
function monster_intent_detail(_e, _act)
{
    var s = monster_name(_e.monster_id) + "的下一个行动：\n" + _act.text;

    // 攻击：补充当前实际伤害（含力量、魔力等加成）
    for (var k = 0; k < array_length(_act.parts); k++)
    {
        var p = _act.parts[k];

        if (p.kind == ActKind.ATTACK)
        {
            s += "\n（当前实际伤害：" + string(monster_attack_damage(_e, p));

            if (p.times > 1)
            {
                s += "×" + string(p.times);
            }

            s += "）";
            break;
        }
    }

    return s;
}

// 在怪物头顶画意图：图标 + 数字
function draw_monster_intent(_e)
{
    if (!variable_instance_exists(_e, "cycle")) return;
    if (array_length(_e.cycle) == 0) return;

    draw_set_font(global.chinese_font);

    var act = _e.cycle[_e.cycle_i];
    var r = monster_intent_rect(_e);
    var spr = intent_sprite(act.icon);

    if (spr != -1)
    {
        draw_node_sprite(spr, r[0], r[1], r[2], 1);
    }

    var num = monster_intent_number_text(_e, act);

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    if (num != "")
    {
        draw_set_color(c_black);
        draw_text_transformed(r[0] + r[2] * 0.5 + 6, r[1] + 1, num, 1, 1, 0);

        draw_set_color(c_white);
        draw_text_transformed(r[0] + r[2] * 0.5 + 5, r[1], num, 1, 1, 0);
    }
    else if (spr == -1)
    {
        // 空过：没有图标，显示省略号
        draw_set_color(c_white);
        draw_text(r[0] - 6, r[1], "…");
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// 鼠标放在意图上时，在上方显示详细说明（在控制器的 Draw GUI 里调用）
function draw_monster_tooltip(_e, _mx, _my)
{
    if (!variable_instance_exists(_e, "cycle")) return;
    if (array_length(_e.cycle) == 0) return;

    var r = monster_intent_rect(_e);

    // 鼠标要在意图图标（含右边的数字）范围内
    if (_mx < r[0] - r[2] * 0.5 || _mx > r[0] + r[2] * 0.5 + 70) return;
    if (_my < r[1] - r[2] * 0.5 || _my > r[1] + r[2] * 0.5) return;

    var act = _e.cycle[_e.cycle_i];

    draw_set_font(global.chinese_font);

    var sc = 0.8;
    var txt = wrap_text_pixels(monster_intent_detail(_e, act), 280 / sc);
    var tw = string_width(txt) * sc;
    var th = string_height(txt) * sc;
    var pad = 12;

    var bx1 = clamp(r[0] - tw * 0.5 - pad, 6, max(room_width - tw - pad * 2 - 6, 6));
    var bx2 = bx1 + tw + pad * 2;
    var by2 = r[1] - r[2] * 0.5 - 10;
    var by1 = by2 - th - pad * 2;

    draw_set_color(make_color_rgb(20, 24, 38));
    draw_rectangle(bx1, by1, bx2, by2, false);

    draw_set_color(make_color_rgb(150, 160, 195));
    draw_rectangle(bx1, by1, bx2, by2, true);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text_transformed(bx1 + pad, by1 + pad, txt, sc, sc, 0);
}

// ---------- 遭遇（点普通战斗时随机触发其中一种）----------

// _battle_index：这是第几次触发普通战斗（从 0 开始）。前两次是弱怪区，之后是强怪区
// 返回 { start: 开局的怪物, reinf: 增援 [ {round: 第几回合入场, id: 怪物} ] }
function encounter_generate(_battle_index)
{
    var ink_ids = array_shuffle([
        MonsterId.INK_BIRD, MonsterId.INK_PIG, MonsterId.INK_FISH,
        MonsterId.INK_WOLF, MonsterId.INK_FROG
    ]);

    var enc = { start: [], reinf: [] };
    var r = irandom(2);

    if (_battle_index < 2)
    {
        // 弱怪区
        if (r == 0)
        {
            enc.start = [MonsterId.STONE];                          // 类型一：1 个守墓石像
        }
        else if (r == 1)
        {
            enc.start = [MonsterId.FIREFLY, MonsterId.FIREFLY];     // 类型二：2 个墓穴萤火
        }
        else
        {
            enc.start = [ink_ids[0]];                               // 类型三：随机一种墨灵
        }
    }
    else
    {
        // 强怪区
        if (r == 0)
        {
            // 类型四：墓穴盗尸者，第 2、3 回合各进入一个墓穴萤火
            enc.start = [MonsterId.ROBBER];
            enc.reinf = [
                { round: 2, id: MonsterId.FIREFLY },
                { round: 3, id: MonsterId.FIREFLY }
            ];
        }
        else if (r == 1)
        {
            enc.start = [ink_ids[0], ink_ids[1]];                   // 类型五：随机两种墨灵
        }
        else
        {
            enc.start = [MonsterId.ROBBER, MonsterId.CURSER];       // 类型六：盗尸者 + 诅咒者
        }
    }

    return enc;
}