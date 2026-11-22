
/// obj_hand_controller - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// ---------------------------------
// 战斗奖励：只处理三选一和跳过
// ---------------------------------
if (turn_state == "reward")
{
    if (mouse_check_button_pressed(mb_left))
    {
        for (var wi = 0; wi < array_length(reward_options); wi++)
        {
            var wopt = reward_options[wi];

            if (instance_exists(wopt) && position_meeting(mx, my, wopt))
            {
                finish_reward(wopt);
                exit;
            }
        }

        if (mx >= skip_x1 && mx <= skip_x2 && my >= skip_y1 && my <= skip_y2)
        {
            finish_reward(noone);
        }
    }

    exit;
}
// ---------------------------------
// 发现界面：暂停游戏，只处理三选一的点击
// （此时无法收起手牌、结束回合、抽牌，敌人回合和延迟效果也暂停）
// ---------------------------------
if (discover_active)
{
    if (mouse_check_button_pressed(mb_left))
    {
        for (var di = 0; di < array_length(discover_options); di++)
        {
            var dopt = discover_options[di];

            if (instance_exists(dopt) && position_meeting(mx, my, dopt))
            {
                pick_discover(dopt);
                break;
            }
        }
    }

    exit;
}

// ---------------------------------
// 手牌选择界面：只允许选择符合条件的手牌，右侧按钮确认
// ---------------------------------
var selection_was_active = selection_active;
if (selection_active && mouse_check_button_pressed(mb_left))
{
    if (mx >= end_button_x1 && mx <= end_button_x2
    &&  my >= end_button_y1 && my <= end_button_y2)
    {
        selection_finish();
    }
    else
    {
        for (var si = array_length(hand) - 1; si >= 0; si--)
        {
            var scard = hand[si];
            if (!instance_exists(scard)) continue;
            if (position_meeting(mx, my, scard))
            {
                if (selection_can_select(scard))
                {
                    selection_toggle(scard);
                }
                else
                {
                    warning_text = "这张牌不能选择";
                    warning_timer = 45;
                }
                break;
            }
        }
    }
}
if (warning_timer > 0) warning_timer--;
// 延迟触发的卡牌效果（比如 2 号牌两次伤害之间的间隔）
for (var di = array_length(pending_effects) - 1; di >= 0; di--)
{
    var pend = pending_effects[di];
    pend.timer--;

    if (pend.timer <= 0)
    {
        card_apply_effect(pend.effect, pend.value, pend.target, pend.enemy);
        array_delete(pending_effects, di, 1);
    }
}

