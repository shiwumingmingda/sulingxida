
/// obj_hand_controller - Create Event
// 测试用临时按钮：左上角
test_x1 = 20;
test_x2 = 190;
test_y1 = 20;
test_y2 = 70;

// 场上所有活着的角色的牌（各自 1~30 号里属于他们的牌），发现用
discover_pool_field = function()
{
    var pool = [];

    for (var n = 1; n <= 4; n++)
    {
        var who = variable_instance_get(id, "char_" + string(n));

        // 没入队或已阵亡的角色不算
        if (!char_is_alive(who)) continue;

        var card_range = character_get_card_range(n);

        if (array_length(card_range) == 0) continue;

        for (var cn = card_range[0]; cn <= card_range[1]; cn++)
        {
			if (!card_in_pool(cn)) continue
            var card_obj_n = card_get_object(cn);

            if (card_obj_n != -1)
            {
                pool[array_length(pool)] = card_obj_n;
            }
        }
    }

    return pool;
};










randomize();

// 固定界面坐标
display_set_gui_size(room_width, room_height);

// 十张卡牌
// 如果直接从战斗房间启动（没经过选人界面），用默认队伍，方便测试
if (!variable_global_exists("party"))
{
    global.party = [obj_character_1, obj_character_2];
}

// 按选择的角色组牌库
// 进入战斗时，记录当前拥有的所有牌（整局游戏的牌库）。
// 战斗中洗入的牌、消耗掉的牌都只影响抽牌堆和弃牌堆，不会改动这份记录
if (!variable_global_exists("card_collection") || is_undefined(global.card_collection))
{
    global.card_collection = build_card_pool(global.party);
}

// 本场战斗的牌堆：复制一份记录，再洗牌
card_pool = copy_array(global.card_collection);
// 测试用：临时多放两张 1 号牌，方便凑出三张。测完删掉

// 牌堆里存的是"卡牌记录"（对象 + 强化），合成过的牌在整场战斗里都保持强化
deck = array_shuffle(card_entries_from_objects(card_pool));
deck_index = 0;

// 手牌
hand = [];

// 弃牌堆：保存卡牌对象，而不是卡牌实例
discard_pile = [];

// 当前正在拖动的卡牌
drag_card = noone;
drag_offset_x = 0;
drag_offset_y = 0;

// 角色所在的位置

// 我方（左侧）：前场靠近中间，后场两个站位在更左边的上下
front_x = room_width * 0.36;
front_y = room_height * 0.55;

back_slot_x = [room_width * 0.16, room_width * 0.16];
back_slot_y = [room_height * 0.35, room_height * 0.75];   // 下标 0 = 上方，1 = 下方



front_char = noone;
back_chars = [];

// 1~4 号角色的实例（没入队的是 noone）
char_1 = noone;
char_2 = noone;
char_3 = noone;
char_4 = noone;

var all_chars = [obj_character_1, obj_character_2, obj_character_3, obj_character_4];
party_insts = [];
for (var p = 0; p < array_length(global.party); p++)
{
    // 第 1 个在前场，第 2 个在后场上方，第 3 个在后场下方
	
    var px = (p == 0) ? front_x : back_slot_x[p - 1];
    var py = (p == 0) ? front_y : back_slot_y[p - 1];
	
    var inst = instance_create_layer(px, py, "Instances", global.party[p]);
	// 带入地图上记录的血量
if (variable_global_exists("party_hp") && p < array_length(global.party_hp))
{
    inst.max_hp = global.party_max_hp[p];
    inst.hp = global.party_hp[p];
}
party_insts[p] = inst;
    if (p == 0)
    {
        front_char = inst;
    }
    else
    {
        back_chars[array_length(back_chars)] = inst;
    }

    // 记录这是几号角色，卡牌效果里的 char_1 ~ char_4 要靠它找到对应的人
    for (var q = 0; q < 4; q++)
    {
        if (all_chars[q] == global.party[p])
        {
            variable_instance_set(id, "char_" + string(q + 1), inst);
        }
    }
}


// 让指定角色进入前场
bring_to_front = function(_char)
{
    if (!instance_exists(_char)) return;
	if (_char.is_dead) return;

    // 已经在前场就不用动
    if (_char == front_char) return;

    // 1. 把目标从后场队列里移除（后面的人自动左移补位）
    for (var k = 0; k < array_length(back_chars); k++)
    {
        if (back_chars[k] == _char)
        {
            array_delete(back_chars, k, 1);
            break;
        }
    }

    // 2. 前场有人：那个人排到后场队尾（右边），
    //    如果左边没人，它的下标就是 0，也就是自动站到左边
    if (front_char != noone && instance_exists(front_char))
    {
        back_chars[array_length(back_chars)] = front_char;
    }

    // 3. 目标上场
    front_char = _char;
};

