/// scr_map
/// 地图：生成、揭露、可到达范围、首领先锋

enum NodeType
{
    EMPTY,      // 空地
    BOSS,       // 首领
    BATTLE,     // 战斗
    ELITE,      // 精英战斗
    ARENA,      // 擂台大赛
    EVENT,      // 事件
    MERCHANT,   // 行商
    TRIBE,      // 部落
    CAMP,       // 营地
    TREASURE,   // 探寻珍宝
    LOOKOUT,    // 瞭望点
    REALM,      // 秘境
    FATE        // 命定
}

// 方向下标：0 = 上，1 = 右，2 = 下，3 = 左
// 一个格子的连线用 4 个二进制位保存：上 1、右 2、下 4、左 8

// ---------- 基础小函数 ----------

function map_has_link(_map, _i, _d)
{
    return (_map.links[_i] & (1 << _d)) != 0;
}

function map_add_link(_map, _i, _j, _d)
{
    _map.links[_i] |= (1 << _d);
    _map.links[_j] |= (1 << ((_d + 2) mod 4));
}

function map_degree(_map, _i)
{
    var c = 0;

    for (var d = 0; d < 4; d++)
    {
        if (map_has_link(_map, _i, d)) c++;
    }

    return c;
}

// 格子 _i 在方向 _d 上的相邻格子下标（调用前要确认没出界或者有连线）
function map_neighbor(_map, _i, _d)
{
    var ddx = [0, 1, 0, -1];
    var ddy = [-1, 0, 1, 0];

    return ((_i div _map.w) + ddy[_d]) * _map.w + ((_i mod _map.w) + ddx[_d]);
}

// 并查集：找到 _i 所在区域的根（只读）
function uf_find(_p, _i)
{
    while (_p[_i] != _i)
    {
        _i = _p[_i];
    }

    return _i;
}

// ---------- 节点分类 ----------

function node_is_combat(_t)
{
    return (_t == NodeType.BATTLE || _t == NodeType.ELITE || _t == NodeType.ARENA);
}

// 可重复进入的节点（其余节点探索完会变成空地）
function node_is_repeatable(_t)
{
    return (_t == NodeType.MERCHANT || _t == NodeType.TRIBE);
}

// ---------- 节点图标（把 spr_node_xxx 换成你自己的精灵名）----------

function node_sprite(_t)
{
    switch (_t)
    {
        case NodeType.EMPTY:    return spr_node_empty;
        case NodeType.BOSS:     return spr_node_boss;
        case NodeType.BATTLE:   return spr_node_battle;
        case NodeType.ELITE:    return spr_node_elite;
        case NodeType.ARENA:    return spr_node_arena;
        case NodeType.EVENT:    return spr_node_event;
        case NodeType.MERCHANT: return spr_node_merchant;
        case NodeType.TRIBE:    return spr_node_tribe;
        case NodeType.CAMP:     return spr_node_camp;
        case NodeType.TREASURE: return spr_node_treasure;
        case NodeType.LOOKOUT:  return spr_node_lookout;
        case NodeType.REALM:    return spr_node_realm;
        case NodeType.FATE:     return spr_node_fate;
    }

    return spr_node_hidden;
}

// 未揭露时的图标：战斗类显示"凶煞"，其他显示"隐秘"
function node_hidden_sprite(_t)
{
    return node_is_combat(_t) ? spr_node_danger : spr_node_hidden;
}

// 这个格子现在应该显示的图标
function map_cell_sprite(_map, _i)
{
    var t = _map.type[_i];

    if (_map.revealed[_i]) return node_sprite(t);

    return node_hidden_sprite(t);
}

// 在 (_x, _y) 处画一个居中的、缩放到 _size 大小的图标
function draw_node_sprite(_spr, _x, _y, _size, _alpha)
{
    var s = _size / max(sprite_get_width(_spr), sprite_get_height(_spr));
    var dx = _x - (sprite_get_width(_spr)  * 0.5 - sprite_get_xoffset(_spr)) * s;
    var dy = _y - (sprite_get_height(_spr) * 0.5 - sprite_get_yoffset(_spr)) * s;

    draw_sprite_ext(_spr, 0, dx, dy, s, s, 0, c_white, _alpha);
}

// ---------- 随机节点类型（占位权重，之后按你的设计改）----------

