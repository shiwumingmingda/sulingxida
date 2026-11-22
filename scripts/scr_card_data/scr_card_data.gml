/// scr_card_data
/// 所有卡牌的分类、费用、效果都在这里统一管理

enum CardType
{
    ATTACK,   // 攻击牌：打出后让角色进入前场
    SKILL,    // 技能牌
    STATUS    // 状态牌：打出后不进弃牌堆
}

// 效果类型
enum EffectType
{
    DAMAGE,          // 对前场敌人造成伤害
    ARMOR,           // 给指定角色增加护甲
    STARLIGHT,       // 给角色2增加星光
    DAMAGE_OTHERS,   // 对前场以外的所有敌人造成伤害
    DRAW,            // 抽牌
    NEXT_ENERGY,     // 下回合额外获得费用
    STATUS,           // 给前场敌人施加状态（寒冷等）
	UNLOCK_DISCOVER,   // 解锁：之后发现时可以出现 46 号牌
	ADD_TO_HAND,         // 把一张牌置入手牌
	DISCARD_FROM_HAND,   // 弃置手牌里所有某编号的牌
	LOSE_HP,             // 失去生命
	HEAL,                 // 回复生命
	BRING_TO_FRONT,
	GAIN_ENERGY,         // 获得费用
	COUNTDOWN,           // 倒计时：N 个我方回合后触发一组效果
	COUNTDOWN_SHIFT,     // 令某角色所有倒计时 -N
	MOVE_TO_BACK,        // 移动至后场
	DISCOVER_OWN,        // 发现一张本角色的牌
	DISCOVER_LIST,       // 从指定的几张牌里发现
	DRAW_CARD_ID,        // 从抽牌堆抽取指定编号的牌
	RETAIN_HAND,         // 令手牌里所有的牌保留一回合
	CONSUME_FROM_HAND,   // 消耗手牌里一张指定编号的牌
	BUFF_HAND_DAMAGE,    // 令手牌里指定编号的牌伤害 +N
	DAMAGE_ARMOR_TOTAL,  // 造成等同于护甲总和的伤害
	SHUFFLE_ELEMENT,     // 随机一张元素牌（1~4）洗入抽牌堆
    ROTATE_SELF,         // 角色在前场和后场之间轮换
    DRAW_IF_PLAYED,      // 本回合打出过指定牌时抽牌
    SELECT_HAND,         // 打开通用手牌选择界面
    ADD_ENTRY_TO_HAND,   // 将保存的强化卡牌记录加入手牌
    FIREBALL_VOLLEY,     // 生成并依次使用多张火球
    RANDOM_STARTER,      // 随机视为使用一张初始牌并复制
    UPGRADE_ALL_STARTERS,// 强化所有区域里的苏灵兮初始牌
    COUNTDOWN_ALL_FRIENDS,// 给所有友方角色添加倒计时
    MERGE_ALL_FIREBALLS, // 消耗所有火球并合成后使用
    REPLAY_STARTER       // 倒计时后视为再次使用一张初始牌
}

// 卡牌分类
function card_get_type(_id)
{
    // 新卡牌（scr_card_new）里写了类型的，直接用
    var info = card_info(_id);
    if (!is_undefined(info)) return info.type;

    // 攻击牌：1~3、101~104、201~206、241~246、301
    if ((_id >= 1 && _id <= 3) || (_id >= 101 && _id <= 104)
    ||  (_id >= 201 && _id <= 206) || (_id >= 241 && _id <= 246) || _id == 301)
    {
        return CardType.ATTACK;
    }

    // 技能牌：4~6、105~107、207~208、302~304
    if ((_id >= 4 && _id <= 6) || (_id >= 105 && _id <= 107)
    ||  (_id >= 207 && _id <= 208) || (_id >= 302 && _id <= 304))
    {
        return CardType.SKILL;
    }

    // 其余是状态牌
    return CardType.STATUS;
}

// 卡牌费用
function card_get_cost(_id)
{
    // 风刃（2号牌）固定为0费，必须放在 card_info 查询之前
    if (_id == 2) return 0;

    var info = card_info(_id);
    if (!is_undefined(info)) return info.cost;

    // 2 费：7~10、102、105、210
    if ((_id >= 7 && _id <= 10) || _id == 102 || _id == 105 || _id == 210) return 2;

    // 1 费：1~3、101、103、104、201~206、208、301、302、304
    if ((_id >= 1 && _id <= 3) || _id == 101 || _id == 103 || _id == 104
    ||  (_id >= 201 && _id <= 206) || _id == 208
    ||  _id == 301 || _id == 302 || _id == 304)
    {
        return 1;
    }

    return 0;
}

// 这张牌属于哪个角色（0 = 通用）

// 攻击牌属于哪个角色（0 = 不属于任何角色）
function card_get_character(_id)
{
    if (_id == 243) return 0;                 // 243：不会进入前场
    if (_id >= 1   && _id <= 100) return 1;
    if (_id >= 101 && _id <= 200) return 2;
    if (_id >= 201 && _id <= 300) return 3;

    return 0;
}
// 效果作用的我方角色：写了 on_char 就是那个编号的角色，否则用默认的
function effect_target_char(_e, _default)
{
    if (variable_struct_exists(_e, "on_char"))
    {
        return variable_instance_get(obj_hand_controller, "char_" + string(_e.on_char));
    }

    return _default;
}
// 选了某个角色，就把哪些编号的牌加入牌库
// 返回 [起始编号, 结束编号]；返回 [] 表示不加入任何牌

function character_get_card_range(_num)
{
    switch (_num)
    {
        case 1: return [1, 100];
        case 2: return [101, 200];
        case 3: return [201, 300];
    }

    return [];
}