// 阵亡的角色，按阵亡顺序排列
dead_chars = [];

// 角色阵亡
character_die = function(_char)
{
    if (_char.is_dead) return;

    _char.is_dead = true;

    // 失去作战能力的形态
    if (variable_instance_exists(_char, "dead_spr"))
    {
        _char.sprite_index = _char.dead_spr;
    }
    else
    {
        _char.image_blend = c_dkgray;
    }

    // 从前场 / 后场移除
    if (front_char == _char)
    {
        front_char = noone;
    }
    else
    {
        for (var k = 0; k < array_length(back_chars); k++)
        {
            if (back_chars[k] == _char)
            {
                array_delete(back_chars, k, 1);
                break;
            }
        }
    }

    // 记录阵亡顺序：第 1 个退到后场下方，第 2 个退到后场上方
    dead_chars[array_length(dead_chars)] = _char;

    // 前场空了：后场上方活着的角色上场
    if (front_char == noone && array_length(back_chars) > 0)
    {
        front_char = back_chars[0];
        array_delete(back_chars, 0, 1);
    }

    // 没有活着的角色了：战斗失败
    if (front_char == noone)
    {
        battle_lost();
    }
};
// 把队伍当前血量写回全局记录（战斗胜利时调用）
party_save_hp = function()
{
    for (var p = 0; p < array_length(party_insts); p++)
    {
        if (instance_exists(party_insts[p]))
        {
            global.party_hp[p] = party_insts[p].hp;
        }
    }
};
// 敌人阵亡：直接消失，后面的敌人自动前移补位
// 敌人阵亡：直接消失，后面的敌人自动前移补位
enemy_die = function(_enemy)
{
    // 窃尸：其他敌人死亡时，带有窃尸的敌人恢复 8 点生命并获得 1 点力量
    for (var ck = 0; ck < array_length(enemies); ck++)
    {
        var thief = enemies[ck];

        if (thief != _enemy && instance_exists(thief) && get_status(thief, StatusType.CORPSE_THIEF) > 0)
        {
            heal_hp(thief, 8);
            add_status(thief, StatusType.STRENGTH, 1);
        }
    }

    // 从敌人列表移除（后面的敌人自动前移补位）
    for (var k = 0; k < array_length(enemies); k++)
    {
        if (enemies[k] == _enemy)
        {
            array_delete(enemies, k, 1);
            break;
        }
    }

    with (_enemy)
    {
        instance_destroy();
    }

    // 所有敌人阵亡：战斗胜利
    if (array_length(enemies) == 0)
    {
        battle_won();
    }
};

// 战斗胜利（占位：之后在这里接奖励、调用 reset_cards_to_battle_start() 等）
battle_won = function()
{
    party_save_hp();
    start_reward();
};

// 战斗失败（占位）
battle_lost = function()
{
    turn_state = "lost";
};




// 敌人站位（右侧）：下标 0 = 前场，1 = 后场上方，2 = 后场下方
enemy_slot_x = [room_width * 0.64, room_width * 0.84, room_width * 0.84];
enemy_slot_y = [room_height * 0.55, room_height * 0.40, room_height * 0.70];

// 没经过地图、直接运行战斗房间时，随机一个弱怪遭遇，方便测试
if (!variable_global_exists("encounter") || is_undefined(global.encounter))
{
    global.encounter = encounter_generate(0);
}

// 生成一个怪物放在第 _slot 个站位（0 = 前场，1 = 后场上方，2 = 后场下方）
spawn_enemy = function(_mid, _slot)
{
    var e = instance_create_layer(enemy_slot_x[_slot], enemy_slot_y[_slot], "Instances", obj_enemy_1);

    monster_setup(e, _mid);

    return e;
};

enemies = [];

for (var ei = 0; ei < array_length(global.encounter.start); ei++)
{
    enemies[ei] = spawn_enemy(global.encounter.start[ei], ei);
}

// 战斗回合数（第几个我方回合）
battle_round = 1;

// 蛙的"令你下回合第一张牌费用+1"：pending 是敌人刚施加的，first 是当前回合生效的
pending_cost_up = 0;
first_cost_up = 0;

// 敌人回合里正在轮到第几个敌人行动
// 敌人回合的步骤："attack" = 前场出手，"rotate" = 轮换站位
enemy_phase = "attack";
enemy_acted = 0;           // 本回合已经出手的敌人数
enemy_rotate_delay = 30;   // 出手后多少帧开始轮换（enemy_delay 是轮换后到下次出手的间隔）

// 敌人显示在普通角色图层后面


character_in_back = true;
// 初始抽取五张
for (var i = 0; i < 5 && deck_index < array_length(deck); i++)
{
    var card = card_spawn_from_entry(deck[deck_index], room_width * 0.5, room_height - 115);
    deck_index++;

    card.is_dealing = false;
    hand[array_length(hand)] = card;
}
// 延迟触发的效果队列
pending_effects = [];