// 战斗类：战斗 / 精英战斗 / 擂台大赛（1 层没有擂台大赛）
function map_random_combat(_floor)
{
    var r = irandom(99);

    if (_floor >= 2 && r < 6) return NodeType.ARENA;
    if (r < 22) return NodeType.ELITE;

    return NodeType.BATTLE;
}

// 隐秘类：1 层只有事件、营地、探寻珍宝（行商/部落由"保证刷新"规则处理）
function map_random_hidden(_floor)
{
    var r = irandom(99);

    if (_floor == 1)
    {
        if (r < 55) return NodeType.EVENT;
        if (r < 85) return NodeType.CAMP;

        return NodeType.TREASURE;
    }

    if (r < 42) return NodeType.EVENT;
    if (r < 64) return NodeType.CAMP;
    if (r < 74) return NodeType.TREASURE;
    if (r < 82) return NodeType.MERCHANT;
    if (r < 90) return NodeType.TRIBE;

    return NodeType.LOOKOUT;
}

// ---------- 生成地图 ----------
// _w、_h：宽高；_ap：这一层的行动力；_link_chance：每条可能的线存在的概率；
// _empty_ratio：空地比例；_floor：第几层（1~3）
// 生成地图
// _w、_h：宽高；_ap：这一层的行动力；_link_chance：每条可能的线存在的概率；
// _empty_ratio：空地比例；_floor：第几层（1~3）
function map_generate(_w, _h, _ap, _link_chance, _empty_ratio, _floor)
{
    var n = _w * _h;

    var map = {
        w: _w,
        h: _h,
        ap_max: _ap,
        ap: _ap,
        type: array_create(n, NodeType.EMPTY),
        links: array_create(n, 0),
        revealed: array_create(n, false),
        pursuers: [],
        start_i: 0,
        boss_i: 0,
        pos: 0
    };

    // 1. 连线（和节点类型无关）：每条相邻的线，以 _link_chance 的概率存在
    for (var gy = 0; gy < _h; gy++)
    {
        for (var gx = 0; gx < _w; gx++)
        {
            var i = gy * _w + gx;

            if (gx < _w - 1 && random(1) < _link_chance)
            {
                map_add_link(map, i, i + 1, 1);
            }

            if (gy < _h - 1 && random(1) < _link_chance)
            {
                map_add_link(map, i, i + _w, 2);
            }
        }
    }

    // 保证整张图连通：先把已有的线合并成区域
    var parent = array_create(n);

    for (var i = 0; i < n; i++)
    {
        parent[i] = i;
    }

    for (var i = 0; i < n; i++)
    {
        if (map_has_link(map, i, 1))
        {
            parent[uf_find(parent, i)] = uf_find(parent, i + 1);
        }

        if (map_has_link(map, i, 2))
        {
            parent[uf_find(parent, i)] = uf_find(parent, i + _w);
        }
    }

    // 只要还有"相邻但不连通"的格子，就随机补一条线把两个区域接起来
    var guard = 0;

    while (guard < 1000)
    {
        guard++;

        var bridges = [];

        for (var gy = 0; gy < _h; gy++)
        {
            for (var gx = 0; gx < _w; gx++)
            {
                var i = gy * _w + gx;

                if (gx < _w - 1 && uf_find(parent, i) != uf_find(parent, i + 1))
                {
                    bridges[array_length(bridges)] = [i, i + 1, 1];
                }

                if (gy < _h - 1 && uf_find(parent, i) != uf_find(parent, i + _w))
                {
                    bridges[array_length(bridges)] = [i, i + _w, 2];
                }
            }
        }

        if (array_length(bridges) == 0) break;

        var b = bridges[irandom(array_length(bridges) - 1)];

        map_add_link(map, b[0], b[1], b[2]);
        parent[uf_find(parent, b[0])] = uf_find(parent, b[1]);
    }

    // 2. 起点随机：尽量挑一个在线路上能走出 6 步以上的位置；没有就取最远的
    var min_dist = 6;
    var start_i = 0;
    var best_far = -1;

    for (var attempt = 0; attempt < 60; attempt++)
    {
        var s = irandom(n - 1);
        var dist_s = map_distance_field(map, s);
        var far = 0;

        for (var i = 0; i < n; i++)
        {
            far = max(far, dist_s[i]);
        }

        if (far > best_far)
        {
            best_far = far;
            start_i = s;
        }

        if (far >= min_dist)
        {
            start_i = s;
            break;
        }
    }

    map.start_i = start_i;
    map.pos = start_i;

    var start_dist = map_distance_field(map, start_i);

    // 首领：随机选一个距离起点至少 6 步的格子；没有这样的格子就选最远的那些
    var far_max = 0;

    for (var i = 0; i < n; i++)
    {
        far_max = max(far_max, start_dist[i]);
    }

    var need = min(min_dist, far_max);
    var boss_candidates = [];

    for (var i = 0; i < n; i++)
    {
        if (i != start_i && start_dist[i] >= need)
        {
            boss_candidates[array_length(boss_candidates)] = i;
        }
    }

    map.boss_i = boss_candidates[irandom(array_length(boss_candidates) - 1)];

    // 3. 起点上下左右有线连着的第一个节点，必定是普通战斗
    var forced_n = 0;

    for (var d = 0; d < 4; d++)
    {
        if (!map_has_link(map, start_i, d)) continue;

        var nb = map_neighbor(map, start_i, d);

        if (nb != map.boss_i)
        {
            map.type[nb] = NodeType.BATTLE;
            forced_n++;
        }
    }

    // 4. 其余格子（除起点、首领、必定战斗的格子）打乱顺序
    var cells = [];

    for (var i = 0; i < n; i++)
    {
        if (i != start_i && i != map.boss_i && map.type[i] == NodeType.EMPTY)
        {
            cells[array_length(cells)] = i;
        }
    }

    cells = array_shuffle(cells);

    // 前 empty_n 个是空地（起点本身也是空地，算在 20% 里），其余是有内容的节点
    var empty_n = min(max(round(n * _empty_ratio) - 1, 0), array_length(cells));
    var m = array_length(cells) - empty_n;

    // 有内容的节点（含必定战斗的）：60% 战斗类，40% 隐秘类
    var combat_n = clamp(round((m + forced_n) * 0.6) - forced_n, 0, m);

    for (var k = 0; k < m; k++)
    {
        var idx = cells[empty_n + k];

        if (k < combat_n)
        {
            map.type[idx] = map_random_combat(_floor);
        }
        else
        {
            map.type[idx] = map_random_hidden(_floor);
        }
    }

    // 5. 保证刷新的节点：改写最前面几个隐秘类节点
    var hs = combat_n;

    // 1 层：行商和部落至少刷新一个，且只会刷新其中之一
    if (_floor == 1 && hs < m)
    {
        map.type[cells[empty_n + hs]] = choose(NodeType.MERCHANT, NodeType.TRIBE);
        hs++;
    }

    // 2、3 层：秘境 50% 概率出现一个
    if (_floor >= 2 && hs < m && random(1) < 0.5)
    {
        map.type[cells[empty_n + hs]] = NodeType.REALM;
        hs++;
    }

    map.type[map.boss_i] = NodeType.BOSS;

    // 6. 进入地图时揭露：空地、首领
    for (var i = 0; i < n; i++)
    {
        if (map.type[i] == NodeType.EMPTY || map.type[i] == NodeType.BOSS)
        {
            map.revealed[i] = true;
        }
    }

    // 瞭望点：进入地图时揭露自身上下左右的节点
    var ddx = [0, 1, 0, -1];
    var ddy = [-1, 0, 1, 0];

    for (var i = 0; i < n; i++)
    {
        if (map.type[i] != NodeType.LOOKOUT) continue;

        for (var d = 0; d < 4; d++)
        {
            var nx = (i mod _w) + ddx[d];
            var ny = (i div _w) + ddy[d];

            if (nx >= 0 && nx < _w && ny >= 0 && ny < _h)
            {
                map.revealed[ny * _w + nx] = true;
            }
        }
    }

    // 7. 首领先锋：2 层 1 个，3 层 3 个，在线路上离起点至少 3 步，不在首领上
    var pursuer_n = (_floor == 2) ? 1 : ((_floor == 3) ? 3 : 0);
    var spawn_cells = [];

    for (var i = 0; i < n; i++)
    {
        if (i != map.boss_i && start_dist[i] >= 3)
        {
            spawn_cells[array_length(spawn_cells)] = i;
        }
    }

    spawn_cells = array_shuffle(spawn_cells);

    for (var k = 0; k < min(pursuer_n, array_length(spawn_cells)); k++)
    {
        map.pursuers[k] = { pos: spawn_cells[k] };
    }

    // 调试输出：实际的平均连线数、首领距离
    var deg_all = 0;
    var deg_inner = 0;
    var inner_n = 0;

    for (var gy = 0; gy < _h; gy++)
    {
        for (var gx = 0; gx < _w; gx++)
        {
            var i = gy * _w + gx;
            var dg = map_degree(map, i);

            deg_all += dg;

            if (gx > 0 && gx < _w - 1 && gy > 0 && gy < _h - 1)
            {
                deg_inner += dg;
                inner_n++;
            }
        }
    }

    show_debug_message("地图 " + string(_w) + "x" + string(_h) + " 第" + string(_floor) + "层"
        + "  空地 " + string(empty_n + 1)
        + "  首领距离 " + string(start_dist[map.boss_i])
        + "  平均连线数(全部) " + string(deg_all / n)
        + "  平均连线数(内部) " + string(inner_n > 0 ? deg_inner / inner_n : 0));

    return map;
}