// 每张牌的效果列表（想改数值或加效果，只改这里）
function card_get_effects(_id)
{
    switch (_id)
    {
		// 1号牌：对前场敌人造成 6 点法术伤害，对其他敌人造成 3 点法术伤害
		case 1:
			return [
			{ type: EffectType.DAMAGE,        amount: 6, dtype: DamageType.MAGIC },
			{ type: EffectType.DAMAGE_OTHERS, amount: 3, dtype: DamageType.MAGIC }
    ];

// 2号牌：先造成 2 点法术伤害，隔一会儿再造成 2 点物理伤害
		case 2:
			return [
			{ type: EffectType.DAMAGE, amount: 2, dtype: DamageType.MAGIC },
			{ type: EffectType.DAMAGE, amount: 2, dtype: DamageType.PHYSICAL, delay: 20 }
    ];
// 3号牌：造成 6 点法术伤害，令敌人获得 1 层寒冷
		case 3:
			return [
			{ type: EffectType.DAMAGE, amount: 6, dtype: DamageType.MAGIC },
			{ type: EffectType.STATUS, status: StatusType.CHILL, amount: 1 }
    ];
		// 4号牌：+5 通用护甲、+4 物理护甲
        case 4:
            return [
            { type: EffectType.ARMOR, armor: ArmorType.GENERAL,  amount: 5 },
            { type: EffectType.ARMOR, armor: ArmorType.PHYSICAL, amount: 4 }
            ];
// 5号牌：抽 3 张牌，下回合额外获得 1 费
		case 5:
			 return [
			{ type: EffectType.DRAW,        amount: 3 },
			{ type: EffectType.NEXT_ENERGY, amount: 1 }
    ];
        
// 7号牌：状态牌，让角色1获得元素共鸣
		case 7:
			return [
			{ type: EffectType.STATUS, status: StatusType.RESONANCE, amount: 1, on_char: 1 }
    ];

       // 11号牌：造成 8 点法术伤害
		case 101:
			return [
				 { type: EffectType.DAMAGE, amount: 8, dtype: DamageType.MAGIC }
    ];
			
			// 12号牌：造成物理伤害，获得 1 点星光
			case 102:
				return [
					{ type: EffectType.DAMAGE,    amount: 6, dtype: DamageType.PHYSICAL },
				 { type: EffectType.STARLIGHT, amount: 1 }
				];

        // 15号牌：获得 2 点星光
        case 105:
            return [
                { type: EffectType.STARLIGHT, amount: 2 }
            ];
			// 21 击：剑招，造成 6 点物理伤害
		case 201:
			return [
				{ type: EffectType.DAMAGE, amount: 6, dtype: DamageType.PHYSICAL }
    ];

// 22 刺：剑招，追猎，造成 4 点物理伤害
		case 202:
			return [
				{ type: EffectType.DAMAGE, amount: 4, dtype: DamageType.PHYSICAL }
    ];

// 23 格：剑招，获得 5 点护甲
		case 203:
			return [
				{ type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 5 }
    ];

// 24 洗：剑招，造成 3 点物理伤害，令敌方下回合失去等量的力量
		case 204:
			return [
			{ type: EffectType.DAMAGE, amount: 3, dtype: DamageType.PHYSICAL },
			{ type: EffectType.STATUS, status: StatusType.STRENGTH_DOWN, amount: 0, equal_damage: true }
    ];

// 25 业随影生：造成 10 点魔法伤害，将一张【猩红】置入手牌
		case 205:
			return [
				{ type: EffectType.DAMAGE,      amount: 10, dtype: DamageType.MAGIC },
				{ type: EffectType.ADD_TO_HAND, amount: 1, obj: obj_card_scarlet }
    ];

// 26 断业：造成 5 点物理伤害，弃置手中所有的【猩红】
		case 206:
			return [
				{ type: EffectType.DAMAGE,            amount: 5, dtype: DamageType.PHYSICAL },
				{ type: EffectType.DISCARD_FROM_HAND, amount: 1, card_id: 51 }
    ];

// 27 引血：失去 3 点生命，获得 3 层血色
		case 207:
			return [
			{ type: EffectType.LOSE_HP, amount: 3, on_char: 3 },
			{ type: EffectType.STATUS,  status: StatusType.BLOOD, amount: 3, on_char: 3 }
    ];

// 28 练心：获得 1 点力量和 1 点敏捷，回复 1 点生命
		case 208:
			return [
			{ type: EffectType.STATUS, status: StatusType.STRENGTH,  amount: 1, on_char: 3 },
			{ type: EffectType.STATUS, status: StatusType.DEXTERITY, amount: 1, on_char: 3 },
			{ type: EffectType.HEAL,   amount: 1, on_char: 3 }
    ];
	// 29号牌：状态牌，本场战斗剩余时间内，发现时可以出现 46 号牌
		case 209:
			return [
			{ type: EffectType.UNLOCK_DISCOVER, amount: 1 }
			
			
    ];
// 30 精进：每回合开始，往手牌里放一张 0 费的练心
		case 210:
			return [
		    { type: EffectType.STATUS, status: StatusType.DILIGENCE, amount: 1, on_char: 3 }
    ];
			
		
			// 41号牌：8 点物理伤害，获得 8 点护甲，令目标下回合力量和魔力 -6
		case 241:
			return [
			{ type: EffectType.DAMAGE, amount: 8, dtype: DamageType.PHYSICAL },
			{ type: EffectType.ARMOR,  armor: ArmorType.GENERAL, amount: 8 },
			{ type: EffectType.STATUS, status: StatusType.STRENGTH_DOWN, amount: 6 },
			{ type: EffectType.STATUS, status: StatusType.MAGIC_DOWN,    amount: 6 }
    ];
// 31 打击：令一名友方角色造成 6 点物理伤害
		case 301:
			return [
			{ type: EffectType.DAMAGE, amount: 6, dtype: DamageType.PHYSICAL }
    ];

// 32 防御：令一名友方角色获得 5 点护甲
		case 302:
			return [
			{ type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 5 }
    ];

// 33 动员：令一名友方角色进入前场
		case 303:
			return [
			{ type: EffectType.BRING_TO_FRONT, amount: 1 }
    ];

// 34 智慧：抽两张牌
		case 304:
			return [
			 { type: EffectType.DRAW, amount: 2 }
    ];
// 42号牌：对所有敌人造成 8 点物理伤害（前场一个 + 其他敌人）
		case 242:
			return [
			{ type: EffectType.DAMAGE,        amount: 8, dtype: DamageType.PHYSICAL },
			{ type: EffectType.DAMAGE_OTHERS, amount: 8, dtype: DamageType.PHYSICAL }
    ];

// 43号牌：指向一个敌人，造成 12 点物理伤害
		case 243:
			return [
				{ type: EffectType.DAMAGE, amount: 12, dtype: DamageType.PHYSICAL }
    ];
	// 44号牌：造成 6 点物理伤害，重复 3 次
		case 244:
			return [
			{ type: EffectType.DAMAGE, amount: 6, dtype: DamageType.PHYSICAL, times: 3 }
    ];

// 45号牌：获得 2 点力量和敏捷，本场战斗剩余时间内，剑招伤害 +3
		case 245:
			return [
			{ type: EffectType.STATUS, status: StatusType.STRENGTH,   amount: 2, on_char: 3 },
			{ type: EffectType.STATUS, status: StatusType.DEXTERITY,  amount: 2, on_char: 3 },
			{ type: EffectType.STATUS, status: StatusType.SWORD_FORM, amount: 3, on_char: 3 }
    ];

// 46号牌：造成 50 点物理伤害
		case 246:
			return [
			{ type: EffectType.DAMAGE, amount: 50, dtype: DamageType.PHYSICAL }
    ];	
    }

    // 没有写效果的牌，效果为空
    return [];
}