// ---------------------------------
// 0. 敌人回合：出手 → 轮换 → 出手 → 轮换 → 出手
// ---------------------------------
if (turn_state == "enemy")
{
    enemy_timer++;

    // 出手前等 enemy_delay 帧；出手后等 enemy_rotate_delay 帧再轮换
    var enemy_wait = (enemy_phase == "attack") ? enemy_delay : enemy_rotate_delay;

    if (enemy_timer >= enemy_wait)
    {
        enemy_timer = 0;

        if (enemy_phase == "attack")
{
    // 当前前场的敌人行动
    var attacker = (array_length(enemies) > 0) ? enemies[0] : noone;

    if (instance_exists(attacker))
    {
        monster_take_turn(attacker);
    }

    enemy_phase = "rotate";
}
        else if (enemies_any_pending())
        {
            // 还有敌人没出手：前场退到后场下方，上方进前场，下方挪到上方
            var rot_en = enemies[0];
            array_delete(enemies, 0, 1);
            enemies[array_length(enemies)] = rot_en;

            enemy_phase = "attack";
        }
        turn_state = "player";

// 战斗回合数 +1，按遭遇表让增援入场
battle_round++;

for (var ri = 0; ri < array_length(global.encounter.reinf); ri++)
{
    var rf = global.encounter.reinf[ri];

    if (rf.round == battle_round && array_length(enemies) < 3)
    {
        enemies[array_length(enemies)] = spawn_enemy(rf.id, array_length(enemies));
    }
}

// 敌人"令你下回合第一张牌费用+1"在这个回合生效
first_cost_up = pending_cost_up;
pending_cost_up = 0;

// 基础费用 + 上回合效果带来的额外费用，用完后清零
energy = max_energy + next_turn_energy_bonus;
next_turn_energy_bonus = 0;

// 本回合打出的牌记录清零
turn_played_ids = [];
wind_blade_bonus = 0;
witch_chant_used = false;

// 新回合：护甲清零（疾风步的"护甲保留"这一次不清零）；临时魔力、熔岩加护结束
with (obj_character_1)
{
    if (get_status(id, StatusType.ARMOR_KEEP) > 0)
    {
        clear_status(id, StatusType.ARMOR_KEEP);
    }
    else
    {
        armor_general = 0;
        armor_physical = 0;
        armor_magic = 0;
    }

    clear_status(id, StatusType.TEMP_MAGIC);
    clear_status(id, StatusType.LAVA_WARD);
    clear_status(id, StatusType.ROCK_WALL);
}

// 新回合：星光可以再次使用
if (instance_exists(char_2))
{
    char_2.starlight_used = false;
}

// 倒计时：所有倒计时 -1，到 0 的立刻触发
countdown_tick();

if (char_is_alive(char_1))
{
    // 元素共鸣：每回合开始，倒计时1：将一张随机的元素牌洗入抽牌堆（每层一个）
    repeat (get_status(char_1, StatusType.RESONANCE))
    {
        countdown_add(1, 1, [ { type: EffectType.SHUFFLE_ELEMENT, amount: 1 } ]);
    }

    // 阅读：每回合开始，发现一张本角色的牌
    repeat (get_status(char_1, StatusType.READING))
    {
        request_discover(discover_pool_char(1), 3);
    }

    // 风息庭：每回合开始，将一张风刃置入手牌
    repeat (get_status(char_1, StatusType.WIND_COURT))
    {
        add_card_to_hand_id(2, -1, 0);
    }
}

// 精进：每回合开始，每层往手牌里放一张 0 费的练心
if (char_is_alive(char_3))
{
    repeat (get_status(char_3, StatusType.DILIGENCE))
    {
        add_card_to_hand(obj_card_208, 0);
    }
}

// 抽 5 张牌
draw_cards(5);
    }
}

// ---------------------------------
// 0.5 悬停检测：找出鼠标下最上层的手牌
// ---------------------------------
hover_card = noone;

