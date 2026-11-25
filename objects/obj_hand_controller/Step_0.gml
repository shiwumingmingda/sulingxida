
/// obj_hand_controller - Step

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);



if (discard_choice_active)
{
    discard_choice_hover_card = noone;
    for (var di = array_length(discard_choice_options) - 1; di >= 0; di--)
    {
        var hover_opt = discard_choice_options[di];
        if (instance_exists(hover_opt.card)
        && card_point_inside_rotated(hover_opt.card, mx, my, 1.08))
        {
            discard_choice_hover_card = hover_opt.card;
            break;
        }
    }

    if (mouse_check_button_pressed(mb_left))
    {
        if (mx >= discard_choice_x1 && mx <= discard_choice_x2
        && my >= discard_choice_y1 && my <= discard_choice_y2)
        {
            discard_choice_finish();
            exit;
        }

        for (var di = 0; di < array_length(discard_choice_options); di++)
        {
            var opt = discard_choice_options[di];
            if (!instance_exists(opt.card)) continue;
            var old_y = opt.card.y;
            if (opt.card == discard_choice_hover_card) opt.card.y -= 24;
            var card_hit = card_point_inside_rotated(opt.card, mx, my, 1.08);
            opt.card.y = old_y;
            if (card_hit)
            {
                if (opt.selected)
                    opt.selected = false;
                else
                {
                    var selected_count = 0;
                    for (var si = 0; si < array_length(discard_choice_options); si++)
                        if (discard_choice_options[si].selected) selected_count++;
                    if (selected_count < discard_choice_max) opt.selected = true;
                }
                break;
            }
        }
    }

    exit;
}