// 读取这张牌"当前"的效果列表（优先用牌自己的，没有就查表）
function card_current_effects(_inst)
{
    // 合成、强化或其他效果修改过的卡牌，优先读取实例自身保存的效果
    if (variable_instance_exists(_inst, "effects")) return _inst.effects;

    // 新卡优先读取 scr_card_new 中的数据
    var new_effects = card_get_effects_new(_inst.card_id);

    if (array_length(new_effects) > 0)
    {
        return new_effects;
    }

    // 没有新卡效果数据时，继续使用旧卡牌效果表
    return card_get_effects(_inst.card_id);
}

// 计算一个效果实际生效的数值（在这里统一加上各种加成）
function card_effect_value(_effect)
{
    var v = _effect.amount;

    // 护甲加成：之后"提高获得护甲值"的效果改 global.armor_bonus
    if (_effect.type == EffectType.ARMOR)
{
    // 全局加成可能还没初始化（比如在地图房间里查看卡牌时）
    if (variable_global_exists("armor_bonus"))
    {
        v += global.armor_bonus;
    }
}

    return max(v, 0);
}
// 这张牌的拥有者角色的实例（没有就返回 noone）
function card_get_owner_instance(_id)
{
    var owner_num = card_get_owner(_id);
    if (owner_num <= 0) return noone;
    if (!instance_exists(obj_hand_controller)) return noone;
    return variable_instance_get(obj_hand_controller, "char_" + string(owner_num));
}

function card_get_owner(_id)
{
    if (_id >= 1   && _id <= 100) return 1;   // 苏灵兮
    if (_id >= 101 && _id <= 200) return 2;   // 尘
    if (_id >= 201 && _id <= 300) return 3;   // 心羽
    if (_id == 401) return 3;                 // 猩红

    return 0;                                 // 通用牌、其他异常牌
}

// 一个效果的最终数值：基础数值 + 全局加成 + 力量 / 敏捷 / 剑招
// _inst：这张牌；_receiver：接收护甲的角色（显示卡面数字时传 noone，按牌的拥有者算）
function card_effect_final(_e, _inst, _receiver)
{
    var v = card_effect_value(_e);
    var owner = card_get_owner_instance(_inst.card_id);
	// 通用牌没有拥有者：用被指定的友方角色作为出手 / 受益的角色（吃他的力量、敏捷）
if (owner == noone) owner = _receiver;

    switch (_e.type)
    {
        case EffectType.DAMAGE:
        case EffectType.DAMAGE_OTHERS:
        {
            var dt = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.PHYSICAL;

            // 力量：物理伤害 +1/层
            // 力量：物理伤害 +1/层；魔力和临时魔力：魔法伤害 +1/层
if (dt == DamageType.PHYSICAL)
{
    v += get_status(owner, StatusType.STRENGTH);
}
else
{
    v += get_status(owner, StatusType.MAGIC_POWER) + get_status(owner, StatusType.TEMP_MAGIC);
}

            // 剑招：带剑招标签的牌，所有伤害 +N
            if (card_has_tag(_inst.card_id, CardTag.SWORD))
            {
                v += get_status(owner, StatusType.SWORD_FORM);
            }

            // 风狂·流羽：本回合风刃的每个伤害段额外+2
            if (_inst.card_id == 2 && instance_exists(obj_hand_controller))
            {
                v += obj_hand_controller.wind_blade_bonus;
            }
        }
        break;

        case EffectType.ARMOR:
        {
            // 敏捷：获得的护甲 +1/层（按接收者算，没有指定接收者就按拥有者算）
            var receiver = (_receiver != noone) ? _receiver : owner;
            v += get_status(receiver, StatusType.DEXTERITY);
            if (get_status(receiver, StatusType.ROCK_WALL) > 0) v *= 2;
        }
        break;
    }

    return max(v, 0);
}

// 这张牌上伤害效果的重复次数（卡面文字用）
function card_current_times(_inst)
{
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        if (effects[i].type == EffectType.DAMAGE && variable_struct_exists(effects[i], "times"))
        {
            return effects[i].times;
        }
    }

    return 1;
}

// 这张牌上某一类效果的当前总数值（用来显示在卡牌文字上）
function card_current_value(_inst, _type)
{
    var total = 0;
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        if (effects[i].type == _type)
        {
            total += card_effect_final(effects[i], _inst, noone);
        }
    }

    return total;
}

function card_current_damage(_inst)
{
    return card_current_value(_inst, EffectType.DAMAGE);
}

function card_current_xingguang(_inst)
{
    return card_current_value(_inst, EffectType.STARLIGHT);
}

function card_current_armor(_inst)
{
    return card_current_value(_inst, EffectType.ARMOR);
}

// 某种伤害类型的当前总伤害（只统计对前场敌人的 DAMAGE 效果）
function card_current_damage_of(_inst, _dtype)
{
    var total = 0;
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        var e = effects[i];

        if (e.type == EffectType.DAMAGE
        &&  variable_struct_exists(e, "dtype")
        &&  e.dtype == _dtype)
        {
            total += card_effect_final(e, _inst, noone);
        }
    }

    return total;
}

// 对其他敌人的伤害
function card_current_others(_inst)
{
    return card_current_value(_inst, EffectType.DAMAGE_OTHERS);
}

// 抽牌数
function card_current_draw(_inst)
{
    return card_current_value(_inst, EffectType.DRAW);
}