// ---------- 视野 / 可到达范围 ----------

// 计算从当前位置能看到、也能走到的所有格子，以及到它们的行动力花费
// 返回数组 cost：cost[i] = 花费，-1 = 看不到 / 走不到
function map_compute_reach(_map)
{
    var n = _map.w * _map.h;
    var cost = array_create(n, -1);
    var queue = [_map.pos];
    var head = 0;

    cost[_map.pos] = 0;

    while (head < array_length(queue))
    {
        var cur = queue[head];
        head++;

        // 只有当前位置和空地会延伸视野：非空节点能看到，但不会继续往外扩
        if (cur != _map.pos && _map.type[cur] != NodeType.EMPTY) continue;

        for (var d = 0; d < 4; d++)
        {
            if (!map_has_link(_map, cur, d)) continue;

            var nxt = map_neighbor(_map, cur, d);

            if (cost[nxt] != -1) continue;

            // 进入瞭望点不花行动力，其他格子每个 1 点
            var step_cost = (_map.type[nxt] == NodeType.LOOKOUT) ? 0 : 1;

            cost[nxt] = cost[cur] + step_cost;
            queue[array_length(queue)] = nxt;
        }
    }

    return cost;
}

// 把当前视野内的节点全部揭露，返回当前的 cost 数组
function map_reveal_reach(_map)
{
    var reach = map_compute_reach(_map);

    for (var i = 0; i < array_length(reach); i++)
    {
        if (reach[i] != -1)
        {
            _map.revealed[i] = true;
        }
    }

    return reach;
}