if (turn_state == "player" && !selection_active && !hand_collapsed && drag_card == noone)
{
    // 从后往前找，优先选中最上层的牌
    for (var i = array_length(hand) - 1; i >= 0; i--)
    {
        var c = hand[i];

        if (!instance_exists(c)) continue;
        if (!variable_instance_exists(c, "rest_x")) continue;

        // 用"静止位置"判断：牌上浮后鼠标不会掉出牌外，避免上下抖动
        var ox = c.rest_x - c.x;
        var oy = c.rest_y - c.y;

        if (position_meeting(mx - ox, my - oy, c))
        {
            hover_card = c;
            break;
        }
    }
}
// ---------------------------------
// 1. 鼠标按下：抽牌、收起手牌或开始拖牌
// ---------------------------------


    if (turn_state == "player" && !selection_was_active && !selection_active && mouse_check_button_pressed(mb_left))
{
	// 测试按钮：发现一张场上角色的牌（临时）
if (mx >= test_x1 && mx <= test_x2
&&  my >= test_y1 && my <= test_y2)
{
    start_discover(discover_pool_field());
}
// 回合结束按钮

    // 回合结束按钮
    else if (mx >= end_button_x1 && mx <= end_button_x2
    &&  my >= end_button_y1 && my <= end_button_y2)
    {
		// 出牌阶段结束：结算手牌里的回合结束效果（猩红）
for (var ei = 0; ei < array_length(hand); ei++)
{
    var ec = hand[ei];

    if (instance_exists(ec))
    {
        card_on_turn_end(ec);
    }
}
        // 把所有手牌放入弃牌堆，并销毁实例
       // 把手牌放入弃牌堆并销毁实例；带"保留"的牌留在手里
var kept_cards = [];

for (var i = 0; i < array_length(hand); i++)
{
    var c = hand[i];

    if (!instance_exists(c)) continue;

    if (card_has_retain(c.card_id) || (variable_instance_exists(c, "retain_once") && c.retain_once))
{
    c.retain_once = false;   // "保留一回合"只保留这一次
    kept_cards[array_length(kept_cards)] = c;
}
    else
    {
        discard_pile[array_length(discard_pile)] = card_entry_from_instance(c);

        with (c)
        {
            instance_destroy();
        }
    }
}

hand = kept_cards;
drag_card = noone;
        drag_card = noone;
// 检测前场是否有人
// 前场没人：让后场最左边的角色上场
if (front_char == noone || !instance_exists(front_char))
{
    front_char = noone;

    if (array_length(back_chars) > 0)
    {
        bring_to_front(back_chars[0]);
    }
}

        // 记录本回合每个角色是否使用过攻击牌，供下一回合倒计时判断
attack_used_last_turn = copy_array(attack_used_this_turn);
attack_used_this_turn = array_create(4, false);

// 轮到敌人

turn_state = "enemy";
enemy_timer = 0;
enemy_phase = "attack";
// 敌人回合开始：所有敌人标记为"还没行动"
for (var hi = 0; hi < array_length(enemies); hi++)
{
    if (instance_exists(enemies[hi]))
    {
        enemies[hi].has_acted = false;
    }
}
enemy_acted = 0;
    }
    // 抽牌按钮
   // 抽牌按钮
else if (mx >= button_x1 && mx <= button_x2
&&  my >= button_y1 && my <= button_y2)
{
    // 手牌已满：不抽牌，也不消耗牌堆
    if (array_length(hand) >= max_hand_size)
    {
        warning_text = "手牌已满";
        warning_timer = 90;
    }
    // 抽牌按钮
else if (mx >= button_x1 && mx <= button_x2
&&  my >= button_y1 && my <= button_y2)
{
    // 手牌已满：不抽牌，也不消耗牌堆
    if (array_length(hand) >= max_hand_size)
    {
        warning_text = "手牌已满";
        warning_timer = 90;
    }
    else
    {
        draw_cards(1);
    }
}
}
    // 收起或展开手牌
    else if (hand_collapsed)
    {
        if (mx >= room_width - 180
        &&  my >= room_height - 180)
        {
            hand_collapsed = false;
        }
    }
    else if (my < room_height * 0.42)
    {
        hand_collapsed = true;
    }
    // 手牌展开时，尝试抓起一张牌
    // 手牌展开时，抓起悬停的那张牌
else if (!hand_collapsed && hover_card != noone)
{
    drag_card = hover_card;

    drag_offset_x = drag_card.x - mx;
    drag_offset_y = drag_card.y - my;

    // 让被抓起的牌显示在最前面
    drag_card.depth = -10000;
// 指向型卡牌：拿起后卡牌凭空消失，改为显示箭头
if (card_needs_target(drag_card.card_id))
{
    drag_card.visible = false;
}
    // 开始拖动后不再显示预览
    hover_card = noone;
    }
}

// ---------------------------------
// 2. 拖动中的卡牌跟随鼠标
// ---------------------------------