// 下回合额外费用
function card_current_next_energy(_inst)
{
    return card_current_value(_inst, EffectType.NEXT_ENERGY);
}
// 这张牌施加的某种状态的层数
function card_current_status(_inst, _status)
{
    var total = 0;
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        var e = effects[i];

        if (e.type == EffectType.STATUS && e.status == _status)
        {
            total += card_effect_value(e);
        }
    }

    return total;
}
// 这张牌给的某种护甲的数值（会带上全局护甲加成）
function card_current_armor_of(_inst, _armor_type)
{
    var total = 0;
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        var e = effects[i];

        if (e.type == EffectType.ARMOR && e.armor == _armor_type)
        {
            total += card_effect_final(e, _inst, noone);
        }
    }

    return total;
}
// 执行一张牌的所有效果
// 立即执行一个效果
function card_apply_effect(_e, _v, _target, _enemy)
{
    switch (_e.type)
    {
        case EffectType.DAMAGE:
{
    if (_enemy != noone)
    {
        // 条件伤害：目标被冻结才造成
        if (variable_struct_exists(_e, "if_frozen") && get_status(_enemy, StatusType.FROZEN) <= 0) break;

        // 没写类型的伤害效果默认按物理伤害处理
        var dt = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.PHYSICAL;
        deal_damage(_enemy, _v, dt);

        // 击杀奖励：目标被击杀，把一张牌置入手牌
        if (variable_struct_exists(_e, "on_kill_id") && !instance_exists(_enemy))
        {
            with (obj_hand_controller)
            {
                add_card_to_hand_id(_e.on_kill_id, _e.on_kill_cost, 0);
            }
        }
    }
}
break;

        case EffectType.DAMAGE_OTHERS:
        {
            // 前场（被打的那个）以外的所有敌人
            var dt_o = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.PHYSICAL;
            var all_enemies = copy_array(obj_hand_controller.enemies);

            for (var i = 0; i < array_length(all_enemies); i++)
            {
                var en = all_enemies[i];

                if (en != _enemy && instance_exists(en))
                {
                    deal_damage(en, _v, dt_o);
                }
            }
        }
        break;

        case EffectType.ARMOR:
{
    var armor_recv = effect_target_char(_e, _target);

    if (armor_recv != noone)
    {
        add_armor(armor_recv, _e.armor, _v);
    }
}
break;

        case EffectType.STARLIGHT:
        {
            // 星光是角色2的专属资源
            add_starlight(obj_hand_controller.char_2, _v);
        }
        break;
		case EffectType.UNLOCK_DISCOVER:
		{
			with (obj_hand_controller)
			{
				discover_46_unlocked = true;
			}
			}
		break;
        case EffectType.DRAW:
        {
            with (obj_hand_controller)
            {
                draw_cards(_v);
            }
        }
        break;

        case EffectType.NEXT_ENERGY:
        {
            with (obj_hand_controller)
            {
                next_turn_energy_bonus += _v;
            }
        }
        break;
		
		case EffectType.ADD_TO_HAND:
{
    var cnt = variable_struct_exists(_e, "count") ? _e.count : 1;
    var cst = variable_struct_exists(_e, "cost") ? _e.cost : -1;
    var bonus = variable_struct_exists(_e, "dmg_bonus") ? _e.dmg_bonus : 0;

    with (obj_hand_controller)
    {
        repeat (cnt)
        {
            if (variable_struct_exists(_e, "card_id"))
            {
                add_card_to_hand_id(_e.card_id, cst, bonus);
            }
            else
            {
                add_card_to_hand(_e.obj, cst);
            }
        }
    }
}
break;

case EffectType.DISCARD_FROM_HAND:
{
    with (obj_hand_controller)
    {
        discard_cards_by_id(_e.card_id);
    }
}
break;

case EffectType.LOSE_HP:
{
    lose_hp(variable_instance_get(obj_hand_controller, "char_" + string(_e.on_char)), _v);
}
break;

case EffectType.HEAL:
{
    heal_hp(variable_instance_get(obj_hand_controller, "char_" + string(_e.on_char)), _v);
}
break;

		case EffectType.STATUS:
{
    // 默认施加给被打的前场敌人；写了 on_char 就施加给对应编号的我方角色
    var status_target = _enemy;

    if (variable_struct_exists(_e, "on_char"))
    {
        status_target = variable_instance_get(obj_hand_controller, "char_" + string(_e.on_char));
    }

    if (status_target != noone)
    {
        add_status(status_target, _e.status, _v);
    }
}
break;
case EffectType.BRING_TO_FRONT:
{
    var front_who = effect_target_char(_e, _target);

    with (obj_hand_controller)
    {
        bring_to_front(front_who);
    }
}
break;

// ---- 新增 ----
case EffectType.GAIN_ENERGY:
{
    // 条件：本回合使用过 N 种不同的初始牌
    var energy_ok = true;

    if (variable_struct_exists(_e, "need_starters"))
    {
        energy_ok = (turn_distinct_starters() >= _e.need_starters);
    }

    if (energy_ok)
    {
        with (obj_hand_controller)
        {
            energy += _v;
        }
    }
}
break;

case EffectType.COUNTDOWN:
{
    with (obj_hand_controller)
    {
        countdown_add(_e.owner, _e.amount, _e.effects);
    }
}
break;

case EffectType.COUNTDOWN_SHIFT:
{
    with (obj_hand_controller)
    {
        countdown_shift(_e.on_char, -_e.amount);
    }
}
break;

case EffectType.MOVE_TO_BACK:
{
    var back_who = effect_target_char(_e, _target);

    with (obj_hand_controller)
    {
        send_to_back(back_who);
    }
}
break;

case EffectType.DISCOVER_OWN:
{
    with (obj_hand_controller)
    {
        request_discover(discover_pool_char(_e.on_char), 3);
    }
}
break;

case EffectType.DISCOVER_LIST:
{
    var list_pool = [];

    for (var li = 0; li < array_length(_e.card_ids); li++)
    {
        var list_obj = card_get_object(_e.card_ids[li]);

        if (list_obj != -1) list_pool[array_length(list_pool)] = list_obj;
    }

    with (obj_hand_controller)
    {
        request_discover(list_pool, _e.count);
    }
}
break;

case EffectType.DRAW_CARD_ID:
{
    with (obj_hand_controller)
    {
        draw_specific(_e.card_id, _e.amount);
    }
}
break;

case EffectType.RETAIN_HAND:
{
    with (obj_hand_controller)
    {
        retain_all_hand();
    }
}
break;

case EffectType.CONSUME_FROM_HAND:
{
    with (obj_hand_controller)
    {
        consume_from_hand(_e.card_id);
    }
}
break;

case EffectType.BUFF_HAND_DAMAGE:
{
    with (obj_hand_controller)
    {
        buff_hand_damage(_e.card_id, _e.amount);
    }
}
break;

case EffectType.DAMAGE_ARMOR_TOTAL:
{
    var armor_who = effect_target_char(_e, _target);

    if (_enemy != noone && armor_who != noone)
    {
        deal_damage(_enemy, unit_armor_total(armor_who), _e.dtype);
    }
}
break;

case EffectType.SHUFFLE_ELEMENT:
{
    with (obj_hand_controller)
    {
        shuffle_into_deck(card_get_object(irandom_range(1, 4)));
    }
}
break;

case EffectType.ROTATE_SELF:
{
    var rotate_who = effect_target_char(_e, _target);
    with (obj_hand_controller)
    {
        rotate_character(rotate_who);
    }
}
break;

case EffectType.DRAW_IF_PLAYED:
{
    var was_played = false;
    for (var pi = 0; pi < array_length(obj_hand_controller.turn_played_ids); pi++)
    {
        if (obj_hand_controller.turn_played_ids[pi] == _e.card_id)
        {
            was_played = true;
            break;
        }
    }

    if (was_played)
    {
        with (obj_hand_controller)
        {
            draw_cards(_v);
        }
    }
}
break;

case EffectType.SELECT_HAND:
{
    with (obj_hand_controller)
    {
        selection_start(_e.filter_id, _e.mode, _e.min, _e.max, _e.action);
    }
}
break;

case EffectType.ADD_ENTRY_TO_HAND:
{
    with (obj_hand_controller)
    {
        var entry = _e.entry;
        if (array_length(hand) >= max_hand_size)
        {
            discard_pile[array_length(discard_pile)] = entry;
        }
        else
        {
            var spawned = card_spawn_from_entry(entry, room_width * 0.5, room_height - 115);
            spawned.is_dealing = true;
            hand[array_length(hand)] = spawned;
            check_merge();
        }
    }
}
break;

case EffectType.FIREBALL_VOLLEY:
{
    var fire_obj = card_get_object(1);
    var free_slots = max(obj_hand_controller.max_hand_size - array_length(obj_hand_controller.hand), 0);
    var use_count = min(_e.amount, free_slots);
    var volley_target = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;

    for (var vi = 0; vi < _e.amount; vi++)
    {
        var fire_entry = card_make_entry(fire_obj);
        fire_entry.effects = effects_add_damage(card_get_effects(1), _e.damage_bonus);

        if (vi < use_count)
        {
            var fire_inst = card_spawn_from_entry(fire_entry, -1000, -1000);
            var current_volley_target = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;
            card_play_effects(fire_inst, _target, current_volley_target);
            with (fire_inst) instance_destroy();
            obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] = fire_entry;
        }
        else
        {
            obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] = fire_entry;
        }
    }
}
break;