// 占卜界面：暂停其他操作，只处理悬停、拖动、排序和确认。
if (scry_active)
{
    scry_hover_card = noone;

    // 从最上层开始检测鼠标悬停的卡牌。
    if (!instance_exists(scry_drag_card))
    {
        for (var si = 1; si >= 0 && scry_hover_card == noone; si--)
        {
            var list = (si == 0) ? scry_top : scry_bottom;
            for (var ci = array_length(list) - 1; ci >= 0; ci--)
            {
                var card = list[ci];
                if (!instance_exists(card)) continue;

                var hw = sprite_get_width(card.sprite_index) * scry_scale * 0.5;
                var hh = sprite_get_height(card.sprite_index) * scry_scale * 0.5;
                if (point_in_rectangle(mx, my, card.x - hw, card.y - hh,
                    card.x + hw, card.y + hh))
                {
                    scry_hover_card = card;
                    break;
                }
            }
        }
    }

    if (mouse_check_button_pressed(mb_left))
    {
        if (mx >= scry_confirm_x1 && mx <= scry_confirm_x2
        && my >= scry_confirm_y1 && my <= scry_confirm_y2)
        {
            scry_finish();
            exit;
        }

        scry_drag_card = noone;
        for (var si = 0; si < 2 && scry_drag_card == noone; si++)
        {
            var list = (si == 0) ? scry_top : scry_bottom;
            for (var ci = array_length(list) - 1; ci >= 0; ci--)
            {
                var card = list[ci];
                if (!instance_exists(card)) continue;
                var hw = sprite_get_width(card.sprite_index) * scry_scale * 0.5;
                var hh = sprite_get_height(card.sprite_index) * scry_scale * 0.5;
                if (point_in_rectangle(mx, my, card.x - hw, card.y - hh, card.x + hw, card.y + hh))
                {
                    scry_drag_card = card;
                    scry_hover_card = noone;
                    break;
                }
            }
        }
    }

    if (instance_exists(scry_drag_card) && mouse_check_button(mb_left))
    {
        scry_drag_card.x = mx;
        scry_drag_card.y = my;
    }

    if (mouse_check_button_released(mb_left) && instance_exists(scry_drag_card))
    {
        var moving = scry_drag_card;
        var was_top = false;
        for (var oi = 0; oi < array_length(scry_top); oi++)
        {
            if (scry_top[oi] == moving)
            {
                array_delete(scry_top, oi, 1);
                was_top = true;
                break;
            }
        }
        if (!was_top)
        {
            for (var oi = 0; oi < array_length(scry_bottom); oi++)
            {
                if (scry_bottom[oi] == moving)
                {
                    array_delete(scry_bottom, oi, 1);
                    break;
                }
            }
        }

        if (my < room_height * 0.52)
        {
            var insert_at = 0;
            while (insert_at < array_length(scry_top) && scry_top[insert_at].x < mx) insert_at++;
            array_insert(scry_top, insert_at, moving);
        }
        else
        {
            var insert_at = 0;
            while (insert_at < array_length(scry_bottom) && scry_bottom[insert_at].x < mx) insert_at++;
            array_insert(scry_bottom, insert_at, moving);
        }
        scry_drag_card = noone;
        scry_layout();
    }

    exit;
}


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
selection_hover_card = noone;
if (selection_active)
{
    // 选择界面也沿用普通手牌的悬停检测，确保所有选牌效果都能预览。
    for (var hi = array_length(hand) - 1; hi >= 0; hi--)
    {
        var hcard = hand[hi];
        if (!instance_exists(hcard) || !selection_can_select(hcard)) continue;
        var old_y = hcard.y;
        hcard.y -= 22;
        var card_hit = card_point_inside_rotated(hcard, mx, my, 1.12);
        hcard.y = old_y;
        if (card_hit)
        {
            selection_hover_card = hcard;
            break;
        }
    }
}
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
            var old_y = scard.y;
            if (scard == selection_hover_card) scard.y -= 22;
            var card_hit = card_point_inside_rotated(scard, mx, my, 1.12);
            scard.y = old_y;
            if (card_hit)
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
// 选择手牌期间暂停延迟效果，避免遮罩界面还未确认就发生战斗结算
if (!selection_active && !selection_was_active)
{
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

            // 贯索锁定的敌人离开前场后，立即重新回到前场。
            for (var lock_i = 0; lock_i < array_length(enemies); lock_i++)
            {
                var lock_enemy = enemies[lock_i];
                if (!instance_exists(lock_enemy)) continue;
                if (variable_instance_exists(lock_enemy, "force_front") && lock_enemy.force_front)
                {
                    array_delete(enemies, lock_i, 1);
                    array_insert(enemies, 0, lock_enemy);
                    break;
                }
            }

            enemy_phase = "attack";
        }
        // 只有所有敌人都行动完毕，才开始新一轮玩家回合
        if (!enemies_any_pending())
        {
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
starter_played_this_turn = array_create(5, false);
starfire_ready = (get_status(char_1, StatusType.STARFIRE) > 0);

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

// 地岳·镇垒给予目标角色的护甲翻倍只持续到这次玩家回合开始
if (instance_exists(char_2)) clear_status(char_2, StatusType.ROCK_WALL);
if (instance_exists(char_3)) clear_status(char_3, StatusType.ROCK_WALL);
if (instance_exists(char_4)) clear_status(char_4, StatusType.ROCK_WALL);
rock_wall_ready = false;

// 新回合：星光可以再次使用；星印持续两个敌方回合。
if (instance_exists(char_2))
{
    char_2.starlight_used = false;
    if (char_2.enemy_debuff_turns > 0) char_2.enemy_debuff_turns--;

    // 炫技：若上一个敌方回合没有受到伤害，额外获得3点护甲。
    if (char_2.showmanship_active)
    {
        if (!char_2.showmanship_hit) add_armor(char_2, ArmorType.GENERAL, 3);
        char_2.showmanship_active = false;
        char_2.showmanship_hit = false;
    }
}

// 临时属性与天河渡的分担效果只持续到本回合开始。
for (var fi = 0; fi < array_length(party_insts); fi++)
{
    var friend = party_insts[fi];
    if (!instance_exists(friend)) continue;
    clear_status(friend, StatusType.TEMP_MAGIC);
    clear_status(friend, StatusType.TEMP_STRENGTH);
    friend.shared_damage_owner = noone;
}
team_echo_used = array_create(5, false);

// 同尘授予的星光支付只持续当前回合。
for (var hi = 0; hi < array_length(hand); hi++)
    if (instance_exists(hand[hi])) hand[hi].starlight_enabled = false;

// 前场锁定只持续到下个玩家回合开始。
for (var ei = 0; ei < array_length(enemies); ei++)
    if (instance_exists(enemies[ei])) enemies[ei].force_front = false;

// 倒计时：所有倒计时 -1，到 0 的立刻触发
countdown_tick();

if (char_is_alive(char_1))
{
    // 苏灵兮天赋：每回合开始，从四张初始牌中选择一张加入手牌。
    request_discover([
        card_get_object(1),
        card_get_object(2),
        card_get_object(3),
        card_get_object(4)
    ], 4, "sulingxi_talent");

    // 元素共鸣：每回合开始，倒计时1：将一张随机的元素牌洗入抽牌堆（每层一个）
    repeat (get_status(char_1, StatusType.RESONANCE))
    {
        countdown_add(1, 1, [ { type: EffectType.SHUFFLE_ELEMENT, amount: 1 } ]);
    }

    // 阅读：每回合开始，发现一张本角色的牌
    repeat (get_status(char_1, StatusType.READING))
    {
        request_discover(discover_pool_char(1), 3, "reading");
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
        add_card_to_hand_id(208, 0, 0);
    }
}

// 紫微垣：每回合开始先占卜2；占卜确认后再进行常规抽牌。
draw_after_scry = 5;
if (char_is_alive(char_2) && char_2.purple_star)
    scry_start(2);

if (!scry_active)
{
    draw_after_scry = 0;
    draw_cards(5);
}
        }
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
    start_discover(discover_pool_field(), 7);
}
// 回合结束按钮

    // 回合结束按钮
    else if (mx >= end_button_x1 && mx <= end_button_x2
    &&  my >= end_button_y1 && my <= end_button_y2)
    {
		// 漫步繁星之畔：回合结束时为抽牌堆中的一张牌施加繁星。
if (char_is_alive(char_2) && char_2.star_walk_active) mark_random_deck_card();

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

    // 阅读的加费机会只属于发现它的这个回合
    if (variable_instance_exists(c, "reading_bonus")) c.reading_bonus = false;

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
attack_used_this_turn = array_create(5, false);

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
var can_play = false;

var tkind = card_target_kind(released_card.card_id);

if (tkind == TargetKind.FRIEND)
{
    // 必须松手在我方角色身上才算打出
    target = instance_position(mx, my, obj_character_1);
    if (card_requires_other_friend(released_card.card_id) && target == char_2)
        target = noone;
    can_play = (target != noone);

    // 先把卡牌显示回来：打出会被销毁，没打出就飞回手牌
    released_card.visible = true;
}
else if (tkind == TargetKind.ENEMY)
{
    // 必须松手在敌人身上才算打出（前场、后场的敌人都可以）
    target_enemy = instance_position(mx, my, obj_enemy_1);
    can_play = (target_enemy != noone);

    released_card.visible = true;
}

else
{
    // 普通牌：卡牌中心高于屏幕中央才算打出
    can_play = (released_card.y < room_height * 0.5);
}
// 无法被打出的牌（猩红）：拖出去也回到手牌
if (can_play && card_is_unplayable(released_card.card_id))
{
    can_play = false;
    warning_text = "无法打出";
    warning_timer = 90;
}

// 这张牌的拥有者已阵亡：无法使用（通用牌没有拥有者，不受影响）
if (can_play && card_owner_dead(released_card.card_id))
{
    can_play = false;
    warning_text = "该角色已阵亡";
    warning_timer = 90;
}

// 指向我方的牌不能指向已阵亡的角色
if (can_play && target != noone && target.is_dead)
{
    can_play = false;
    warning_text = "该角色已阵亡";
    warning_timer = 90;
}
// 需要其他友方角色的牌不能选择尘自己。
if (can_play && (released_card.card_id == 110 || released_card.card_id == 135 || released_card.card_id == 139)
&& target == char_2)
{
    can_play = false;
    warning_text = "请选择其他友方角色";
    warning_timer = 90;
}

// 需要手牌里有指定的牌才能打出（比如风助火势需要风刃）
var need_id = card_requirement(released_card.card_id);

if (can_play && need_id > 0 && !hand_has_card(need_id, released_card))
{
    can_play = false;
    warning_text = "手牌中没有所需的牌";
    warning_timer = 90;
}

if (can_play && released_card.card_id == 35 && array_length(hand) <= 1)
{
    can_play = false;
    warning_text = "手牌中没有可转化的牌";
    warning_timer = 90;
}

if (can_play && released_card.card_id == 46)
{
    var has_sulingxi_starter = false;
    for (var si = 0; si < array_length(hand); si++)
    {
        var starter_card = hand[si];
        if (starter_card != released_card && instance_exists(starter_card)
        && starter_card.card_id >= 1 && starter_card.card_id <= 4)
        {
            has_sulingxi_starter = true;
            break;
        }
    }
    if (!has_sulingxi_starter)
    {
        can_play = false;
        warning_text = "手牌中没有苏灵兮的初始牌";
        warning_timer = 90;
    }
}
if (can_play)
{
        var released_id = released_card.card_id;
        var cost = card_current_cost(released_card) + first_cost_up;
        var printed_star_cost = card_star_cost(released_id);
        var shortage = max(cost - energy, 0);
        var can_convert_star = card_uses_starlight(released_id)
            || (variable_instance_exists(released_card, "starlight_enabled") && released_card.starlight_enabled);
        var star_conversion = 0;
        var total_star_pay = printed_star_cost;
        var can_play = (energy >= cost);

        if (instance_exists(char_2))
        {
            if (shortage > 0 && can_convert_star
            && (!char_2.starlight_used || char_2.starlight_unlimited))
            {
                star_conversion = shortage;
                can_play = true;
            }

            total_star_pay += star_conversion;
            if (char_2.starlight < total_star_pay) can_play = false;
        }
        else if (total_star_pay > 0)
        {
            can_play = false;
        }

        // 助星捷辰一场战斗只能使用一次。
        if (released_id == 140 && char_2.assist_star_used) can_play = false;

// 费用和星光都不足：不打出，牌自动飞回手牌
if (!can_play)
{
    warning_text = (printed_star_cost > 0 || star_conversion > 0) ? "星光或费用不足" : "费用不足";
    warning_timer = 90;
}
else
{
    energy -= min(energy, cost);
    if (total_star_pay > 0) char_2.starlight -= total_star_pay;
    if (star_conversion > 0 && !char_2.starlight_unlimited) char_2.starlight_used = true;
	first_cost_up = 0;   // 本回合使用的第一张牌已经用掉了这个费用加成
	turn_played_ids[array_length(turn_played_ids)] = released_id;   // 记录本回合打出的牌

// 阅读：打出本回合发现的牌时获得1费（一次性）
if (variable_instance_exists(released_card, "reading_bonus") && released_card.reading_bonus)
{
    energy += 1;
    released_card.reading_bonus = false;
}

// 星火与燎原若在本回合已经使用过初始牌后才打出，则留到下回合触发
if (released_id == 23)
{
    var starter_before_starfire = false;
    for (var si = 0; si < array_length(turn_played_ids) - 1; si++)
    {
        if (card_is_starter(turn_played_ids[si]) && card_get_owner(turn_played_ids[si]) == 1) starter_before_starfire = true;
    }
    starfire_ready = !starter_before_starfire;
}

    var ctype = card_get_type(released_id);

    // 地岳·镇垒强化后的岩盾：被指定的角色进入前场，并在本回合获得的护甲翻倍
    if (released_id == 4 && rock_wall_ready && target != noone)
    {
        bring_to_front(target);
        add_status(target, StatusType.ROCK_WALL, 1);
    }

    // 记录各角色本回合是否打出过攻击牌。
    var attack_owner_n = card_get_owner(released_id);
    if (ctype == CardType.ATTACK && attack_owner_n == 2)
        char_2.attack_cards_used_battle++;
    if (ctype == CardType.ATTACK)
    {
        if (attack_owner_n > 0)
        {
            attack_used_this_turn[attack_owner_n] = true;
        }
        else if (target != noone)
        {
            // 通用攻击牌把攻击记录到被指定的友方角色名下
            if (target == char_1) attack_used_this_turn[1] = true;
            else if (target == char_2) attack_used_this_turn[2] = true;
            else if (target == char_3) attack_used_this_turn[3] = true;
            else if (target == char_4) attack_used_this_turn[4] = true;
        }
    }

// 攻击牌：对应角色先进入前场
// 攻击牌：所属角色先进入前场（通用攻击牌没有所属角色，不用换人）
if (ctype == CardType.ATTACK && !card_has_tag(released_id, CardTag.RANGED))
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
&& starfire_ready && get_status(card_owner, StatusType.STARFIRE) > 0)
{
    card_double_effects(released_card);
    // 状态持续整个战斗；本回合触发后只关闭本回合的触发资格
    starfire_ready = false;
}

// 保存初始牌本身的当前合成等级与效果，供女巫吟唱下一回合原样重放
var starter_replay_entry = card_entry_from_instance(released_card);

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
var starter_owner_for_turn = card_get_owner(released_id);
var first_hand_starter_this_turn = card_is_starter(released_id)
    && starter_owner_for_turn > 0
    && !starter_played_this_turn[starter_owner_for_turn];
if (card_is_starter(released_id) && starter_owner_for_turn > 0)
{
    starter_played_this_turn[starter_owner_for_turn] = true;
}

if (first_hand_starter_this_turn && char_is_alive(card_owner)
&& get_status(card_owner, StatusType.WITCH_CHANT) > 0 && !witch_chant_used)
{
    witch_chant_used = true;
    countdown_add(card_get_owner(released_id), 1,
        [ { type: EffectType.REPLAY_STARTER, amount: 1, card_id: released_id, entry: starter_replay_entry } ]);
}

// 尘的群星因你我而相连：每名友方角色每回合第一次使用攻击/技能牌，尘额外结算一次。
if (char_is_alive(char_2) && char_2.team_echo_active && (ctype == CardType.ATTACK || ctype == CardType.SKILL))
{
    var actor_id = card_get_owner(released_id);
    if (actor_id <= 0)
    {
        var actor_target = (target != noone) ? target : effect_target;
        if (actor_target == char_1) actor_id = 1;
        else if (actor_target == char_2) actor_id = 2;
        else if (actor_target == char_3) actor_id = 3;
        else if (actor_target == char_4) actor_id = 4;
    }

    if (actor_id > 0 && !team_echo_used[actor_id])
    {
        var has_modal = false;
        var echo_effects = card_current_effects(released_card);
        for (var ei = 0; ei < array_length(echo_effects); ei++)
        {
            var echo_effect = echo_effects[ei];
            if (echo_effect.type == EffectType.SCRY
            || echo_effect.type == EffectType.SELECT_HAND
            || echo_effect.type == EffectType.DISCOVER_OWN
            || echo_effect.type == EffectType.DISCOVER_LIST)
                has_modal = true;

            if (echo_effect.type == EffectType.CUSTOM
            && (echo_effect.action == "discard_choose" || echo_effect.action == "wish_discover"))
                has_modal = true;
        }

        team_echo_used[actor_id] = true;
        if (!has_modal)
            card_play_effects(released_card, effect_target, hit_enemy);
    }
}

// 星河相连：友方攻击后，尘向前场敌人投射星星。
if (ctype == CardType.ATTACK && char_is_alive(char_2) && char_2.star_bond_active
&& array_length(enemies) > 0 && instance_exists(enemies[0]))
{
    var bond_shot = instance_create_layer(char_2.x, char_2.y, "Instances", obj_star_projectile);
    bond_shot.target_enemy = enemies[0];
    bond_shot.damage = 5 + (char_2.star_damage_bonus_active ? 2 : 0);
    bond_shot.damage_type = DamageType.MAGIC;
}

// 参商：尘使用攻击牌后，令标记目标退至后场。
if (ctype == CardType.ATTACK && released_id >= 101 && released_id <= 200
&& instance_exists(char_2.retreat_mark_target))
{
    send_enemy_to_back(char_2.retreat_mark_target);
}

// 星灭：使用后自身费用提高1点，并保存在弃牌堆记录中。
if (released_id == 134 && !card_is_exhaust(released_id) && array_length(discard_pile) > 0)
    discard_pile[array_length(discard_pile) - 1].cost = card_current_cost(released_card) + 1;

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