if (drag_card != noone)
{
    if (instance_exists(drag_card))
    {
        if (mouse_check_button(mb_left))
{
	// 拖动的牌属于已阵亡的角色：持续提示
if (card_owner_dead(drag_card.card_id))
{
    warning_text = "该角色已阵亡";
    warning_timer = 30;
}
    // 指向型卡牌不跟随鼠标，留在原地（已隐藏），由箭头代替
    if (!card_needs_target(drag_card.card_id))
    {
        drag_card.x = mx + drag_offset_x;
        drag_card.y = my + drag_offset_y;

        // 拖动时回到原始大小
        drag_card.image_xscale = lerp(drag_card.image_xscale, drag_card.hand_base_xscale, 0.3);
        drag_card.image_yscale = lerp(drag_card.image_yscale, drag_card.hand_base_yscale, 0.3);
    }
}
	}


        // ---------------------------------
        // 3. 松开鼠标：判断是否打出卡牌
        // ---------------------------------

        if (mouse_check_button_released(mb_left))
{
    var released_card = drag_card;

var target = noone;          // 指向我方角色的牌：选中的我方角色
var target_enemy = noone;    // 指向敌方的牌：选中的敌人
var try_play = false;

var tkind = card_target_kind(released_card.card_id);

if (tkind == TargetKind.FRIEND)
{
    // 必须松手在我方角色身上才算打出
    target = instance_position(mx, my, obj_character_1);
    try_play = (target != noone);

    // 先把卡牌显示回来：打出会被销毁，没打出就飞回手牌
    released_card.visible = true;
}
else if (tkind == TargetKind.ENEMY)
{
    // 必须松手在敌人身上才算打出（前场、后场的敌人都可以）
    target_enemy = instance_position(mx, my, obj_enemy_1);
    try_play = (target_enemy != noone);

    released_card.visible = true;
}

else
{
    // 普通牌：卡牌中心高于屏幕中央才算打出
    try_play = (released_card.y < room_height * 0.5);
}
// 无法被打出的牌（猩红）：拖出去也回到手牌
if (try_play && card_is_unplayable(released_card.card_id))
{
    try_play = false;
    warning_text = "无法打出";
    warning_timer = 90;
}

// 这张牌的拥有者已阵亡：无法使用（通用牌没有拥有者，不受影响）
if (try_play && card_owner_dead(released_card.card_id))
{
    try_play = false;
    warning_text = "该角色已阵亡";
    warning_timer = 90;
}

// 指向我方的牌不能指向已阵亡的角色
if (try_play && target != noone && target.is_dead)
{
    try_play = false;
    warning_text = "该角色已阵亡";
    warning_timer = 90;
}
// 需要手牌里有指定的牌才能打出（比如风助火势需要风刃）
var need_id = card_requirement(released_card.card_id);

if (try_play && need_id > 0 && !hand_has_card(need_id, released_card))
{
    try_play = false;
    warning_text = "手牌中没有所需的牌";
    warning_timer = 90;
}
if (try_play)
{
        var released_id = released_card.card_id;
        var cost = card_current_cost(released_card) + first_cost_up;

var can_play = (energy >= cost);
var star_pay = 0;

// 费用不足时：角色2的牌可以用星光补差额（每回合限一次）
if (!can_play
&&  card_uses_starlight(released_id)
&&  instance_exists(char_2))
{
    var shortage = cost - energy;

    if (!char_2.starlight_used && char_2.starlight >= shortage)
    {
        can_play = true;
        star_pay = shortage;
    }
}

// 仍然不够：不打出，牌自动飞回手牌
if (!can_play)
{
    warning_text = "费用不足";
    warning_timer = 90;
}
else
{
    if (star_pay > 0)
    {
        // 先用完剩余费用，不够的部分用星光补
        energy = 0;
        char_2.starlight -= star_pay;
        char_2.starlight_used = true;
    }
    else
    {
        energy -= cost;
    }
	first_cost_up = 0;   // 本回合使用的第一张牌已经用掉了这个费用加成
	turn_played_ids[array_length(turn_played_ids)] = released_id;   // 记录本回合打出的牌

    var ctype = card_get_type(released_id);

    // 记录各角色本回合是否打出过攻击牌
    var attack_owner_n = card_get_owner(released_id);
    if (ctype == CardType.ATTACK && attack_owner_n > 0)
    {
        attack_used_this_turn[attack_owner_n] = true;
    }

// 攻击牌：对应角色先进入前场
// 攻击牌：所属角色先进入前场（通用攻击牌没有所属角色，不用换人）
if (ctype == CardType.ATTACK)
{
    var who = card_get_character(released_id);

    if (who > 0)
    {
        bring_to_front(variable_instance_get(id, "char_" + string(who)));
    }
    else if (target != noone)
    {
        // 通用攻击牌（打击）：被指定的友方角色上场出手
        // （不想让它上场，删掉下面这一行）
        bring_to_front(target);
    }
}
// 先把这张牌从手牌数组移除
// （这样"抽牌"效果检查手牌上限时，不会把这张已经打出的牌算进去）
for (var j = 0; j < array_length(hand); j++)
{
    if (hand[j] == released_card)
    {
        array_delete(hand, j, 1);
        break;
    }
}

// 状态牌打出后不进弃牌堆，其余牌进入弃牌堆
// 消耗牌（状态牌、剑招牌）打出后不进弃牌堆
if (!card_is_exhaust(released_id))
{
    discard_pile[array_length(discard_pile)] = card_entry_from_instance(released_card);
}
// 状态牌：一个角色同一时间只能有一个状态牌的效果，先顶掉旧的，再让新的生效
if (ctype == CardType.STATUS)
{
    var owner_n = card_get_owner(released_id);

    if (owner_n > 0)
    {
        state_card_played(variable_instance_get(id, "char_" + string(owner_n)), released_id);
    }
}
// 触发这张牌的所有效果（数值全部来自 scr_card_data）
var effect_target = (target != noone) ? target : front_char;
var front_enemy = (array_length(enemies) > 0) ? enemies[0] : noone;
// 指向敌人的牌作用在选中的敌人身上，其他牌作用在前场敌人身上
var hit_enemy = (target_enemy != noone) ? target_enemy : front_enemy;
// 聚能：本角色使用的下一张技能牌额外结算 1 次
var repeat_n = 1;
var card_owner = card_get_owner_instance(released_id);

// 星火与燎原：每回合第一张初始牌视为合成强化一次
if (card_is_starter(released_id) && char_is_alive(card_owner)
&& get_status(card_owner, StatusType.STARFIRE) > 0)
{
    card_double_effects(released_card);
    clear_status(card_owner, StatusType.STARFIRE);
}

if (ctype == CardType.SKILL && char_is_alive(card_owner) && get_status(card_owner, StatusType.OVERCHARGE) > 0)
{
    clear_status(card_owner, StatusType.OVERCHARGE);
    repeat_n = 2;
}

repeat (repeat_n)
{
    card_play_effects(released_card, effect_target, hit_enemy);
}

// 冰寒·落雨：下一张霜落对其他敌人各重复一次
if (released_id == 3 && char_is_alive(card_owner)
&& get_status(card_owner, StatusType.FROST_RAIN) > 0)
{
    clear_status(card_owner, StatusType.FROST_RAIN);
    var frost_targets = copy_array(enemies);
    for (var fi = 0; fi < array_length(frost_targets); fi++)
    {
        if (frost_targets[fi] != hit_enemy && instance_exists(frost_targets[fi]))
        {
            card_play_effects(released_card, effect_target, frost_targets[fi]);
        }
    }
}

// 女巫吟唱：每回合第一次打出初始牌，倒计时1后重放
if (card_is_starter(released_id) && char_is_alive(card_owner)
&& get_status(card_owner, StatusType.WITCH_CHANT) > 0 && !witch_chant_used)
{
    witch_chant_used = true;
    countdown_add(card_get_owner(released_id), 1,
        [ { type: EffectType.REPLAY_STARTER, card_id: released_id } ]);
}

// 销毁打出的卡牌实例
with (released_card)
{
    instance_destroy();
}

// 角色3的天赋：打出攻击牌 +1，累计到上限就归零并触发（发现）
if (char_is_alive(char_3) && card_counts_for_discover(released_id))
{
    char_3.talent_count++;

    if (char_3.talent_count >= char_3.talent_need)
    {
        char_3.talent_count = 0;
        request_discover(discover_pool_xinyu(discover_46_unlocked), 3);
    }
}

}
    }

    // 没打出（位置不够高或费用不足）都会回到手牌布局
    drag_card = noone;
}
}
// ---------------------------------
// 4. 手牌扇形排列
// ---------------------------------