case EffectType.RANDOM_STARTER:
{
    var random_id = irandom_range(1, 4);
    var random_obj = card_get_object(random_id);
    var random_entry = card_make_entry(random_obj);
    var random_inst = card_spawn_from_entry(random_entry, -1000, -1000);
    var random_owner = effect_target_char(_e, _target);
    var random_enemy = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;

    // 视为使用：记录初始牌编号，使其他“本回合使用过初始牌”的效果也能识别
    obj_hand_controller.turn_played_ids[array_length(obj_hand_controller.turn_played_ids)] = random_id;
    if (random_id <= 3)
    {
        obj_hand_controller.attack_used_this_turn[1] = true;
        with (obj_hand_controller) bring_to_front(random_owner);
    }
    else if (random_id == 4 && get_status(random_owner, StatusType.ROCK_WALL) > 0)
    {
        with (obj_hand_controller) bring_to_front(random_owner);
    }

    // 星火与燎原也会作用于这次视为使用的初始牌
    if (obj_hand_controller.starfire_ready && get_status(random_owner, StatusType.STARFIRE) > 0)
    {
        card_double_effects(random_inst);
        clear_status(random_owner, StatusType.STARFIRE);
        obj_hand_controller.starfire_ready = false;
    }

    card_play_effects(random_inst, random_owner, random_enemy);

    // 若随机到霜落，也会消耗冰寒·落雨并对其他敌人重复
    if (random_id == 3 && get_status(random_owner, StatusType.FROST_RAIN) > 0)
    {
        clear_status(random_owner, StatusType.FROST_RAIN);
        var extra_targets = copy_array(obj_hand_controller.enemies);
        for (var ei = 0; ei < array_length(extra_targets); ei++)
        {
            if (extra_targets[ei] != random_enemy && instance_exists(extra_targets[ei]))
            {
                card_play_effects(random_inst, random_owner, extra_targets[ei]);
            }
        }
    }

    var random_used_entry = card_entry_from_instance(random_inst);
    with (random_inst) instance_destroy();

    obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] = random_used_entry;

    with (obj_hand_controller)
    {
        // 复制实际使用的那张牌，保留本次触发的强化效果
        if (array_length(hand) >= max_hand_size)
        {
            discard_pile[array_length(discard_pile)] = random_used_entry;
        }
        else
        {
            var copy_inst = card_spawn_from_entry(random_used_entry, room_width * 0.5, room_height - 115);
            copy_inst.is_dealing = true;
            hand[array_length(hand)] = copy_inst;
            check_merge();
        }
    }
}
break;

case EffectType.UPGRADE_ALL_STARTERS:
{
    // 手牌中的初始牌直接强化
    for (var hi = 0; hi < array_length(obj_hand_controller.hand); hi++)
    {
        var hand_card = obj_hand_controller.hand[hi];
        if (instance_exists(hand_card) && hand_card.card_id >= 1 && hand_card.card_id <= 4)
        {
            card_double_effects(hand_card);
        }
    }

    // 抽牌堆和弃牌堆中的初始牌通过临时实例强化，再保存回牌堆记录
    for (var di = obj_hand_controller.deck_index; di < array_length(obj_hand_controller.deck); di++)
    {
        var deck_entry = obj_hand_controller.deck[di];
        if (deck_entry.obj == card_get_object(1) || deck_entry.obj == card_get_object(2)
        ||  deck_entry.obj == card_get_object(3) || deck_entry.obj == card_get_object(4))
        {
            var deck_inst = card_spawn_from_entry(deck_entry, -1000, -1000);
            card_double_effects(deck_inst);
            obj_hand_controller.deck[di] = card_entry_from_instance(deck_inst);
            with (deck_inst) instance_destroy();
        }
    }

    for (var di = 0; di < array_length(obj_hand_controller.discard_pile); di++)
    {
        var discard_entry = obj_hand_controller.discard_pile[di];
        if (discard_entry.obj == card_get_object(1) || discard_entry.obj == card_get_object(2)
        ||  discard_entry.obj == card_get_object(3) || discard_entry.obj == card_get_object(4))
        {
            var discard_inst = card_spawn_from_entry(discard_entry, -1000, -1000);
            card_double_effects(discard_inst);
            obj_hand_controller.discard_pile[di] = card_entry_from_instance(discard_inst);
            with (discard_inst) instance_destroy();
        }
    }
}
break;

case EffectType.COUNTDOWN_ALL_FRIENDS:
{
    with (obj_hand_controller)
    {
        for (var fi = 1; fi <= 4; fi++)
        {
            var friend_inst = variable_instance_get(id, "char_" + string(fi));
            if (char_is_alive(friend_inst))
            {
                countdown_add(fi, _e.amount, _e.effects);
            }
        }
    }
}
break;