// 下回合额外获得的费用（抽牌效果之外的加费）
next_turn_energy_bonus = 0;

// 抽 _n 张牌：手牌满了就停，抽牌堆空了就把弃牌堆洗回去
draw_cards = function(_n)
{
    repeat (_n)
    {
        // 手牌已满：不再抽
        if (array_length(hand) >= max_hand_size) break;

        // 抽牌堆空了：尝试把弃牌堆洗回去
        if (deck_index >= array_length(deck) && array_length(discard_pile) > 0)
        {
            deck = array_shuffle(discard_pile);
            deck_index = 0;
            discard_pile = [];
        }

        // 有牌才抽
       if (deck_index < array_length(deck))
{
    var new_card = card_spawn_from_entry(deck[deck_index], room_width * 0.5, room_height - 115);
    deck_index++;

    new_card.is_dealing = true;
    hand[array_length(hand)] = new_card;
}
    }    // 抽完牌后检查有没有可以合成的
    check_merge();
};

// 把手牌里的一张牌移除并销毁（不进弃牌堆）
remove_card_from_hand = function(_c)
{
    for (var k = 0; k < array_length(hand); k++)
    {
        if (hand[k] == _c)
        {
            array_delete(hand, k, 1);
            break;
        }
    }

    if (instance_exists(_c))
    {
        with (_c)
        {
            instance_destroy();
        }
    }
};

// 检查手牌里有没有 3 张同名的可合成牌，有就合成
check_merge = function()
{
    var merged_any = true;

    // 合成后可能又凑成新的三张，所以循环到没有可合成的为止
    while (merged_any)
    {
        merged_any = false;

        for (var cid = 1; cid <= 30; cid++)
        {
            if (!card_can_merge(cid)) continue;

            // 找出手牌里所有这个编号的牌（正在拖动的不算）
            var same = [];

            for (var i = 0; i < array_length(hand); i++)
            {
                var c = hand[i];

                if (instance_exists(c) && c != drag_card && c.card_id == cid)
                {
                    same[array_length(same)] = c;
                }
            }

            if (array_length(same) < 3) continue;

            // 取前三张，其中数值最大的一张翻倍
            var best = same[0];

            for (var t = 1; t < 3; t++)
            {
                if (card_power(same[t]) > card_power(best))
                {
                    best = same[t];
                }
            }

            // 另外两张移除
            for (var t2 = 0; t2 < 3; t2++)
            {
                if (same[t2] != best)
                {
                    remove_card_from_hand(same[t2]);
                }
            }

            card_double_effects(best);

            // 手牌变了，重新检查一遍
            merged_any = true;
            break;
        }
    }
};
// 把一张牌洗入抽牌堆：随机插到还没抽到的牌之间
shuffle_into_deck = function(_card_obj)
{
    if (_card_obj == -1) return;

    // 抽牌堆里还没抽的部分是 deck[deck_index ..]，随机选一个位置插入
    var remaining = array_length(deck) - deck_index;
    var pos = deck_index + irandom(remaining);

    array_insert(deck, pos, card_make_entry(_card_obj));
};

// 战斗结束时调用：把卡牌全部恢复成战斗开始时的样子
reset_cards_to_battle_start = function()
{
	countdowns = [];
turn_played_ids = [];
discover_queue = [];
attack_used_this_turn = array_create(5, false);
attack_used_last_turn = array_create(5, false);
witch_chant_used = false;
starter_played_this_turn = array_create(5, false);
starfire_ready = false;
wind_blade_bonus = 0;
rock_wall_ready = false;
selection_active = false;
selection_cards = [];
selection_action = { kind: "" };
selection_queue = [];
    // 销毁手上所有卡牌实例
    for (var i = 0; i < array_length(hand); i++)
    {
        var c = hand[i];

        if (instance_exists(c))
        {
            with (c)
            {
                instance_destroy();
            }
        }
    }

    hand = [];
    drag_card = noone;
    hover_card = noone;

    // 用战斗开始时记录的牌重新组牌堆：洗入的牌消失，消耗掉的牌回来
    card_pool = copy_array(global.card_collection);
    deck = array_shuffle(card_entries_from_objects(card_pool));
    deck_index = 0;
    discard_pile = [];

    // 清掉没触发完的延迟效果和下回合加费
    pending_effects = [];
    next_turn_energy_bonus = 0;

    // 元素共鸣只在本场战斗有效
    // 本场战斗里获得的状态全部清掉（元素共鸣、力量、敏捷、剑招）
for (var ci = 1; ci <= 4; ci++)
{
    var cc = variable_instance_get(id, "char_" + string(ci));

    if (instance_exists(cc))
    {
        clear_status(cc, StatusType.RESONANCE);
        clear_status(cc, StatusType.STRENGTH);
        clear_status(cc, StatusType.DEXTERITY);
        clear_status(cc, StatusType.SWORD_FORM);
		clear_status(cc, StatusType.BLOOD);
		clear_status(cc, StatusType.DILIGENCE);
        clear_status(cc, StatusType.STARFIRE);
        clear_status(cc, StatusType.FROST_RAIN);
        clear_status(cc, StatusType.ROCK_WALL);
        clear_status(cc, StatusType.WITCH_CHANT);
    }
}
	// 发现界面和计数也一起重置
	for (var oi = 0; oi < array_length(discover_options); oi++)
{
    if (instance_exists(discover_options[oi]))
    {
        with (discover_options[oi])
        {
            instance_destroy();
        }
    }
}

discover_options = [];
discover_active = false;
discover_tag = "";
discover_46_unlocked = false;

// 状态牌记录和天赋计数
for (var si = 1; si <= 4; si++)
{
    var sc = variable_instance_get(id, "char_" + string(si));

    if (instance_exists(sc))
    {
        sc.state_card_id = 0;
    }
}

if (instance_exists(char_3))
{
    char_3.talent_count = 0;
}

};