var count = array_length(hand);

if (count > 0)
{
    var center_x = room_width * 0.5;
    var base_y = room_height - 115;
    var card_spacing = 90;
    var fan_height = 45;
    var max_angle = 20;

    for (var i = 0; i < count; i++)
    {
        var card = hand[i];

        if (!instance_exists(card))
        {
            continue;
        }

        // 被拖动的牌不参与自动排列
        if (card == drag_card)
        {
            continue;
        }

        // 保存卡牌原始缩放比例
        if (!variable_instance_exists(card, "hand_base_xscale"))
        {
            card.hand_base_xscale = card.image_xscale;
            card.hand_base_yscale = card.image_yscale;
        }

        var t = 0;

        if (count > 1)
        {
            t = (i / (count - 1)) * 2 - 1;
        }

        var target_x = center_x
            + (i - (count - 1) * 0.5) * card_spacing;

        var target_y = base_y
            - (1 - abs(t)) * fan_height;

        if (selection_active && selection_has(card)) target_y -= 35;

        var target_angle = -t * max_angle;

        // 收起手牌
        if (hand_collapsed)
        {
            target_x = collapsed_x + i * 2;
            target_y = collapsed_y - i * 2;
            target_angle = 0;
        }

        // 记录"静止位置"（不含悬停上浮），悬停检测用
			card.rest_x = target_x;
			card.rest_y = target_y;

		var target_scale = hand_collapsed
		 ? collapsed_scale
			: 1;

// 悬停：上浮并略微放大
			if (card == hover_card)
			{
		  target_y -= hover_raise;
		 target_scale = hover_scale;
		}


        // 平滑移动
        card.x = lerp(card.x, target_x, 0.18);
        card.y = lerp(card.y, target_y, 0.18);

        card.image_angle = lerp(
            card.image_angle,
            target_angle,
            0.18
        );

        card.image_xscale = lerp(
            card.image_xscale,
            card.hand_base_xscale * target_scale,
            0.18
        );

        card.image_yscale = lerp(
            card.image_yscale,
            card.hand_base_yscale * target_scale,
            0.18
        );

        if (point_distance(
            card.x,
            card.y,
            target_x,
            target_y
        ) < 0.8)
        {
            card.x = target_x;
            card.y = target_y;
        }

        card.depth = -i;
    }
}
// ---------------------------------
// 5. 角色站位排列
// ---------------------------------