// 随机揭露 _count 个还没揭露的节点（瞭望点、以后的"分析地图"都用这个）
function map_reveal_random(_map, _count)
{
    var pool = [];

    for (var i = 0; i < array_length(_map.revealed); i++)
    {
        if (!_map.revealed[i])
        {
            pool[array_length(pool)] = i;
        }
    }

    pool = array_shuffle(pool);

    for (var k = 0; k < min(_count, array_length(pool)); k++)
    {
        _map.revealed[pool[k]] = true;
    }
}

// ---------- 首领先锋 ----------

// 先锋不能踩的格子：首领、命定
function map_blocked_for_pursuer(_map, _i)
{
    return (_map.type[_i] == NodeType.BOSS || _map.type[_i] == NodeType.FATE);
}

// 距离场：从 _from 出发沿线路到每个格子的步数（首领、命定不可通过），-1 = 到不了
function map_distance_field(_map, _from)
{
    var n = _map.w * _map.h;
    var dist = array_create(n, -1);
    var queue = [_from];
    var head = 0;

    dist[_from] = 0;

    while (head < array_length(queue))
    {
        var cur = queue[head];
        head++;

        for (var d = 0; d < 4; d++)
        {
            if (!map_has_link(_map, cur, d)) continue;

            var nxt = map_neighbor(_map, cur, d);

            if (dist[nxt] != -1) continue;
            if (map_blocked_for_pursuer(_map, nxt)) continue;

            dist[nxt] = dist[cur] + 1;
            queue[array_length(queue)] = nxt;
        }
    }

    return dist;
}

