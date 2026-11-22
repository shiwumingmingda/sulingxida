/// scr_battle
/// 通用战斗函数：造成伤害并在目标中央显示飘字

enum DamageType
{
    PHYSICAL,   // 物理伤害：先扣物理护甲，再扣通用护甲
    MAGIC       // 魔法伤害：先扣魔法护甲，再扣通用护甲
}
// 复制一个数组（返回新数组，改它不会影响原数组）
function copy_array(_arr)
{
    var result = [];

    for (var i = 0; i < array_length(_arr); i++)
    {
        result[i] = _arr[i];
    }

    return result;
}
// 用名为 _name 的护甲抵消伤害，返回抵消后剩余的伤害
// 目标没有这种护甲变量时（比如敌人）直接跳过
function armor_absorb(_target, _name, _dmg)
{
    if (_dmg <= 0) return 0;
    if (!variable_instance_exists(_target, _name)) return _dmg;

    var have = variable_instance_get(_target, _name);
    var used = min(have, _dmg);

    variable_instance_set(_target, _name, have - used);

    return _dmg - used;
}
// 单位当前所有护甲的总和
function unit_armor_total(_u)
{
    if (!variable_instance_exists(_u, "armor_general")) return 0;

    return _u.armor_general + _u.armor_physical + _u.armor_magic;
}
// 造成伤害：先扣对应类型的护甲 → 再扣通用护甲 → 最后扣血
function deal_damage(_target, _amount, _dtype)
{
    if (unit_is_dead(_target)) return;
	var armor_before = unit_armor_total(_target);
    var remaining = _amount;

    if (_dtype == DamageType.PHYSICAL)
    {
        remaining = armor_absorb(_target, "armor_physical", remaining);
    }
    else
    {
        remaining = armor_absorb(_target, "armor_magic", remaining);
    }

    remaining = armor_absorb(_target, "armor_general", remaining);

    // 剩下的才扣血
    _target.hp = max(_target.hp - remaining, 0);

    // 飘字显示这次攻击的伤害数值（包括被护甲抵消的部分）
    var cx = (_target.bbox_left + _target.bbox_right) * 0.5;
    var cy = (_target.bbox_top + _target.bbox_bottom) * 0.5;

    var t = instance_create_layer(cx, cy, "Instances", obj_damage_text);
    t.text = "-" + string(_amount);
	// 熔岩加护：损失护甲后，将一张火球置入抽牌堆
if (unit_armor_total(_target) < armor_before && get_status(_target, StatusType.LAVA_WARD) > 0)
{
    with (obj_hand_controller)
    {
        shuffle_into_deck(card_get_object(1));
    }
}
	battle_check_death(_target);
}

// 给角色增加星光
function add_starlight(_target, _amount)
{
    if (!instance_exists(_target)) return;

    _target.starlight += _amount;
}
enum ArmorType
{
    GENERAL,
    PHYSICAL,
    MAGIC
}

// 给角色增加护甲
function add_armor(_target, _type, _amount)
{
    if (!instance_exists(_target)) return;

    switch (_type)
    {
        case ArmorType.GENERAL:  _target.armor_general  += _amount; break;
        case ArmorType.PHYSICAL: _target.armor_physical += _amount; break;
        case ArmorType.MAGIC:    _target.armor_magic    += _amount; break;
    }
}

// 这个单位是否已经阵亡（敌人没有 is_dead 变量，按存活处理）
function unit_is_dead(_u)
{
    if (!instance_exists(_u)) return true;
    if (variable_instance_exists(_u, "is_dead")) return _u.is_dead;

    return false;
}

// 我方角色是否存在且活着
function char_is_alive(_c)
{
    if (!instance_exists(_c)) return false;

    return !_c.is_dead;
}

// 血量归零就触发阵亡：角色变成失去作战能力的形态，敌人直接消失
function battle_check_death(_unit)
{
    if (!instance_exists(_unit)) return;
	monster_on_damaged(_unit);
    if (_unit.hp > 0) return;

    with (obj_hand_controller)
    {
        // 角色有 is_dead 变量，敌人没有
        if (variable_instance_exists(_unit, "is_dead"))
        {
            character_die(_unit);
        }
        else
        {
            enemy_die(_unit);
        }
    }
}

// 在目标中央飘一个字
function spawn_float_text(_target, _text, _col)
{
    var cx = (_target.bbox_left + _target.bbox_right) * 0.5;
    var cy = (_target.bbox_top + _target.bbox_bottom) * 0.5;

    var t = instance_create_layer(cx, cy, "Instances", obj_damage_text);
    t.text = _text;
    t.col = _col;
}

// 失去生命：直接扣血，不吃护甲
function lose_hp(_target, _amount)
{
    if (unit_is_dead(_target)) return;

    _target.hp = max(_target.hp - _amount, 0);
    spawn_float_text(_target, "-" + string(_amount), make_color_rgb(255, 70, 70));
	battle_check_death(_target);
}

// 回复生命：不超过最大生命
function heal_hp(_target, _amount)
{
	if (unit_is_dead(_target)) return;
    if (!instance_exists(_target)) return;

    var healed = min(_amount, _target.max_hp - _target.hp);

    if (healed <= 0) return;

    _target.hp += healed;
    spawn_float_text(_target, "+" + string(healed), make_color_rgb(90, 230, 120));
}

// 画单位的护甲条（三种护甲共用一条）；没有护甲不画，返回是否画了
function draw_unit_armor_bar(_u, _x, _y, _w, _h)
{
    var total = _u.armor_general + _u.armor_physical + _u.armor_magic;

    if (total <= 0) return false;

    draw_set_color(make_color_rgb(55, 55, 55));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);

    var vals = [_u.armor_general, _u.armor_physical, _u.armor_magic];
    var cols = [c_white, make_color_rgb(240, 200, 60), make_color_rgb(160, 90, 220)];
    var tcols = [c_black, c_black, c_white];
    var seg_x = _x;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var n = 0; n < 3; n++)
    {
        if (vals[n] <= 0) continue;

        var seg_w = _w * vals[n] / total;

        draw_set_color(cols[n]);
        draw_rectangle(round(seg_x), _y, round(seg_x + seg_w), _y + _h, false);

        draw_set_color(tcols[n]);
        draw_text(seg_x + seg_w * 0.5, _y + _h * 0.5, string(vals[n]));

        seg_x += seg_w;
    }

    draw_set_color(c_dkgray);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    return true;
}