if (front_char != noone && instance_exists(front_char))
{
    front_char.x = lerp(front_char.x, front_x, 0.18);
    front_char.y = lerp(front_char.y, front_y, 0.18);
}

for (var b = 0; b < array_length(back_chars); b++)
{
    var bc = back_chars[b];

    if (instance_exists(bc))
    {
        bc.x = lerp(bc.x, back_slot_x[b], 0.18);
        bc.y = lerp(bc.y, back_slot_y[b], 0.18);
    }
}
// 阵亡的角色：第 1 个在后场下方，第 2 个在后场上方
for (var di = 0; di < array_length(dead_chars); di++)
{
    var dc = dead_chars[di];

    if (!instance_exists(dc)) continue;

    var dslot = max(1 - di, 0);

    dc.x = lerp(dc.x, back_slot_x[dslot], 0.18);
    dc.y = lerp(dc.y, back_slot_y[dslot], 0.18);
}
// 敌人站位排列（下标 0 = 前场，1 = 后场上方，2 = 后场下方）
for (var ei = 0; ei < array_length(enemies); ei++)
{
    var en = enemies[ei];

    if (instance_exists(en))
    {
        en.x = lerp(en.x, enemy_slot_x[ei], 0.18);
        en.y = lerp(en.y, enemy_slot_y[ei], 0.18);
    }
}