// 站在格子 _i 上的先锋下标，没有返回 -1
function map_pursuer_index_at(_map, _i)
{
    for (var k = 0; k < array_length(_map.pursuers); k++)
    {
        if (_map.pursuers[k].pos == _i) return k;
    }

    return -1;
}

// 所有先锋追向玩家，每个先锋走 _steps 步
// 返回碰到玩家的先锋下标（没有返回 -1）
function map_move_pursuers(_map, _steps)
{
    var dist = map_distance_field(_map, _map.pos);

    for (var k = 0; k < array_length(_map.pursuers); k++)
    {
        var p = _map.pursuers[k];

        for (var s = 0; s < _steps; s++)
        {
            if (p.pos == _map.pos) break;

            // 在相邻的格子里，选一个离玩家更近的
            var best = -1;
            var best_d = dist[p.pos];

            for (var d = 0; d < 4; d++)
            {
                if (!map_has_link(_map, p.pos, d)) continue;

                var nxt = map_neighbor(_map, p.pos, d);

                if (dist[nxt] != -1 && dist[nxt] < best_d)
                {
                    best = nxt;
                    best_d = dist[nxt];
                }
            }

            if (best == -1) break;

            p.pos = best;
        }

        if (p.pos == _map.pos) return k;
    }

    return -1;
}

// 触碰先锋（占位）：之后接先锋作战
function map_vanguard_touch(_map, _k, _i)
{
    // TODO：进入先锋作战。先锋 4 回合后逃跑并让行动力 -1；
    //       击败先锋 +1 行动力，并获得必定带补给品的普通战斗奖励
    show_debug_message("触碰首领先锋：进入先锋作战");

    array_delete(_map.pursuers, _k, 1);

    // 打完作战，这个格子变成空地
    _map.type[_i] = NodeType.EMPTY;
    _map.revealed[_i] = true;
}

// ---------- 到达节点 ----------

// 到达节点后触发的事情（占位）。返回 true 表示这一层结束
function map_on_arrive(_map, _i)
{
    var t = _map.type[_i];

    switch (t)
    {
		// 普通战斗：随机触发一种遭遇，并进入战斗房间
	case NodeType.BATTLE:
    global.encounter = encounter_generate(global.battle_count);
    global.battle_count++;
    global.go_battle = true;
    break;
        // 暂时：碰到首领直接进入下一层
        case NodeType.BOSS:
            return true;

        // 进入瞭望点：随机揭露场上 3 个未揭露的节点
        case NodeType.LOOKOUT:
            map_reveal_random(_map, 3);
            break;

        // TODO：战斗、商店、事件、营地……的触发之后再做
    }

    // 不可重复探索的节点，探索完变成空地
    // （现在没有触发流程，所以到达就当作探索完；以后改成流程结束后再执行）
    if (t != NodeType.EMPTY && !node_is_repeatable(t))
    {
        _map.type[_i] = NodeType.EMPTY;
    }

    return false;
}

// 命定：只在选了一些事件之后才会刷新。随机把一个未探索的节点变成命定（之后由事件调用）
function map_spawn_fate(_map)
{
    var pool = [];

    for (var i = 0; i < array_length(_map.type); i++)
    {
        var t = _map.type[i];

        if (t == NodeType.EMPTY || t == NodeType.BOSS || t == NodeType.FATE) continue;
        if (i == _map.pos) continue;
        if (map_pursuer_index_at(_map, i) != -1) continue;

        pool[array_length(pool)] = i;
    }

    if (array_length(pool) == 0) return;

    var pick = pool[irandom(array_length(pool) - 1)];

    _map.type[pick] = NodeType.FATE;
    _map.revealed[pick] = true;
}

// 进入下一层（占位：第 3 层结束后回到第 1 层）
function map_next_floor()
{
    if (global.map_floor < 3)
    {
        global.map_floor++;
    }
    else
    {
        show_debug_message("通关");
        global.map_floor = 1;
    }
	global.map = undefined;
    room_restart();
}