// 角色3机制：打出攻击牌计数，满 discover_need 张触发"发现"
// 29 号牌打出后，本场战斗发现时可以出现 46 号牌
discover_46_unlocked = false;        
discover_active = false;    // 发现界面是否打开
discover_options = [];      // 三张备选牌（卡牌实例，不可见，由 Draw GUI 画出）
discover_scale = 1.5;       // 备选牌的显示大小（相对于手牌原始大小）

// ---------- 通用手牌选择界面 ----------
selection_active = false;
selection_mode = "single";
selection_filter_id = 0;       // 0=任意牌，-1=苏灵兮初始牌，正数=指定牌编号
selection_min = 1;
selection_max = 1;
selection_cards = [];
selection_action = { kind: "" };
selection_queue = [];

selection_has = function(_card)
{
    for (var i = 0; i < array_length(selection_cards); i++)
    {
        if (selection_cards[i] == _card) return true;
    }
    return false;
};

selection_can_select = function(_card)
{
    if (!instance_exists(_card)) return false;
    if (selection_filter_id == -1) return (_card.card_id >= 1 && _card.card_id <= 4);
    if (selection_filter_id > 0) return _card.card_id == selection_filter_id;
    return true;
};

selection_start = function(_filter, _mode, _min, _max, _action)
{
    // 先检查是否还有足够的候选牌，避免聚能重复选择时出现无法确认的空界面
    var available = 0;
    for (var ai = 0; ai < array_length(hand); ai++)
    {
        var candidate = hand[ai];
        if (!instance_exists(candidate)) continue;

        var allowed = (_filter == 0)
            || (_filter == -1 && candidate.card_id >= 1 && candidate.card_id <= 4)
            || (_filter > 0 && candidate.card_id == _filter);

        if (allowed) available++;
    }

    if (available < _min)
    {
        warning_text = "没有足够的可选手牌";
        warning_timer = 60;
        return;
    }

    if (selection_active)
    {
        selection_queue[array_length(selection_queue)] = {
            filter_id: _filter, mode: _mode, min: _min, max: _max, action: _action
        };
        return;
    }

    selection_active = true;
    selection_filter_id = _filter;
    selection_mode = _mode;
    selection_min = _min;
    selection_max = _max;
    selection_cards = [];
    selection_action = _action;
    drag_card = noone;
    hover_card = noone;
    hand_collapsed = false;
};

selection_toggle = function(_card)
{
    if (!selection_can_select(_card)) return;

    var found = -1;
    for (var i = 0; i < array_length(selection_cards); i++)
    {
        if (selection_cards[i] == _card) { found = i; break; }
    }

    if (found >= 0)
    {
        array_delete(selection_cards, found, 1);
        return;
    }

    if (array_length(selection_cards) >= selection_max) return;
    selection_cards[array_length(selection_cards)] = _card;
};

