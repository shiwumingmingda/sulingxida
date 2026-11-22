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
        generation_version: 2,
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

    // 1. 随机生成线路。先随机抽取边，再用并查集补线，保证全图连通。
    // 较低的连线概率会留下更多岔路、死路和绕行路线，而不是整张图变成密集网格。
    for (var gy = 0; gy < _h; gy++)
    {
        for (var gx = 0; gx < _w; gx++)
        {
            var cell_i = gy * _w + gx;

            if (gx < _w - 1 && random(1) < _link_chance)
                map_add_link(map, cell_i, cell_i + 1, 1);

            if (gy < _h - 1 && random(1) < _link_chance)
                map_add_link(map, cell_i, cell_i + _w, 2);
        }
    }

    var parent = array_create(n);
    for (var init_i = 0; init_i < n; init_i++) parent[init_i] = init_i;

    for (var merge_i = 0; merge_i < n; merge_i++)
    {
        if (map_has_link(map, merge_i, 1))
            parent[uf_find(parent, merge_i)] = uf_find(parent, merge_i + 1);

        if (map_has_link(map, merge_i, 2))
            parent[uf_find(parent, merge_i)] = uf_find(parent, merge_i + _w);
    }

    // 每次随机挑选两个不同连通区域之间的相邻边，直到全图连通。
    var guard = 0;
    while (guard < n * 8)
    {
        guard++;
        var bridges = [];

        for (var by = 0; by < _h; by++)
        {
            for (var bx = 0; bx < _w; bx++)
            {
                var bi = by * _w + bx;

                if (bx < _w - 1 && uf_find(parent, bi) != uf_find(parent, bi + 1))
                    bridges[array_length(bridges)] = [bi, bi + 1, 1];

                if (by < _h - 1 && uf_find(parent, bi) != uf_find(parent, bi + _w))
                    bridges[array_length(bridges)] = [bi, bi + _w, 2];
            }
        }

        if (array_length(bridges) == 0) break;

        var bridge = bridges[irandom(array_length(bridges) - 1)];
        map_add_link(map, bridge[0], bridge[1], bridge[2]);
        parent[uf_find(parent, bridge[0])] = uf_find(parent, bridge[1]);
    }

    // 2. 随机选择起点和首领。
    // 先用曼哈顿距离筛选：只有几何距离至少 6 格的首领候选才会入池，
    // 因此无论线路如何生成，首领的实际线路距离都不会小于 6。
    var start_candidates = [];

    for (var si = 0; si < n; si++)
    {
        var sx = si mod _w;
        var sy = si div _w;
        var far_manhattan = max(sx + sy,
            max((_w - 1 - sx) + sy,
                max(sx + (_h - 1 - sy), (_w - 1 - sx) + (_h - 1 - sy))));

        if (far_manhattan >= 6)
            start_candidates[array_length(start_candidates)] = si;
    }

    start_candidates = array_shuffle(start_candidates);
    var start_i = start_candidates[0];
    var start_dist = map_distance_field(map, start_i);
    var boss_candidates = [];

    for (var boss_check = 0; boss_check < n; boss_check++)
    {
        var bx2 = boss_check mod _w;
        var by2 = boss_check div _w;
        var sx2 = start_i mod _w;
        var sy2 = start_i div _w;
        var manhattan = abs(bx2 - sx2) + abs(by2 - sy2);

        if (boss_check != start_i && manhattan >= 6 && start_dist[boss_check] >= 0)
            boss_candidates[array_length(boss_candidates)] = boss_check;
    }

    // 所有尺寸均足以找到至少一个满足距离要求的首领位置。
    // 若以后调整尺寸导致候选为空，则用最远的可达格子兜底。
    if (array_length(boss_candidates) == 0)
    {
        var farthest = -1;
        for (var far_i = 0; far_i < n; far_i++)
            farthest = max(farthest, start_dist[far_i]);

        for (var fallback_i = 0; fallback_i < n; fallback_i++)
        {
            if (fallback_i != start_i && start_dist[fallback_i] == farthest)
                boss_candidates[array_length(boss_candidates)] = fallback_i;
        }
    }

    map.start_i = start_i;
    map.pos = start_i;
    map.boss_i = boss_candidates[irandom(array_length(boss_candidates) - 1)];

    // 3. 起点直接连着的节点必定是普通战斗，确保开局附近有敌人。
    var forced_n = 0;
    for (var dir = 0; dir < 4; dir++)
    {
        if (!map_has_link(map, start_i, dir)) continue;

        var near_i = map_neighbor(map, start_i, dir);
        if (near_i != map.boss_i)
        {
            map.type[near_i] = NodeType.BATTLE;
            forced_n++;
        }
    }

    // 4. 保留约 15% 空地（起点也计入空地比例），其余格子用于放置节点。
    var cells = [];
    for (var collect_i = 0; collect_i < n; collect_i++)
    {
        if (collect_i != start_i && collect_i != map.boss_i
        && map.type[collect_i] == NodeType.EMPTY)
            cells[array_length(cells)] = collect_i;
    }

    cells = array_shuffle(cells);

    // 空地只占指定比例；其余格子都进入待分配列表。
    var empty_n = min(max(round(n * _empty_ratio) - 1, 0), array_length(cells));
    var available_n = array_length(cells) - empty_n;
    var available = array_create(available_n, -1);

    for (var av_i = 0; av_i < available_n; av_i++)
        available[av_i] = cells[empty_n + av_i];

    // 5. 先保证每层的最低节点数量。使用游标顺序分配，避免反复删除数组元素。
    var min_camp = _floor;
    var min_elite = _floor;
    var min_treasure = 2;
    var min_battle = 8;

    var required_types = [
        [NodeType.BATTLE, min_battle],
        [NodeType.TREASURE, min_treasure],
        [NodeType.CAMP, min_camp],
        [NodeType.ELITE, min_elite],
        [NodeType.MERCHANT, 1],
        [NodeType.TRIBE, 1]
    ];

    var available_used = 0;

    for (var req_i = 0; req_i < array_length(required_types); req_i++)
    {
        var req_type = required_types[req_i][0];
        var req_count = required_types[req_i][1];

        for (var req_k = 0; req_k < req_count; req_k++)
        {
            if (available_used >= array_length(available)) break;

            map.type[available[available_used]] = req_type;
            available_used++;
        }
    }

    // 2、3 层各自有 50% 概率出现一个秘境；不会出现第二个。
    if (_floor >= 2 && available_used < array_length(available) && random(1) < 0.5)
    {
        map.type[available[available_used]] = NodeType.REALM;
        available_used++;
    }

    // 6. 填充剩余位置。战斗和事件是绝对主体，其余节点只占较小比例。
    // 1 层不生成擂台、瞭望点、秘境和首领先锋。
    for (var fill_i = available_used; fill_i < array_length(available); fill_i++)
    {
        var roll = irandom(99);
        var new_type = NodeType.BATTLE;

        if (roll < 52)
            new_type = NodeType.BATTLE;
        else if (roll < 80)
            new_type = NodeType.EVENT;
        else if (roll < 84)
            new_type = NodeType.CAMP;
        else if (roll < 87)
            new_type = NodeType.TREASURE;
        else if (roll < 92)
            new_type = NodeType.ELITE;
        else if (_floor >= 2 && roll < 95)
            new_type = NodeType.LOOKOUT;
        else if (_floor >= 2 && roll < 98)
            new_type = NodeType.ARENA;
        else if (roll < 99)
            new_type = NodeType.MERCHANT;
        else
            new_type = NodeType.TRIBE;

        map.type[available[fill_i]] = new_type;
    }

    map.type[map.boss_i] = NodeType.BOSS;

    // 7. 开局揭露所有真正的空地、首领，以及瞭望点周围的 3×3 区域。
    for (var reveal_i = 0; reveal_i < n; reveal_i++)
    {
        if (map.type[reveal_i] == NodeType.EMPTY || map.type[reveal_i] == NodeType.BOSS)
            map.revealed[reveal_i] = true;

        if (map.type[reveal_i] == NodeType.LOOKOUT)
        {
            var lookout_x = reveal_i mod _w;
            var lookout_y = reveal_i div _w;

            for (var oy = -1; oy <= 1; oy++)
            {
                for (var ox = -1; ox <= 1; ox++)
                {
                    var reveal_x = lookout_x + ox;
                    var reveal_y = lookout_y + oy;

                    if (reveal_x >= 0 && reveal_x < _w
                    &&  reveal_y >= 0 && reveal_y < _h)
                    {
                        map.revealed[reveal_y * _w + reveal_x] = true;
                    }
                }
            }
        }
    }

    // 8. 首领先锋：2 层 1 个，3 层 3 个；1 层不生成。
    var pursuer_n = (_floor == 2) ? 1 : ((_floor == 3) ? 3 : 0);
    var spawn_cells = [];

    for (var spawn_i = 0; spawn_i < n; spawn_i++)
    {
        if (spawn_i != map.start_i && spawn_i != map.boss_i && start_dist[spawn_i] >= 3)
            spawn_cells[array_length(spawn_cells)] = spawn_i;
    }

    spawn_cells = array_shuffle(spawn_cells);

    for (var pursuer_i = 0; pursuer_i < min(pursuer_n, array_length(spawn_cells)); pursuer_i++)
        map.pursuers[pursuer_i] = { pos: spawn_cells[pursuer_i] };

    // 调试信息：便于确认每次生成的地图确实不同，并核对核心规则。
    var deg_all = 0;
    var empty_total = 0;
    var battle_total = 0;
    var event_total = 0;
    var elite_total = 0;
    var arena_total = 0;
    var lookout_total = 0;
    var realm_total = 0;
    var camp_total = 0;
    var treasure_total = 0;
    var merchant_total = 0;
    var tribe_total = 0;

    for (var stat_i = 0; stat_i < n; stat_i++)
    {
        deg_all += map_degree(map, stat_i);

        switch (map.type[stat_i])
        {
            case NodeType.EMPTY: empty_total++; break;
            case NodeType.BATTLE: battle_total++; break;
            case NodeType.EVENT: event_total++; break;
            case NodeType.CAMP: camp_total++; break;
            case NodeType.ELITE: elite_total++; break;
            case NodeType.ARENA: arena_total++; break;
            case NodeType.LOOKOUT: lookout_total++; break;
            case NodeType.REALM: realm_total++; break;
            case NodeType.TREASURE: treasure_total++; break;
            case NodeType.MERCHANT: merchant_total++; break;
            case NodeType.TRIBE: tribe_total++; break;
        }
    }

    show_debug_message("地图 " + string(_w) + "x" + string(_h)
        + " 第" + string(_floor) + "层"
        + " 空地:" + string(empty_total)
        + " 战斗:" + string(battle_total)
        + " 事件:" + string(event_total)
        + " 营地:" + string(camp_total)
        + " 精英:" + string(elite_total)
        + " 擂台:" + string(arena_total)
        + " 珍宝:" + string(treasure_total)
        + " 瞭望点:" + string(lookout_total)
        + " 秘境:" + string(realm_total)
        + " 行商:" + string(merchant_total)
        + " 部落:" + string(tribe_total)
        + " 首领距离:" + string(start_dist[map.boss_i])
        + " 平均连线数:" + string(deg_all / n));

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