case EffectType.MERGE_ALL_FIREBALLS:
{
    var fire_obj = card_get_object(1);
    var fire_count = 0;
    var best_fire_power = -1;
    var best_fire_entry = card_make_entry(fire_obj);

    // 消耗手牌中的火球，同时保留其中强化程度最高的一张作为合成底牌
    for (var hi = array_length(obj_hand_controller.hand) - 1; hi >= 0; hi--)
    {
        var hcard = obj_hand_controller.hand[hi];
        if (instance_exists(hcard) && hcard.card_id == 1)
        {
            fire_count++;
            var hand_power = card_power(hcard);
            if (hand_power > best_fire_power)
            {
                best_fire_power = hand_power;
                best_fire_entry = card_entry_from_instance(hcard);
            }
            with (obj_hand_controller) remove_card_from_hand(hcard);
        }
    }

    // 消耗尚未抽取的抽牌堆火球
    for (var di = array_length(obj_hand_controller.deck) - 1; di >= obj_hand_controller.deck_index; di--)
    {
        if (obj_hand_controller.deck[di].obj == fire_obj)
        {
            fire_count++;
            var deck_fire_inst = card_spawn_from_entry(obj_hand_controller.deck[di], -1000, -1000);
            var deck_fire_power = card_power(deck_fire_inst);
            if (deck_fire_power > best_fire_power)
            {
                best_fire_power = deck_fire_power;
                best_fire_entry = card_entry_from_instance(deck_fire_inst);
            }
            with (deck_fire_inst) instance_destroy();
            array_delete(obj_hand_controller.deck, di, 1);
        }
    }

    // 消耗弃牌堆火球
    for (var di = array_length(obj_hand_controller.discard_pile) - 1; di >= 0; di--)
    {
        if (obj_hand_controller.discard_pile[di].obj == fire_obj)
        {
            fire_count++;
            var discard_fire_inst = card_spawn_from_entry(obj_hand_controller.discard_pile[di], -1000, -1000);
            var discard_fire_power = card_power(discard_fire_inst);
            if (discard_fire_power > best_fire_power)
            {
                best_fire_power = discard_fire_power;
                best_fire_entry = card_entry_from_instance(discard_fire_inst);
            }
            with (discard_fire_inst) instance_destroy();
            array_delete(obj_hand_controller.discard_pile, di, 1);
        }
    }

    if (fire_count > 0)
    {
        // 1~3张都按一级强化处理；4~9张按二级；10~27张按三级
        // 数量继续增加时，按每三级一组继续向上取整。
        var desired_merge_level = 1;
        var remaining = fire_count;
        while (remaining > 3)
        {
            remaining = ceil(remaining / 3);
            desired_merge_level++;
        }

        var merged_inst = card_spawn_from_entry(best_fire_entry, -1000, -1000);
        var existing_merge_level = card_merge_level(merged_inst);
        var extra_merge_times = max(desired_merge_level - existing_merge_level, 0);
        repeat (extra_merge_times) card_double_effects(merged_inst);

        var merged_target = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;
        card_play_effects(merged_inst, _target, merged_target);
        with (merged_inst) instance_destroy();
    }
}
break;

case EffectType.REPLAY_STARTER:
{
    var replay_obj = card_get_object(_e.card_id);
    var replay_inst = card_spawn_from_entry(card_make_entry(replay_obj), -1000, -1000);
    var replay_owner = card_get_owner_instance(_e.card_id);
    var replay_enemy = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;

    // 倒计时重放也视为本回合使用过这张初始牌
    obj_hand_controller.turn_played_ids[array_length(obj_hand_controller.turn_played_ids)] = _e.card_id;
    if (_e.card_id >= 1 && _e.card_id <= 3)
    {
        obj_hand_controller.attack_used_this_turn[1] = true;
        with (obj_hand_controller) bring_to_front(replay_owner);
    }
    else if (_e.card_id == 4 && get_status(replay_owner, StatusType.ROCK_WALL) > 0)
    {
        with (obj_hand_controller) bring_to_front(replay_owner);
    }

    if (obj_hand_controller.starfire_ready && get_status(replay_owner, StatusType.STARFIRE) > 0)
    {
        card_double_effects(replay_inst);
        obj_hand_controller.starfire_ready = false;
    }

    card_play_effects(replay_inst, replay_owner, replay_enemy);

    // 重放霜落时同样会触发冰寒·落雨
    if (_e.card_id == 3 && get_status(replay_owner, StatusType.FROST_RAIN) > 0)
    {
        clear_status(replay_owner, StatusType.FROST_RAIN);
        var replay_targets = copy_array(obj_hand_controller.enemies);
        for (var ri = 0; ri < array_length(replay_targets); ri++)
        {
            if (replay_targets[ri] != replay_enemy && instance_exists(replay_targets[ri]))
            {
                card_play_effects(replay_inst, replay_owner, replay_targets[ri]);
            }
        }
    }

    with (replay_inst) instance_destroy();
}
break;
    }
}