selection_finish = function()
{
    if (array_length(selection_cards) < selection_min)
    {
        warning_text = "请至少选择" + string(selection_min) + "张牌";
        warning_timer = 60;
        return;
    }

    var picked = copy_array(selection_cards);
    var action = selection_action;

    switch (action.kind)
    {
        case "fireball_aoe":
        {
            var damage = card_current_damage(picked[0]);
            remove_card_from_hand(picked[0]);
            var all_en = copy_array(enemies);
            for (var i = 0; i < array_length(all_en); i++)
            {
                if (instance_exists(all_en[i])) deal_damage(all_en[i], damage, DamageType.MAGIC);
            }
        }
        break;

        case "wind_shield":
        {
            var total = 0;
            for (var i = 0; i < array_length(picked); i++)
            {
                if (instance_exists(picked[i])) total += card_current_damage(picked[i]);
            }
            for (var i = 0; i < array_length(picked); i++) remove_card_from_hand(picked[i]);

            // 零张风刃时不产生护甲，也不单独触发敏捷或全局护甲加成
            if (array_length(picked) > 0)
            {
                var shield_amount = card_effect_value({ type: EffectType.ARMOR, amount: total * 2 });
                shield_amount += get_status(char_1, StatusType.DEXTERITY);
                if (get_status(char_1, StatusType.ROCK_WALL) > 0) shield_amount *= 2;

                add_armor(char_1, ArmorType.GENERAL, shield_amount);
            }
        }
        break;

        case "wind_feather":
        {
            remove_card_from_hand(picked[0]);
            if (array_length(enemies) > 1)
            {
                var front_enemy = enemies[0];
                array_delete(enemies, 0, 1);
                enemies[array_length(enemies)] = front_enemy;
            }
            wind_blade_bonus += 2;
        }
        break;

        case "convert_rockshield":
        {
            var chosen = picked[0];
            chosen.card_id = 4;
            chosen.sprite_index = object_get_sprite(card_get_object(4));
            chosen.image_index = 0;
            chosen.effects = card_copy_effects(card_get_effects(4));
            chosen.merge_level = 0;
            chosen.cost = card_get_cost(4);
            rock_wall_ready = true;
            check_merge();
        }
        break;

        case "compress":
        {
            var chosen = picked[0];
            var entry = card_entry_from_instance(chosen);
            var upgraded = card_spawn_from_entry(entry, -1000, -1000);
            card_double_effects(upgraded);
            var upgraded_entry = card_entry_from_instance(upgraded);
            with (upgraded) instance_destroy();
            remove_card_from_hand(chosen);
            countdown_add(1, 2, [
                { type: EffectType.ADD_ENTRY_TO_HAND, amount: 1, entry: upgraded_entry }
            ]);
        }
        break;
    }

    selection_active = false;
    selection_cards = [];
    selection_action = { kind: "" };

    // 聚能等效果可能连续要求选择多次，完成当前选择后继续下一项
    if (array_length(selection_queue) > 0)
    {
        var next_selection = selection_queue[0];
        array_delete(selection_queue, 0, 1);
        selection_start(next_selection.filter_id, next_selection.mode,
            next_selection.min, next_selection.max, next_selection.action);
    }
};

wind_blade_bonus = 0;
rock_wall_ready = false;
// 左下：抽牌按钮（在"抽牌堆/弃牌堆"文字上方）
button_x1 = 25;
button_x2 = 190;
button_y1 = room_height - 150;
button_y2 = room_height - 80;

// 右下：回合结束按钮（在"收起手牌"提示上方）
end_button_x1 = room_width - 190;
end_button_x2 = room_width - 25;
end_button_y1 = room_height - 260;
end_button_y2 = room_height - 190;

// 按钮状态
button_flash = 0;


// 手牌显示状态
hand_collapsed = false;

// 右下角收起牌堆的位置
collapsed_x = room_width - 100;
collapsed_y = room_height - 100;

// 收起后卡牌的显示尺寸
collapsed_scale = 0.22;
// 被选中、准备保留的手牌
selected_cards = [];

// 拖动开始时的位置
drag_start_x = 0;
drag_start_y = 0;
drag_start_mouse_x = 0;
drag_start_mouse_y = 0;

// 是否真的拖动过
drag_moved = false;

// 点击选择时，卡牌向上移动的距离
selected_offset_y = 28;
// 回合状态："player" 或 "enemy"
turn_state = "player";

// 敌人行动计时(让敌人"想一会儿"再出手)
enemy_timer = 0;
enemy_delay = 45;   // 60帧 = 1秒

// 费用
max_energy = 3;
energy = 3;

// 费用显示的位置：手牌右侧（按你的画面自己微调）
energy_x = room_width * 0.5 + 400;
energy_y = room_height - 115;

// "费用不足"提示
warning_text = "";
warning_timer = 0;
max_hand_size = 10;