// 节点名称（没揭露时是"凶煞的节点"或"隐秘的节点"）
function node_title(_t, _revealed)
{
    if (!_revealed)
    {
        return node_is_combat(_t) ? "凶煞的节点" : "隐秘的节点";
    }

    switch (_t)
    {
        case NodeType.EMPTY:    return "空地";
        case NodeType.BOSS:     return "首领";
        case NodeType.BATTLE:   return "战斗";
        case NodeType.ELITE:    return "精英战斗";
        case NodeType.ARENA:    return "擂台大赛";
        case NodeType.EVENT:    return "事件";
        case NodeType.MERCHANT: return "行商";
        case NodeType.TRIBE:    return "部落";
        case NodeType.CAMP:     return "营地";
        case NodeType.TREASURE: return "探寻珍宝";
        case NodeType.LOOKOUT:  return "瞭望点";
        case NodeType.REALM:    return "秘境";
        case NodeType.FATE:     return "命定";
    }

    return "";
}

// 节点描述
function node_description(_t, _revealed)
{
    if (!_revealed)
    {
        return node_is_combat(_t)
            ? "尚未揭露的战斗节点。"
            : "尚未揭露的非战斗节点。";
    }

    switch (_t)
    {
        case NodeType.EMPTY:
            return "没有任何用处。探索完不可重复探索的节点后，该节点会变成空地。";

        case NodeType.BOSS:
            return "进入地图时就会显示，不会隐藏。行动力耗尽后会立即进入首领战，此时首领会狂暴。";

        case NodeType.BATTLE:
            return "进入小怪战斗。有30%的概率掉落一个自然物/加工品/药物，以及一张卡牌奖励和少量金币。";

        case NodeType.ELITE:
            return "进入精英战斗。必定掉落一个自然物/药物/加工品、一个奇物、一张稀有卡牌奖励和一些金币。";

        case NodeType.ARENA:
            return "连续挑战2波战斗，或挑战被强化的精英战斗。可以在六个自然物/药物/加工品中选择2个，并获得一个奇物和一张稀有卡牌奖励。期间可以随时认输，但不会获得任何奖励。";

        case NodeType.EVENT:
            return "进入后会随机进入一个事件。除少数事件外，每个事件在整局游戏内只会遇到一次。";

        case NodeType.MERCHANT:
            return "可重复进入。可以购买卡牌、奇物，删除卡牌，以及出售自然物。";

        case NodeType.TRIBE:
            return "可重复进入。可以购买加工品、药物、自然物，交换奇物/卡牌，以及出售自然物。";

        case NodeType.CAMP:
            return "进入后随机刷新3个选项供选择：休息、急救、手工、整理背包、精炼技艺、分析地图。";

        case NodeType.TREASURE:
            return "随机获得一个奇物和一些金币。";

        case NodeType.LOOKOUT:
            return "进入该节点不花费行动力。进入后随机揭露场上3个未揭露的节点。";

        case NodeType.REALM:
            return "花费自然物进入一张特殊的地图。";

        case NodeType.FATE:
            return "可以改变你的结局首领。";
    }

    return "";
}

// 角色对象 → 角色编号（1~4），没有返回 0
function character_get_num(_obj)
{
    var list = [obj_character_1, obj_character_2, obj_character_3, obj_character_4];

    for (var i = 0; i < 4; i++)
    {
        if (list[i] == _obj) return i + 1;
    }

    return 0;
}

// 角色的最大生命值（按各角色实际的最大生命值修改）
function character_base_max_hp(_num)
{
    return 35;
}

// 角色头像（换成你的精灵名）
// 角色头像（没有头像的角色先返回 -1，地图里会用角色自己的图代替）
function character_avatar_sprite(_num)
{
    switch (_num)
    {
        case 1: return -1;   // 换成：return spr_你的头像1;
        case 2: return -1;   // 换成：return spr_你的头像2;
        case 3: return -1;
        case 4: return -1;
    }

    return -1;
}

// 按像素宽度给文字换行（中文没有空格，draw_text_ext 不会自动换行，所以手动处理）
// 用当前字体测量，_max_w 是不含缩放的宽度
function wrap_text_pixels(_str, _max_w)
{
    var result = "";
    var line_w = 0;
    var len = string_length(_str);

    for (var i = 1; i <= len; i++)
    {
        var ch = string_char_at(_str, i);

        // 文字里本来就有的换行：行宽清零
        if (ch == "\n")
        {
            result += ch;
            line_w = 0;
            continue;
        }

        var cw = string_width(ch);

        // 这一行放不下了：先换行再写
        if (line_w + cw > _max_w && line_w > 0)
        {
            result += "\n";
            line_w = 0;
        }

        result += ch;
        line_w += cw;
    }

    return result;
}