// 执行一张牌的所有效果（带 delay 的效果放进等待队列，稍后触发）
// _target：指定的友方角色；_enemy：前场敌人
// 执行一张牌的所有效果（带 delay 或重复的效果放进等待队列，稍后触发）
// _target：我方角色（指定的，或前场角色）；_enemy：被打的敌人
function card_play_effects(_card, _target, _enemy)
{
    var effects = card_current_effects(_card);

    for (var i = 0; i < array_length(effects); i++)
    {
        var e = effects[i];

        // 数值在出牌这一刻算好（含力量、魔力、敏捷、剑招等加成）
        var v = card_effect_final(e, _card, effect_target_char(e, _target));

        // "等量"：数值等于这张牌当前造成的伤害
        if (variable_struct_exists(e, "equal_damage"))
        {
            v = card_current_damage(_card);
        }

        var base_delay = variable_struct_exists(e, "delay") ? e.delay : 0;
        var times      = variable_struct_exists(e, "times") ? e.times : 1;
        var gap        = variable_struct_exists(e, "times_gap") ? e.times_gap : 15;

        for (var r = 0; r < times; r++)
        {
            var d = base_delay + r * gap;

            if (d > 0)
            {
                var pe = { timer: d, effect: e, value: v, target: _target, enemy: _enemy };

                with (obj_hand_controller)
                {
                    array_push(pending_effects, pe);
                }
            }
            else
            {
                card_apply_effect(e, v, _target, _enemy);
            }
        }
    }
}
// 按编号取卡牌对象（对象名必须直接写出来，不能用字符串拼接，否则会被当成未使用的资源移除）
// 编号超出列表的返回 -1
// 按编号取卡牌对象（对象名必须直接写出来）。没有的返回 -1
function card_get_object(_n)
{
    switch (_n)
    {
        // 苏灵兮
        case 1:  return obj_card_0001;
        case 2:  return obj_card_0002;
        case 3:  return obj_card_0003;
        case 4:  return obj_card_0004;
        case 5:  return obj_card_0005;
        case 6:  return obj_card_0006;
        case 7:  return obj_card_0007;
        case 8:  return obj_card_0008;
        case 9:  return obj_card_0009;
        case 10: return obj_card_0010;
        case 11: return obj_card_0011;
        case 12: return obj_card_0012;
        case 13: return obj_card_0013;
        case 14: return obj_card_0014;
        case 15: return obj_card_0015;
        case 16: return obj_card_0016;
        case 17: return obj_card_0017;
        case 18: return obj_card_0018;
        case 19: return obj_card_0019;
        case 21: return obj_card_0021;
        case 22: return obj_card_0022;
        case 23: return obj_card_0023;
        case 24: return obj_card_0024;
        case 25: return obj_card_0025;
        case 26: return obj_card_0026;
        case 27: return obj_card_0027;
        case 28: return obj_card_0028;
        case 29: return obj_card_0029;
        case 30: return obj_card_0030;
        case 31: return obj_card_0031;
        case 32: return obj_card_0032;
        case 33: return obj_card_0033;
        case 34: return obj_card_0034;
        case 35: return obj_card_0035;
        case 36: return obj_card_0036;
        case 37: return obj_card_0037;
        case 38: return obj_card_0038;
        case 39: return obj_card_0039;
        case 41: return obj_card_0041;
        case 40: return obj_card_0040;
        case 42: return obj_card_0042;
        case 43: return obj_card_0043;
        case 44: return obj_card_0044;
        case 45: return obj_card_0045;
        case 46: return obj_card_0046;

        // 尘
        case 101: return obj_card_0101;
        case 102: return obj_card_0102;
        case 103: return obj_card_0103;
        case 104: return obj_card_0104;
        case 105: return obj_card_0105;
        case 106: return obj_card_0106;
        case 107: return obj_card_0107;
        case 108: return obj_card_0108;
        case 109: return obj_card_0109;
        case 110: return obj_card_0110;

        // 心羽
        case 201: return obj_card_0201;
        case 202: return obj_card_0202;
        case 203: return obj_card_0203;
        case 204: return obj_card_0204;
        case 205: return obj_card_0205;
        case 206: return obj_card_0206;
        case 207: return obj_card_0207;
        case 208: return obj_card_0208;
        case 209: return obj_card_0209;
        case 210: return obj_card_0210;

        // 通用
        case 301: return obj_card_0301;
        case 302: return obj_card_0302;
        case 303: return obj_card_0303;
        case 304: return obj_card_0304;
    }

    return -1;
}


// 按队伍里的角色组牌库，返回卡牌对象数组
// 角色1 → 1~10，角色2 → 11~20，角色3 → 21~30，角色4 → 不加牌
// 每个角色的初始牌（编号），角色4没有
function character_get_starter_cards(_num)
{
    switch (_num)
    {
        case 1: return [1, 2, 3, 4];
        case 2: return [101, 102, 103, 104];
        case 3: return [201, 202, 203, 204];
    }

    return [];
}
// 通用初始牌：打击 x3、防御 x3、智慧 x1
function generic_starter_cards()
{
    return [301, 301, 301, 302, 302, 302, 304];
}

// 按队伍里的角色组初始牌库，返回卡牌对象数组
function build_card_pool(_party)
{
    var pool = [];
    var char_list = [obj_character_1, obj_character_2, obj_character_3, obj_character_4];

    // 每个入队角色的初始牌
    for (var a = 0; a < array_length(_party); a++)
    {
        for (var b = 0; b < 4; b++)
        {
            if (char_list[b] != _party[a]) continue;

            var starter_ids = character_get_starter_cards(b + 1);

            for (var k = 0; k < array_length(starter_ids); k++)
            {
                var starter_obj = card_get_object(starter_ids[k]);

                // 没有这个对象就跳过
                if (starter_obj != -1)
                {
                    pool[array_length(pool)] = starter_obj;
                }
            }
        }
    }

    // 通用初始牌
    var generic_ids = generic_starter_cards();

    for (var g = 0; g < array_length(generic_ids); g++)
    {
        var generic_obj = card_get_object(generic_ids[g]);

        if (generic_obj != -1)
        {
            pool[array_length(pool)] = generic_obj;
        }
    }

    return pool;
}
// 卡牌的高清预览图（返回 -1 表示没有，改用牌本身的图）
function card_get_preview_sprite(_id)
{
    switch (_id)
    {
        case 15:  return spr_card_15_hd;

        // ……依此类推，把名字换成你实际的高清精灵名……
    }

    return -1;
}

// 是否是角色2的专属牌（可以使用星光抵扣费用）
// 角色2（尘）的牌可以用星光抵扣费用
function card_uses_starlight(_id)
{
    return (_id >= 101 && _id <= 200);
}
// 是否是指向型卡牌（拖动时变成箭头，必须指向角色才能打出）
// 指向类型
enum TargetKind
{
    NONE,     // 不需要指向
    FRIEND,   // 指向我方角色
    ENEMY     // 指向敌方角色
}

function card_target_kind(_id)
{
    var info = card_info(_id);
    if (!is_undefined(info) && info.target != TargetKind.NONE) return info.target;

    if (_id == 4)   return TargetKind.FRIEND;
    if (_id == 202) return TargetKind.ENEMY;     // 刺（追猎）
    if (_id == 243) return TargetKind.ENEMY;
    if (_id >= 301 && _id <= 303) return TargetKind.FRIEND;

    return TargetKind.NONE;
}

// 是否是指向型卡牌（拖动时变成箭头）
function card_needs_target(_id)
{
    return (card_target_kind(_id) != TargetKind.NONE);
}

// 哪些牌可以合成（角色1的 1~4 号牌）
function card_can_merge(_id)
{
    return (_id >= 1 && _id <= 4);
}

// 复制一个效果（结构体），改它不会影响原来的
function effect_copy(_e)
{
    var result = {};
    var names = variable_struct_get_names(_e);

    for (var i = 0; i < array_length(names); i++)
    {
        variable_struct_set(result, names[i], variable_struct_get(_e, names[i]));
    }

    return result;
}

// 一张牌当前的"数值大小"：所有效果的当前数值加起来（用来比较谁最大）
function card_power(_inst)
{
    var total = 0;
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        total += card_effect_value(effects[i]);
    }

    return total;
}