// 悬停
hover_card = noone;
hover_raise = 40;                    // 悬停时上浮的像素
hover_scale = 1.08;                  // 悬停牌的放大倍数（1 = 不放大）
preview_height = room_height * 0.35; // 预览大图的显示高度
// 开局抽的五张牌也要检查一次合成
// 检查手牌里有没有 3 张"同名且合成等级相同"的牌，有就合成
check_merge = function()
{
    var merged_any = true;

    // 合成后可能又凑成新的三张，所以循环到没有可合成的为止
    while (merged_any)
    {
        merged_any = false;

        for (var cid = 1; cid <= 30; cid++)
        {
            if (!card_can_merge(cid)) continue;

            // 找出手牌里这个编号的所有牌（正在拖动的不算），记下最高合成等级
            var same = [];
            var max_lvl = 0;

            for (var i = 0; i < array_length(hand); i++)
            {
                var c = hand[i];

                if (instance_exists(c) && c != drag_card && c.card_id == cid)
                {
                    same[array_length(same)] = c;
                    max_lvl = max(max_lvl, card_merge_level(c));
                }
            }

            // 按合成等级分组：只有等级相同的三张才能合成
            for (var lvl = 0; lvl <= max_lvl; lvl++)
            {
                var group = [];

                for (var g = 0; g < array_length(same); g++)
                {
                    if (card_merge_level(same[g]) == lvl)
                    {
                        group[array_length(group)] = same[g];
                    }
                }

                if (array_length(group) < 3) continue;

                // 取前三张，其中数值最大的一张翻倍
                var best = group[0];

                for (var t = 1; t < 3; t++)
                {
                    if (card_power(group[t]) > card_power(best))
                    {
                        best = group[t];
                    }
                }

                // 另外两张移除
                for (var t2 = 0; t2 < 3; t2++)
                {
                    if (group[t2] != best)
                    {
                        remove_card_from_hand(group[t2]);
                    }
                }

                // 合成等级 +1
                card_double_effects(best);

                merged_any = true;
                break;
            }

            // 手牌变了，重新检查一遍
            if (merged_any) break;
        }
    }
};

// 开始发现：暂停游戏，在中央摆出随机三张剑招牌
// 开始发现：暂停游戏，从 _pool（卡牌对象数组）里随机摆出三张供选择

start_discover = function(_pool, _count, _tag)
{
    if (is_undefined(_tag)) _tag = "";

    // 默认抽取三张
    if (is_undefined(_count)) _count = 3;

    // 随机取牌（不重复）
    var pool = array_shuffle(_pool);
    var n = min(_count, array_length(pool));

    if (n <= 0) return;

    // 备选牌之间的间距：按牌宽算
    var card_w = sprite_get_width(object_get_sprite(pool[0])) * discover_scale * 1.15;

    discover_options = [];

    for (var i = 0; i < n; i++)
    {
        var opt = card_spawn_from_entry(
            card_make_entry(pool[i]),
            room_width * 0.5 + (i - (n - 1) * 0.5) * card_w,
            room_height * 0.45
        );

        // 记下原始大小，放大显示
        opt.opt_base_xscale = opt.image_xscale;
        opt.opt_base_yscale = opt.image_yscale;
        opt.image_xscale *= discover_scale;
        opt.image_yscale *= discover_scale;
        opt.visible = false;

        discover_options[i] = opt;
    }

    hover_card = noone;
    discover_tag = _tag;
    discover_active = true;
};

request_discover = function(_pool, _count, _tag)
{
    if (is_undefined(_tag)) _tag = "";
    var req = { pool: _pool, count: is_undefined(_count) ? 3 : _count, tag: _tag };

    if (discover_active)
    {
        discover_queue[array_length(discover_queue)] = req;
    }
    else
    {
        start_discover(req.pool, req.count, req.tag);
    }
};
// 选中其中一张：它进入手牌，另外两张消失，游戏继续
pick_discover = function(_chosen)
{
    for (var i = 0; i < array_length(discover_options); i++)
    {
        var opt = discover_options[i];

        if (opt != _chosen && instance_exists(opt))
        {
            with (opt)
            {
                instance_destroy();
            }
        }
    }

    // 选中的牌：先记好手牌里的原始大小（它会从中央放大状态缩回手牌）
    _chosen.hand_base_xscale = _chosen.opt_base_xscale;
    _chosen.hand_base_yscale = _chosen.opt_base_yscale;
    _chosen.visible = true;
    _chosen.is_dealing = true;

    hand[array_length(hand)] = _chosen;

    // 阅读发现的牌：本回合打出时额外获得1费
    if (discover_tag == "reading")
    {
        _chosen.reading_bonus = true;
    }

    discover_options = [];
    discover_active = false;
	// 有排队的发现：接着进行下一个
if (array_length(discover_queue) > 0)
{
    var next_req = discover_queue[0];
    array_delete(discover_queue, 0, 1);
    start_discover(next_req.pool, next_req.count, next_req.tag);
}
};

// 把一张牌放进手牌；手牌满了就放进弃牌堆。_cost >= 0 时，这张牌的费用固定为 _cost
add_card_to_hand = function(_obj, _cost)
{
    var entry = card_make_entry(_obj);

    if (_cost >= 0)
    {
        entry.cost = _cost;
    }

    if (array_length(hand) >= max_hand_size)
    {
        discard_pile[array_length(discard_pile)] = entry;
        return;
    }

    var c = card_spawn_from_entry(entry, room_width * 0.5, room_height - 115);
    c.is_dealing = true;
    hand[array_length(hand)] = c;
};

// 弃置手牌里所有指定编号的牌（进入弃牌堆）
discard_cards_by_id = function(_id)
{
    for (var i = array_length(hand) - 1; i >= 0; i--)
    {
        var c = hand[i];

        if (instance_exists(c) && c.card_id == _id)
        {
            discard_pile[array_length(discard_pile)] = card_entry_from_instance(c);
            array_delete(hand, i, 1);

            with (c)
            {
                instance_destroy();
            }
        }
    }
};
// 全局护甲加成（提高获得护甲值的效果改这个）
global.armor_bonus = 0;
  if (!variable_global_exists("chinese_font"))
  {
      global.chinese_font = font_add("QingNiaoHuaGuangJianMeiHei-2.ttf", 24, false, false, 32, 65535);
  }
  
  // 带着阵亡状态进战斗的角色：开局就是阵亡形态
for (var p2 = 0; p2 < array_length(party_insts); p2++)
{
    if (variable_global_exists("party_hp") && p2 < array_length(global.party_hp) && global.party_hp[p2] <= 0)
    {
        character_die(party_insts[p2]);
    }
}
// ---------- 倒计时 ----------
countdowns = [];          // { owner: 角色编号, turns: 剩余回合, effects: [效果] }
turn_played_ids = [];     // 本回合打出过的牌编号
attack_used_this_turn = array_create(5, false);
attack_used_last_turn = array_create(5, false);
witch_chant_used = false;
starter_played_this_turn = array_create(5, false);
starfire_ready = false;
discover_queue = [];      // 排队等待的发现

countdown_add = function(_owner, _turns, _effects)
{
    countdowns[array_length(countdowns)] = { owner: _owner, turns: _turns, effects: _effects };
};

// 倒计时到 0：立刻触发后续的效果（角色已阵亡就作废）
countdown_fire = function(_cd)
{
    var owner_inst = variable_instance_get(id, "char_" + string(_cd.owner));

    if (!char_is_alive(owner_inst)) return;

    for (var k = 0; k < array_length(_cd.effects); k++)
    {
        var e = _cd.effects[k];

        if (variable_struct_exists(e, "conditional_no_attack")
        &&  e.conditional_no_attack
        &&  attack_used_last_turn[_cd.owner])
        {
            continue;
        }

        // 只有伤害或对敌方施加的状态才需要敌方目标
        var needs_enemy = (e.type == EffectType.DAMAGE
            || e.type == EffectType.DAMAGE_ARMOR_TOTAL
            || (e.type == EffectType.STATUS && !variable_struct_exists(e, "on_char")));

        var en = noone;
        if (needs_enemy && array_length(enemies) > 0) en = enemies[0];
        if (needs_enemy && !instance_exists(en)) continue;

        var fire_value = card_effect_value(e);

        // 倒计时获得护甲同样受敏捷、全局护甲加成与地岳·镇垒影响
        if (e.type == EffectType.ARMOR)
        {
            var armor_receiver = effect_target_char(e, owner_inst);
            if (instance_exists(armor_receiver))
            {
                fire_value += get_status(armor_receiver, StatusType.DEXTERITY);
                if (get_status(armor_receiver, StatusType.ROCK_WALL) > 0) fire_value *= 2;
            }
        }

        card_apply_effect(e, fire_value, owner_inst, en);
    }
};

// 回合开始：所有倒计时 -1
countdown_tick = function()
{
    for (var i = array_length(countdowns) - 1; i >= 0; i--)
    {
        var cd = countdowns[i];
        cd.turns--;

        if (cd.turns <= 0)
        {
            array_delete(countdowns, i, 1);
            countdown_fire(cd);
        }
    }
};

// 令某角色所有倒计时增减 _delta（灵光一现）
countdown_shift = function(_owner, _delta)
{
    for (var i = array_length(countdowns) - 1; i >= 0; i--)
    {
        var cd = countdowns[i];

        if (cd.owner != _owner) continue;

        cd.turns += _delta;

        if (cd.turns <= 0)
        {
            array_delete(countdowns, i, 1);
            countdown_fire(cd);
        }
    }
};

// ---------- 手牌和牌堆操作 ----------

// 手牌里有没有这个编号的牌（不算 _exclude 这一张）
hand_has_card = function(_card_id, _exclude)
{
    for (var i = 0; i < array_length(hand); i++)
    {
        var c = hand[i];

        if (c != _exclude && instance_exists(c) && c.card_id == _card_id) return true;
    }

    return false;
};