// 让一张牌的所有效果按当前数值翻倍
function card_double_effects(_inst)
{
    var old_effects = card_current_effects(_inst);
    var new_effects = [];

    for (var i = 0; i < array_length(old_effects); i++)
    {
        var e = effect_copy(old_effects[i]);

        // 当前实际数值（带着各种加成）翻倍。
        // 全局加成要先扣掉，否则打出时会被再加一遍
        var current = card_effect_value(e);
        var bonus = current - e.amount;

        e.amount = current * 2 - bonus;

        new_effects[i] = e;
    }

    // 把翻倍后的效果存在这张牌自己身上，卡面文字会自动读到新数值
    _inst.effects = new_effects;

    // 记录合成过几次（以后想在卡面上做标记可以用）
    if (!variable_instance_exists(_inst, "merge_level"))
    {
        _inst.merge_level = 0;
    }

    _inst.merge_level++;
}
// 复制一组效果
function card_copy_effects(_arr)
{
    var result = [];

    for (var i = 0; i < array_length(_arr); i++)
    {
        result[i] = effect_copy(_arr[i]);
    }

    return result;
}

// 读取一张牌的合成等级（没合成过是 0）
function card_merge_level(_inst)
{
    if (variable_instance_exists(_inst, "merge_level")) return _inst.merge_level;
    return 0;
}

// 把卡牌对象做成牌堆里保存的"卡牌记录"

// 把一组卡牌对象全部做成记录
function card_entries_from_objects(_objs)
{
    var result = [];

    for (var i = 0; i < array_length(_objs); i++)
    {
        result[i] = card_make_entry(_objs[i]);
    }

    return result;
}

// 从卡牌实例生成记录（连同合成强化一起保存），进入弃牌堆时用
function card_entry_from_instance(_inst)
{
    // 以当前卡牌编号对应的对象保存，确保被转化的牌（例如变成岩盾）离开手牌后仍保留新身份
    var saved_obj = card_get_object(_inst.card_id);
    if (saved_obj == -1) saved_obj = _inst.object_index;

    var entry = card_make_entry(saved_obj);
    entry.card_id = _inst.card_id;

    if (variable_instance_exists(_inst, "effects"))
    {
        entry.effects = card_copy_effects(_inst.effects);
    }

    entry.merge_level = card_merge_level(_inst);
	if (variable_instance_exists(_inst, "cost"))
{
    entry.cost = _inst.cost;
}

    return entry;
}

// 根据记录生成卡牌实例，并带上强化
function card_spawn_from_entry(_entry, _x, _y)
{
    var inst = instance_create_layer(_x, _y, "Instances", _entry.obj);

    // 覆盖对象 Create 事件里的默认编号，保留实例经过转化后的卡牌身份
    if (variable_struct_exists(_entry, "card_id") && !is_undefined(_entry.card_id))
    {
        inst.card_id = _entry.card_id;
    }

    // 没合成过的牌不设置 effects，继续从数据表读取
    if (!is_undefined(_entry.effects))
    {
        inst.effects = card_copy_effects(_entry.effects);
    }

    inst.merge_level = _entry.merge_level;
	
	if (!is_undefined(_entry.cost))
{
    inst.cost = _entry.cost;
}

    return inst;
}

// 卡牌标签
enum CardTag
{
    SWORD,   // 剑招
    HUNT     // 追猎：可以攻击到后场的敌人
}

function card_has_tag(_id, _tag)
{
    switch (_tag)
    {
        case CardTag.SWORD:
            return ((_id >= 201 && _id <= 204) || (_id >= 241 && _id <= 246));

        case CardTag.HUNT:
            return (_id == 202);
    }

    return false;
}


// 带"消耗"词条的牌（打出后直接销毁，不进弃牌堆）
// 目前 41~46 都带消耗；以后不带消耗的剑招，不要写进这里
function card_has_exhaust_keyword(_id)
{
    var info = card_info(_id);
    if (!is_undefined(info) && info.exhaust) return true;

    if (_id >= 241 && _id <= 246) return true;   // 剑招特殊牌
    if (_id == 207 || _id == 208) return true;   // 引血、练心

    return false;
}

// 打出后是否移出游戏：状态牌，或者带消耗词条的牌
function card_is_exhaust(_id)
{
    if (card_get_type(_id) == CardType.STATUS) return true;

    return card_has_exhaust_keyword(_id);
}

// 打出这张牌是否计入角色3的"发现"计数
function card_counts_for_discover(_id)
{
    if (_id >= 201 && _id <= 206) return true;   // 心羽的攻击牌
    if (_id >= 241 && _id <= 246) return true;   // 剑招特殊牌
    if (_id == 301) return true;                 // 通用攻击牌：打击

    return false;
}

// 发现用的六张特殊牌（对象名必须直接写出来，否则会被当成未使用的资源移除）
// 发现用的特殊牌：默认只有 41~45，解锁后才加入 46
function discover_pool_xinyu(_include_46)
{
    var pool = [
        obj_card_xinyu_1, obj_card_xinyu_2, obj_card_xinyu_3,
        obj_card_xinyu_4, obj_card_xinyu_5
    ];

    if (_include_46)
    {
        pool[array_length(pool)] = obj_card_xinyu_6;
    }

    return pool;
}

function card_make_entry(_obj)
{
    return { obj: _obj, effects: undefined, merge_level: 0, cost: undefined };
}
// 无法被打出的牌（拖出去也会回到手牌）
function card_is_unplayable(_id)
{
    return (_id == 401 || _id == 402);
}
// 出牌阶段结束时，手牌里这张牌的效果
function card_on_turn_end(_inst)
{
    switch (_inst.card_id)
    {
        // 猩红：扣 3 点生命，获得 1 层血色
        case 401:
        {
            var c3 = obj_hand_controller.char_3;

            lose_hp(c3, 3);
            add_status(c3, StatusType.BLOOD, 1);
        }
        break;
		// 贪婪诅咒：前排的角色受到 2 点物理伤害
		case 402:
{
			var front = obj_hand_controller.front_char;

			if (front != noone)
    {
        deal_damage(front, 2, DamageType.PHYSICAL);
    }
}
break;
    }
}

// 这张牌的拥有者是否已阵亡（通用牌没有拥有者，永远返回 false）
function card_owner_dead(_id)
{
    var owner = card_get_owner_instance(_id);

    if (owner == noone) return false;
    if (!instance_exists(owner)) return false;

    return owner.is_dead;
}

function card_has_retain(_id)
{
    return (_id == 303);
}