// 消耗手牌里一张指定编号的牌（直接销毁，不进弃牌堆）
consume_from_hand = function(_card_id)
{
    for (var i = 0; i < array_length(hand); i++)
    {
        var c = hand[i];

        if (instance_exists(c) && c.card_id == _card_id)
        {
            array_delete(hand, i, 1);

            with (c)
            {
                instance_destroy();
            }

            return true;
        }
    }

    return false;
};

// 令手牌里所有指定编号的牌伤害 +N
buff_hand_damage = function(_card_id, _n)
{
    for (var i = 0; i < array_length(hand); i++)
    {
        var c = hand[i];

        if (instance_exists(c) && c.card_id == _card_id)
        {
            c.effects = effects_add_damage(card_current_effects(c), _n);
        }
    }
};

// 令手牌里所有的牌保留一回合
retain_all_hand = function()
{
    for (var i = 0; i < array_length(hand); i++)
    {
        if (instance_exists(hand[i])) hand[i].retain_once = true;
    }
};

// 把一张指定编号的牌置入手牌（手牌满了进弃牌堆）。_cost >= 0 固定费用，_bonus 是伤害加成
add_card_to_hand_id = function(_card_id, _cost, _bonus)
{
    var o = card_get_object(_card_id);

    if (o == -1) return;

    var entry = card_make_entry(o);

    if (_cost >= 0) entry.cost = _cost;

    if (_bonus != 0)
    {
        entry.effects = effects_add_damage(card_get_effects(_card_id), _bonus);
    }

    if (array_length(hand) >= max_hand_size)
    {
        discard_pile[array_length(discard_pile)] = entry;
        return;
    }

    var c = card_spawn_from_entry(entry, room_width * 0.5, room_height - 115);
    c.is_dealing = true;
    hand[array_length(hand)] = c;

    check_merge();
};

// 从抽牌堆里抽取指定编号的牌（最多 _n 张）
draw_specific = function(_card_id, _n)
{
    var o = card_get_object(_card_id);
    var got = 0;

    for (var i = array_length(deck) - 1; i >= deck_index && got < _n; i--)
    {
        if (deck[i].obj != o) continue;
        if (array_length(hand) >= max_hand_size) break;

        var c = card_spawn_from_entry(deck[i], room_width * 0.5, room_height - 115);
        c.is_dealing = true;
        hand[array_length(hand)] = c;

        array_delete(deck, i, 1);
        got++;
    }

    check_merge();
};

// 移动至后场：后场上方的角色上场，前场的这个角色退到后场
send_to_back = function(_char)
{
    if (!char_is_alive(_char)) return;
    if (front_char != _char) return;
    if (array_length(back_chars) == 0) return;

    bring_to_front(back_chars[0]);
};

// 前后场轮换：前场角色退至后场，后场角色进入前场
rotate_character = function(_char)
{
    if (!char_is_alive(_char)) return;

    if (front_char == _char)
    {
        send_to_back(_char);
    }
    else
    {
        bring_to_front(_char);
    }
};

// 本角色所有能发现的牌
discover_pool_char = function(_n)
{
    var pool = [];
    var card_range = character_get_card_range(_n);

    if (array_length(card_range) == 0) return pool;

    for (var cn = card_range[0]; cn <= card_range[1]; cn++)
    {
        if (!card_in_pool(cn)) continue;

        var o = card_get_object(cn);

        if (o != -1) pool[array_length(pool)] = o;
    }

    return pool;
};



// 战斗奖励
reward_options = [];
reward_gold = 0;
reward_scale = 1.3;

skip_x1 = room_width * 0.5 - 90;
skip_x2 = room_width * 0.5 + 90;
skip_y1 = room_height * 0.84;
skip_y2 = room_height * 0.84 + 50;

// 开始奖励：金币 3~5，然后三选一卡牌
start_reward = function()
{
    if (!variable_global_exists("gold")) global.gold = 0;

    reward_gold = irandom_range(3, 5);
    global.gold += reward_gold;

    var ids = reward_roll_cards(3);
    var n = array_length(ids);

    reward_options = [];

    if (n > 0)
    {
        var card_w = sprite_get_width(object_get_sprite(card_get_object(ids[0]))) * reward_scale * 1.15;

        for (var i = 0; i < n; i++)
        {
            var opt = card_spawn_from_entry(
                card_make_entry(card_get_object(ids[i])),
                room_width * 0.5 + (i - (n - 1) * 0.5) * card_w,
                room_height * 0.5
            );

            opt.image_xscale *= reward_scale;
            opt.image_yscale *= reward_scale;
            opt.visible = false;

            reward_options[i] = opt;
        }
    }

    turn_state = "reward";
};

// 选择（或跳过）奖励后离开：选中的牌加入牌组，回到地图
finish_reward = function(_chosen)
{
    if (_chosen != noone)
    {
        global.card_collection[array_length(global.card_collection)] = _chosen.object_index;
    }

    room_goto(rm_map);
};