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
    REPLAY_STARTER,      // 倒计时后视为再次使用一张初始牌
    SCRY,                 // 占卜：查看并重新排列牌堆顶牌
    STAR_PROJECTILE,      // 星星投射伤害
    ARMOR_BACKLINE,       // 给后场角色增加护甲
    RANDOM_DAMAGE,        // 随机敌人受到多段伤害
    CUSTOM                // 角色专属机制
}

// 新卡牌基础资料、稀有度与通用查询

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
    return {
        type: _type, cost: _cost, rarity: _rarity, exhaust: _exhaust,
        target: _target, need: _need,
        star_cost: (argument_count > 6) ? argument[6] : 0,
        innate: (argument_count > 7) ? argument[7] : false
    };
}

function card_info(_id)
{
    switch (_id)
    {

        // 尘：星星的孩子
        case 101: return card_make_info(CardType.ATTACK, 1, Rarity.NONE, false, TargetKind.NONE, 0);
        case 102: return card_make_info(CardType.ATTACK, 2, Rarity.NONE, false, TargetKind.NONE, 0);
        case 103: return card_make_info(CardType.SKILL,  2, Rarity.NONE, false, TargetKind.NONE, 0);
        case 104: return card_make_info(CardType.SKILL,  0, Rarity.NONE, false, TargetKind.ENEMY, 0, 1);
        // 普通
        case 105: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 106: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 107: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 108: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 109: return card_make_info(CardType.ATTACK, 3, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 110: return card_make_info(CardType.SKILL,  0, Rarity.COMMON, false, TargetKind.FRIEND, 0);
        case 111: return card_make_info(CardType.ATTACK, 2, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 112: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.ENEMY, 0);
        case 113: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 114: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 115: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0, 0, true);
        // 稀有
        case 116: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 117: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 118: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 119: return card_make_info(CardType.SKILL,  0, Rarity.RARE, false, TargetKind.NONE, 0);
        case 120: return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 121: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 122: return card_make_info(CardType.ATTACK, 3, Rarity.RARE, false, TargetKind.NONE, 0);
        case 123: return card_make_info(CardType.STATUS, 0, Rarity.RARE, false, TargetKind.NONE, 0, 1);
        case 124: return card_make_info(CardType.SKILL,  1, Rarity.RARE, true,  TargetKind.FRIEND, 0, 1);
        case 125: return card_make_info(CardType.SKILL,  1, Rarity.RARE, true,  TargetKind.ENEMY, 0);
        case 126: return card_make_info(CardType.ATTACK, 2, Rarity.RARE, false, TargetKind.ENEMY, 0);
        case 127: return card_make_info(CardType.SKILL,  0, Rarity.RARE, false, TargetKind.ENEMY, 0);
        case 128: return card_make_info(CardType.SKILL,  2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 129: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 130: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.ENEMY, 0);
        case 131: return card_make_info(CardType.ATTACK, 2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 132: return card_make_info(CardType.ATTACK, 7, Rarity.RARE, false, TargetKind.NONE, 0);
        case 133: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 134: return card_make_info(CardType.SKILL,  0, Rarity.RARE, false, TargetKind.NONE, 0);
        case 135: return card_make_info(CardType.SKILL,  0, Rarity.RARE, false, TargetKind.FRIEND, 0);
        case 136: return card_make_info(CardType.SKILL,  1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 137: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        // 传说
        case 138: return card_make_info(CardType.SKILL,  0, Rarity.LEGENDARY, false, TargetKind.NONE, 0, 0, true);
        case 139: return card_make_info(CardType.SKILL,  1, Rarity.LEGENDARY, false, TargetKind.FRIEND, 0);
        case 140: return card_make_info(CardType.SKILL,  0, Rarity.LEGENDARY, true, TargetKind.NONE, 0, 4);
        case 141: return card_make_info(CardType.SKILL,  1, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 142: return card_make_info(CardType.SKILL,  0, Rarity.LEGENDARY, false, TargetKind.NONE, 0, 1);
        case 143: return card_make_info(CardType.ATTACK, 2, Rarity.LEGENDARY, true, TargetKind.NONE, 0);
        case 144: return card_make_info(CardType.STATUS, 0, Rarity.LEGENDARY, false, TargetKind.NONE, 0, 2);
        case 145: return card_make_info(CardType.SKILL,  2, Rarity.LEGENDARY, true, TargetKind.NONE, 0);
        case 146: return card_make_info(CardType.SKILL,  0, Rarity.LEGENDARY, true, TargetKind.NONE, 0, 0, true);
        case 147: return card_make_info(CardType.STATUS, 3, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 148: return card_make_info(CardType.SKILL,  3, Rarity.LEGENDARY, true, TargetKind.NONE, 0);
        case 149: return card_make_info(CardType.STATUS, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 150: return card_make_info(CardType.SKILL,  2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 151: return card_make_info(CardType.SKILL,  3, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 152: return card_make_info(CardType.STATUS, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);

        // 新增普通卡
        case 153: return card_make_info(CardType.STATUS, 1, Rarity.COMMON, false, TargetKind.NONE, 0); // 许愿星
        case 154: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0); // 星象
        case 155: return card_make_info(CardType.STATUS, 1, Rarity.COMMON, false, TargetKind.NONE, 0); // 明澈
        case 156: return card_make_info(CardType.SKILL,  1, Rarity.COMMON, false, TargetKind.NONE, 0); // 换斗

        // 心羽：初始牌、普通牌与稀有牌
        case 201: return card_make_info(CardType.ATTACK, 1, Rarity.NONE, false, TargetKind.NONE, 0);
        case 202: return card_make_info(CardType.ATTACK, 1, Rarity.NONE, false, TargetKind.ENEMY, 0);
        case 203: return card_make_info(CardType.ATTACK, 1, Rarity.NONE, false, TargetKind.NONE, 0);
        case 204: return card_make_info(CardType.ATTACK, 1, Rarity.NONE, false, TargetKind.NONE, 0);
        case 205: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 206: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 207: return card_make_info(CardType.SKILL, 0, Rarity.COMMON, true, TargetKind.NONE, 0);
        case 208: return card_make_info(CardType.SKILL, 1, Rarity.COMMON, true, TargetKind.NONE, 0);
        case 209: return card_make_info(CardType.STATUS, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 210: return card_make_info(CardType.STATUS, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);

        case 211: return card_make_info(CardType.SKILL, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 212: return card_make_info(CardType.SKILL, 0, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 213: return card_make_info(CardType.SKILL, 0, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 214: return card_make_info(CardType.SKILL, 0, Rarity.COMMON, true, TargetKind.NONE, 0);
        case 215: return card_make_info(CardType.ATTACK, 0, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 216: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 217: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 218: return card_make_info(CardType.SKILL, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 219: return card_make_info(CardType.ATTACK, 2, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 220: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 221: return card_make_info(CardType.SKILL, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 222: return card_make_info(CardType.SKILL, 0, Rarity.COMMON, false, TargetKind.NONE, 401);
        case 223: return card_make_info(CardType.SKILL, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 224: return card_make_info(CardType.ATTACK, 1, Rarity.COMMON, false, TargetKind.NONE, 0);
        case 225: return card_make_info(CardType.STATUS, 1, Rarity.COMMON, false, TargetKind.NONE, 0);

        case 226: return card_make_info(CardType.ATTACK, 2, Rarity.RARE, false, TargetKind.ENEMY, 0);
        case 227: return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 228: return card_make_info(CardType.SKILL, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 229: return card_make_info(CardType.SKILL, 0, Rarity.RARE, false, TargetKind.NONE, 0);
        case 230: return card_make_info(CardType.SKILL, 0, Rarity.RARE, false, TargetKind.NONE, 0);
        case 231: return card_make_info(CardType.ATTACK, 3, Rarity.RARE, false, TargetKind.NONE, 0);
        case 232: return card_make_info(CardType.ATTACK, 2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 233: return card_make_info(CardType.STATUS, 2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 234: return card_make_info(CardType.SKILL, 1, Rarity.RARE, true, TargetKind.NONE, 0);
        case 235: return card_make_info(CardType.ATTACK, 2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 236: return card_make_info(CardType.SKILL, 1, Rarity.RARE, false, TargetKind.FRIEND, 0);
        case 237: return card_make_info(CardType.SKILL, 2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 238: return card_make_info(CardType.SKILL, 1, Rarity.RARE, false, TargetKind.ENEMY, 0);
        case 239: return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 240: return card_make_info(CardType.ATTACK, 3, Rarity.RARE, false, TargetKind.NONE, 0);

        case 247: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 248: return card_make_info(CardType.STATUS, 1, Rarity.RARE, false, TargetKind.NONE, 0);
        case 249: return card_make_info(CardType.ATTACK, 3, Rarity.RARE, true, TargetKind.NONE, 0);
        case 250: return card_make_info(CardType.STATUS, 2, Rarity.RARE, false, TargetKind.NONE, 0);
        case 251: return card_make_info(CardType.SKILL, 0, Rarity.RARE, false, TargetKind.NONE, 0);

        // 心羽：传说牌
        case 252: return card_make_info(CardType.ATTACK, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 253: return card_make_info(CardType.STATUS, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 254: return card_make_info(CardType.ATTACK, 2, Rarity.LEGENDARY, true, TargetKind.NONE, 0);
        case 255: return card_make_info(CardType.STATUS, 0, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 256: return card_make_info(CardType.ATTACK, 1, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 257: return card_make_info(CardType.STATUS, 1, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 258: return card_make_info(CardType.STATUS, 3, Rarity.LEGENDARY, false, TargetKind.NONE, 0);
        case 259: return card_make_info(CardType.SKILL, 2, Rarity.LEGENDARY, false, TargetKind.NONE, 0);

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
        case 29: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 1);       // 火凝·燎原
        case 30: return card_make_info(CardType.ATTACK, 1, Rarity.RARE, false, TargetKind.NONE, 0);       // 狂风·凝盾
        case 31: return card_make_info(CardType.ATTACK, 0, Rarity.RARE, false, TargetKind.NONE, 2);       // 狂风·流羽
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


function card_star_cost(_id)
{
    var info = card_info(_id);
    return is_undefined(info) ? 0 : info.star_cost;
}

function card_is_innate(_id)
{
    var info = card_info(_id);
    return !is_undefined(info) && info.innate;
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

// 通用纯色底图按稀有度替换；专属卡图、角色图和无稀有度卡牌保持原样。
function card_get_rarity_sprite(_inst, _spr)
{
    if (!instance_exists(_inst)) return _spr;
    if (_spr != Sprite1 && _spr != Sprite2 && _spr != Sprite3
    && _spr != Sprite9 && _spr != Spr_enemy1) return _spr;
    if (!variable_instance_exists(_inst, "card_id")) return _spr;

    switch (card_rarity(_inst.card_id))
    {
        case Rarity.COMMON: return Sprite2;     // 青色：普通
        case Rarity.RARE: return Sprite3;       // 蓝色：稀有
        case Rarity.LEGENDARY: return Sprite1;  // 金黄色：传说
    }

    return _spr;
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
            if (seen[k] == cid) { dup = true; break; }
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
        if (result[i].type == EffectType.DAMAGE
        || result[i].type == EffectType.DAMAGE_OTHERS
        || result[i].type == EffectType.RANDOM_DAMAGE
        || (result[i].type == EffectType.CUSTOM && result[i].action == "pull_and_damage"))
        {
            result[i].amount = max(result[i].amount + _n, 0);
        }
    }

    return result;
}


// 卡牌分类
function card_get_type(_id)
{
    // 有专属资料的卡牌，优先读取统一资料表
    var info = card_info(_id);
    if (!is_undefined(info)) return info.type;

    // 攻击牌：1~3、101~104、201~206、241~246、301
    if ((_id >= 1 && _id <= 3) || (_id >= 101 && _id <= 104)
    ||  (_id >= 201 && _id <= 206) || (_id >= 241 && _id <= 246) || _id == 301)
    {
        return CardType.ATTACK;
    }

    // 技能牌：4~5、105~107、207~208、302~304
    if ((_id >= 4 && _id <= 5) || (_id >= 105 && _id <= 107)
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

    // 2 费：102、105、210
    if (_id == 102 || _id == 105 || _id == 210) return 2;

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
		case 7:
			return [
			{ type: EffectType.STATUS, status: StatusType.RESONANCE, amount: 1, on_char: 1 }
    ];

       // 11号牌：造成 8 点法术伤害
		case 201:
			return [
				{ type: EffectType.DAMAGE, amount: 7, dtype: DamageType.PHYSICAL }
    ];

// 22 刺：剑招，追猎，造成 5 点物理伤害
		case 202:
			return [
				{ type: EffectType.DAMAGE, amount: 5, dtype: DamageType.PHYSICAL }
    ];

// 23 格：剑招，获得 6 点护甲
		case 203:
			return [
				{ type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 6, on_char: 3 }
    ];

// 24 洗：剑招，造成 3 点物理伤害，令敌方下回合失去等量的力量
		case 204:
			return [
			{ type: EffectType.DAMAGE, amount: 3, dtype: DamageType.PHYSICAL },
			{ type: EffectType.STATUS, status: StatusType.STRENGTH_DOWN, amount: 0, equal_damage: true }
    ];

// 业随影生：造成14点魔法伤害，将一张【猩红】置入抽牌堆。
        case 205: return [
            { type: EffectType.DAMAGE, amount: 14, dtype: DamageType.MAGIC },
            { type: EffectType.CUSTOM, action: "scarlet_to_deck", amount: 1 }
        ];

// 26 断业：造成 5 点物理伤害，弃置手中所有的【猩红】
		case 206:
			return [
				{ type: EffectType.DAMAGE,            amount: 5, dtype: DamageType.PHYSICAL },
				{ type: EffectType.DISCARD_FROM_HAND, amount: 1, card_id: 401 }
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
// 30 精进：每回合开始，往手牌里放一张0费练心。
        case 210: return [ { type: EffectType.STATUS, status: StatusType.DILIGENCE, amount: 1, on_char: 3 } ];

        // 普通牌
        case 211: return [ { type: EffectType.CUSTOM, action: "guard_stance", amount: 6, bonus: 4 } ];
        case 212: return [ { type: EffectType.CUSTOM, action: "step_draw", amount: 1 } ];
        case 213: return [ { type: EffectType.STATUS, status: StatusType.TEMP_STRENGTH, amount: 2, on_char: 3 } ];
        case 214: return [ { type: EffectType.CUSTOM, action: "blood_debt", amount: 2 } ];
        case 215: return [
            { type: EffectType.DAMAGE, amount: 2, dtype: DamageType.PHYSICAL },
            { type: EffectType.CUSTOM, action: "pursuit_draw", amount: 1 }
        ];
        case 216: return [
            { type: EffectType.DAMAGE, amount: 5, dtype: DamageType.PHYSICAL },
            { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 4, on_char: 3 }
        ];
        case 217: return [ { type: EffectType.DAMAGE, amount: 5, dtype: DamageType.PHYSICAL, bonus_if_no_armor: 3 } ];
        case 218: return [ { type: EffectType.CUSTOM, action: "finish_stance", amount: 6 } ];
        case 219: return [ { type: EffectType.DAMAGE, amount: 12, dtype: DamageType.PHYSICAL, on_damage_at_least: 15, apply_status: StatusType.VULNERABLE, status_amount: 2 } ];
        case 220: return [ { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.PHYSICAL, on_damage_at_least: 8, gain_energy: 1 } ];
        case 221: return [ { type: EffectType.CUSTOM, action: "blood_curtain", amount: 12 } ];
        case 222: return [
            { type: EffectType.CONSUME_FROM_HAND, amount: 1, card_id: 401 },
            { type: EffectType.GAIN_ENERGY, amount: 1 }
        ];
        case 223: return [ { type: EffectType.CUSTOM, action: "murder_intent", amount: 1 } ];
        case 224: return [
            { type: EffectType.LOSE_HP, amount: 2, on_char: 3 },
            { type: EffectType.DAMAGE, amount: 12, dtype: DamageType.PHYSICAL }
        ];
        case 225: return [ { type: EffectType.CUSTOM, action: "ancient_battlefield", amount: 1 } ];

        // 稀有牌
        case 226: return [ { type: EffectType.DAMAGE, amount: 12, dtype: DamageType.PHYSICAL, on_kill_energy: 2, on_kill_draw: 1 } ];
        case 227: return [ { type: EffectType.CUSTOM, action: "blood_beast", amount: 1 } ];
        case 228: return [ { type: EffectType.CUSTOM, action: "sword_sheath", amount: 2 } ];
        case 229: return [ { type: EffectType.CUSTOM, action: "drawn_sheath", amount: 2 } ];
        case 230: return [ { type: EffectType.CUSTOM, action: "red_dye", amount: 1 } ];
        case 231: return [
            { type: EffectType.DAMAGE, amount: 15, dtype: DamageType.PHYSICAL },
            { type: EffectType.CUSTOM, action: "play_top_two", amount: 2 }
        ];
        case 232: return [ { type: EffectType.DAMAGE, amount: 8, dtype: DamageType.PHYSICAL } ];
        case 233: return [ { type: EffectType.CUSTOM, action: "red_tide", amount: 1 } ];
        case 234: return [ { type: EffectType.CUSTOM, action: "sword_song", amount: 2 } ];
        case 235: return [ { type: EffectType.DAMAGE, amount: 18, dtype: DamageType.MAGIC } ];
        case 236: return [ { type: EffectType.CUSTOM, action: "scarlet_oath", amount: 5 } ];
        case 237: return [ { type: EffectType.CUSTOM, action: "flash_step", amount: 13 } ];
        case 238: return [ { type: EffectType.CUSTOM, action: "terror", amount: 10 } ];
        case 239: return [ { type: EffectType.CUSTOM, action: "blood_boil", amount: 1 } ];
        case 240: return [ { type: EffectType.DAMAGE, amount: 15, dtype: DamageType.PHYSICAL } ];

        // 特殊剑招
        case 241: return [
            { type: EffectType.DAMAGE, amount: 8, dtype: DamageType.PHYSICAL },
            { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 8, on_char: 3 },
            { type: EffectType.STATUS, status: StatusType.STRENGTH_DOWN, amount: 6 },
            { type: EffectType.STATUS, status: StatusType.MAGIC_DOWN, amount: 6 }
        ];
        case 242: return [
            { type: EffectType.DAMAGE, amount: 8, dtype: DamageType.PHYSICAL },
            { type: EffectType.DAMAGE_OTHERS, amount: 8, dtype: DamageType.PHYSICAL }
        ];
        case 243: return [ { type: EffectType.DAMAGE, amount: 15, dtype: DamageType.PHYSICAL } ];
        case 244: return [ { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.PHYSICAL, times: 3 } ];
        case 245: return [ { type: EffectType.STATUS, status: StatusType.SWORD_FORM, amount: 4, on_char: 3 } ];
        case 246: return [ { type: EffectType.DAMAGE, amount: 50, dtype: DamageType.PHYSICAL } ];

        // 追加稀有与传说牌
        case 247: return [
            { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.MAGIC },
            { type: EffectType.CUSTOM, action: "blood_mark", amount: 1 }
        ];
        case 248: return [ { type: EffectType.STATUS, status: StatusType.SWORD_FORM, amount: 2, on_char: 3 } ];
        case 249: return [ { type: EffectType.DAMAGE, amount: 30, dtype: DamageType.PHYSICAL, overkill_to_others: true } ];
        case 250: return [ { type: EffectType.CUSTOM, action: "unload_guard", amount: 1 } ];
        case 251: return [ { type: EffectType.CUSTOM, action: "gather_strength", amount: 3 } ];
        case 252: return [
            { type: EffectType.DAMAGE, amount: 10, dtype: DamageType.PHYSICAL, bonus_scarlet_in_hand: 6 },
            { type: EffectType.CUSTOM, action: "consume_scarlet_in_hand", amount: 1 }
        ];
        case 253: return [ { type: EffectType.CUSTOM, action: "sword_shadow", amount: 1 } ];
        case 254: return [ { type: EffectType.DAMAGE, amount: 10, dtype: DamageType.PHYSICAL, heal_half_damage: true } ];
        case 255: return [ { type: EffectType.CUSTOM, action: "scar_decree", amount: 1 } ];
        case 256: return [ { type: EffectType.COUNTDOWN, amount: 1, owner: 3, effects: [
            { type: EffectType.DAMAGE, amount: 10, dtype: DamageType.PHYSICAL, conditional_no_scarlet: true }
        ] } ];
        case 257: return [ { type: EffectType.CUSTOM, action: "blood_history", amount: 1 } ];
        case 258: return [ { type: EffectType.CUSTOM, action: "endless_blood_war", amount: 3 } ];
        case 259: return [ { type: EffectType.CUSTOM, action: "war_flames", amount: 2 } ];

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
        // 苏灵兮新卡牌效果
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
            return [ { type: EffectType.SELECT_HAND, amount: 1, filter_id: 1, mode: "single", min: 1, max: 1, action: { kind: "fireball_aoe" } } ];

        // 30 狂风·凝盾：消耗任意张风刃，获得其伤害总和两倍的护甲
        case 30:
            return [ { type: EffectType.SELECT_HAND, amount: 1, filter_id: 2, mode: "multi", min: 0, max: 999, action: { kind: "wind_shield" } } ];

        // 31 狂风·流羽：消耗一张风刃，敌方前排移动；本回合风刃伤害+2
        case 31:
            return [ { type: EffectType.SELECT_HAND, amount: 1, filter_id: 2, mode: "single", min: 1, max: 1, action: { kind: "wind_feather" } } ];

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
            return [ { type: EffectType.SELECT_HAND, amount: 1, filter_id: 0, mode: "single", min: 1, max: 1, action: { kind: "convert_rockshield" } } ];

        case 36:
            return [
                { type: EffectType.RETAIN_HAND, amount: 1 }
            ];

        // 37 阅读：回合开始时，发现一张本角色的牌。若你在本回合使用，获得1费
        case 37:
            return [
                { type: EffectType.STATUS, status: StatusType.READING, amount: 1, on_char: 1 }
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
            return [ { type: EffectType.SELECT_HAND, amount: 1, filter_id: -1, mode: "single", min: 1, max: 1, action: { kind: "compress" } } ];

        case 44:
            return [
                { type: EffectType.ADD_TO_HAND, amount: 1, card_id: 2, count: 10 },
                { type: EffectType.STATUS,      status: StatusType.WIND_COURT, amount: 1, on_char: 1 }
            ];


        // 尘：星星的孩子
        case 101: return [ { type: EffectType.DAMAGE, amount: 8, dtype: DamageType.MAGIC } ];
        case 102: return [
            { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.MAGIC },
            { type: EffectType.DAMAGE_OTHERS, amount: 6, dtype: DamageType.MAGIC }
        ];
        case 103: return [ { type: EffectType.STARLIGHT, amount: 2 } ];
        case 104: return [ { type: EffectType.CUSTOM, action: "starseal", amount: 1 } ];
        case 105: return [ { type: EffectType.DAMAGE, amount: 3, dtype: DamageType.MAGIC, other_attack_bonus: 6 } ];
        case 106: return [
            { type: EffectType.DAMAGE, amount: 4, dtype: DamageType.PHYSICAL },
            { type: EffectType.ARMOR_BACKLINE, amount: 5, armor: ArmorType.GENERAL }
        ];
        case 107: return [
            { type: EffectType.SCRY, amount: 5 },
            { type: EffectType.DRAW, amount: 2 }
        ];
        case 108: return [
            { type: EffectType.SCRY, amount: 3 },
            { type: EffectType.STAR_PROJECTILE, amount: 0, bottom_count: true }
        ];
        case 109: return [ { type: EffectType.DAMAGE, amount: 35, dtype: DamageType.PHYSICAL } ];
        case 110: return [ { type: EffectType.CUSTOM, action: "both_armor", amount: 3 } ];
        case 111: return [
            { type: EffectType.DAMAGE, amount: 10, dtype: DamageType.PHYSICAL },
            { type: EffectType.STARLIGHT, amount: 1 }
        ];
        case 112: return [ { type: EffectType.CUSTOM, action: "pull_and_damage", amount: 6 } ];
        case 113: return [ { type: EffectType.CUSTOM, action: "discard_choose", amount: 2 } ];
        case 114: return [ { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.MAGIC, bonus_starlight: true } ];
        case 115: return [
            { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.PHYSICAL },
            { type: EffectType.STARLIGHT, amount: 1, first_card_only: true }
        ];
        case 116: return [
            { type: EffectType.STARLIGHT, amount: 1 },
            { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 5, on_char: 2 },
            { type: EffectType.BRING_TO_FRONT, amount: 1, on_char: 2 }
        ];
        case 117: return [
            { type: EffectType.DRAW, amount: 2 },
            { type: EffectType.SELECT_HAND, filter_id: 0, mode: "multi", min: 2, max: 2, action: { kind: "discard_starmark" } }
        ];
        case 118: return [ { type: EffectType.STATUS, status: StatusType.DEXTERITY, amount: 2, on_char: 2 } ];
        case 119: return [ { type: EffectType.SELECT_HAND, filter_id: -2, mode: "single", min: 1, max: 1, action: { kind: "starlight_enable" } } ];
        case 120: return [ { type: EffectType.CUSTOM, action: "purple_star", amount: 1 } ];
        case 121: return [ ]; // 星轨：虚无效果在抽到时结算。
        case 122: return [
            { type: EffectType.DAMAGE, amount: 10, dtype: DamageType.MAGIC, on_kill_starlight: 1 },
            { type: EffectType.DAMAGE_OTHERS, amount: 10, dtype: DamageType.MAGIC, on_kill_starlight: 1 }
        ];
        case 123: return [ { type: EffectType.CUSTOM, action: "star_aura", amount: 2 } ];
        case 124: return [ { type: EffectType.CUSTOM, action: "long_life", amount: 1 } ];
        case 125: return [ { type: EffectType.CUSTOM, action: "retreat_mark", amount: 1 } ];
        case 126: return [ { type: EffectType.DAMAGE, amount: 14, dtype: DamageType.PHYSICAL } ];
        case 127: return [ { type: EffectType.CUSTOM, action: "move_enemy", amount: 1 } ];
        case 128: return [ ]; // 垒壁阵：虚无效果在抽到时结算。
        case 129: return [ { type: EffectType.CUSTOM, action: "temp_allies", amount: 3 } ];
        case 130: return [ { type: EffectType.CUSTOM, action: "remove_armor", amount: 12 } ];
        case 131: return [ { type: EffectType.RANDOM_DAMAGE, amount: 7, times: 1, dtype: DamageType.MAGIC } ];
        case 132: return [ { type: EffectType.DAMAGE, amount: 28, dtype: DamageType.PHYSICAL } ];
        case 133: return [ { type: EffectType.CUSTOM, action: "showmanship", amount: 5 } ];
        case 134: return [ { type: EffectType.CUSTOM, action: "weaken_enemies", amount: 3 } ];
        case 135: return [ { type: EffectType.CUSTOM, action: "ally_rotate_temp_magic", amount: 2 } ];
        case 136: return [ { type: EffectType.CUSTOM, action: "rotate_and_mark", amount: 1 } ];
        case 137: return [ { type: EffectType.DAMAGE, amount: 6, dtype: DamageType.MAGIC, bottom_bonus: 3 } ];
        case 138: return [ { type: EffectType.CUSTOM, action: "next_attack_bonus", amount: 5 } ];
        case 139: return [ { type: EffectType.CUSTOM, action: "shared_guard", amount: 10 } ];
        case 140: return [ { type: EffectType.CUSTOM, action: "assist_star", amount: 5 } ];
        case 141: return [
            { type: EffectType.COUNTDOWN, amount: 1, owner: 2, effects: [
                { type: EffectType.DRAW, amount: 2 },
                { type: EffectType.STARLIGHT, amount: 2 }
            ] }
        ];
        case 142: return [ { type: EffectType.CUSTOM, action: "wish_discover", amount: 1 } ];
        case 143: return [
            { type: EffectType.DAMAGE, amount: 15, dtype: DamageType.MAGIC },
            { type: EffectType.STATUS, status: StatusType.FROZEN, amount: 1 }
        ];
        case 144: return [ { type: EffectType.CUSTOM, action: "star_bond", amount: 1 } ];
        case 145: return [ { type: EffectType.CUSTOM, action: "heal_allies", amount: 5 } ];
        case 146: return [ { type: EffectType.STARLIGHT, amount: 3 } ];
        case 147: return [ { type: EffectType.CUSTOM, action: "team_echo", amount: 1 } ];
        case 148: return [ { type: EffectType.CUSTOM, action: "mark_hand_draw", amount: 1 } ];
        case 149: return [ { type: EffectType.CUSTOM, action: "night_guard", amount: 5 } ];
        case 150: return [
            { type: EffectType.STARLIGHT, amount: 1 },
            { type: EffectType.CUSTOM, action: "stars_to_power", amount: 1 }
        ];
        case 151: return [
            { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 16, on_char: 2 },
            { type: EffectType.CUSTOM, action: "armor_allies_equal", amount: 1 }
        ];
        case 152: return [ { type: EffectType.CUSTOM, action: "star_walk", amount: 1 } ];

        case 153: return [ { type: EffectType.CUSTOM, action: "wish_star", amount: 1 } ];
        case 154: return [ ]; // 星象：虚无效果在抽到时结算。
        case 155: return [ { type: EffectType.CUSTOM, action: "mingche", amount: 1 } ];
        case 156: return [ { type: EffectType.SELECT_HAND, filter_id: 0, mode: "single", min: 1, max: 1, action: { kind: "topdeck_draw_three" } } ];

    }

    // 没有写效果的牌，效果为空
    return [];
}

// 读取这张牌"当前"的效果列表（优先用牌自己的，没有就查表）
function card_current_effects(_inst)
{
    // 合成、强化或其他效果修改过的卡牌，优先读取实例自身保存的效果
    if (variable_instance_exists(_inst, "effects")) return _inst.effects;

    // 所有卡牌统一从效果表读取
    return card_get_effects(_inst.card_id);
}

// 计算一个效果实际生效的数值（在这里统一加上各种加成）
function card_effect_value(_effect)
{
    // 部分特殊效果只携带 action / card_id 等参数，不一定有 amount。
    // 缺少数值时按 0 处理，避免读取不存在的 struct 成员导致整张牌结算中断。
    var v = variable_struct_exists(_effect, "amount") ? _effect.amount : 0;

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

// 随机选择一个存活的友方角色，供“视为使用”需要友方目标的初始牌使用
function card_pick_random_living_ally()
{
    var controller = instance_find(obj_hand_controller, 0);
    if (!instance_exists(controller)) return noone;

    var choices = [];
    for (var i = 1; i <= 4; i++)
    {
        var ally = variable_instance_get(controller, "char_" + string(i));
        if (char_is_alive(ally))
        {
            choices[array_length(choices)] = ally;
        }
    }

    if (array_length(choices) <= 0) return noone;
    return choices[irandom(array_length(choices) - 1)];
}

function card_get_owner(_id)
{
    if (_id >= 1   && _id <= 100) return 1;
    if (_id >= 101 && _id <= 200) return 2;
    if (_id >= 201 && _id <= 300) return 3;
    if (_id == 401) return 3;
    return 0;
}

// 心羽本回合已使用的攻击牌数量。
function character3_attack_count_this_turn()
{
    if (!instance_exists(obj_hand_controller)) return 0;
    var count = 0;
    for (var i = 0; i < array_length(obj_hand_controller.turn_played_ids); i++)
    {
        var cid = obj_hand_controller.turn_played_ids[i];
        if (card_get_owner(cid) == 3 && card_get_type(cid) == CardType.ATTACK) count++;
    }
    return count;
}

// 当前手牌中【猩红】的数量。
function character3_scarlet_hand_count()
{
    if (!instance_exists(obj_hand_controller)) return 0;
    var count = 0;
    for (var i = 0; i < array_length(obj_hand_controller.hand); i++)
    {
        var c = obj_hand_controller.hand[i];
        if (instance_exists(c) && c.card_id == 401) count++;
    }
    return count;
}

// 将【猩红】洗入未抽取的抽牌堆部分；_ethereal=true 时附带虚无。
function character3_add_scarlet_to_deck(_count, _ethereal)
{
    if (!instance_exists(obj_hand_controller)) return;
    repeat (_count)
    {
        var entry = card_make_entry(obj_card_scarlet);
        entry.card_id = 401;
        entry.ethereal = _ethereal;
        var pos = irandom_range(obj_hand_controller.deck_index, array_length(obj_hand_controller.deck));
        array_insert(obj_hand_controller.deck, pos, entry);
    }
}

// 从抽牌堆中找出心羽攻击牌并以0费置入手牌。
function character3_draw_attacks_free(_count)
{
    if (!instance_exists(obj_hand_controller)) return;

    repeat (_count)
    {
        var found = -1;
        for (var di = obj_hand_controller.deck_index; di < array_length(obj_hand_controller.deck); di++)
        {
            var entry = obj_hand_controller.deck[di];
            var cid = variable_struct_exists(entry, "card_id") ? entry.card_id : -1;

            if (cid < 0)
            {
                for (var id_check = 201; id_check <= 259; id_check++)
                {
                    if (card_get_type(id_check) == CardType.ATTACK
                    && card_get_object(id_check) == entry.obj)
                    {
                        cid = id_check;
                        break;
                    }
                }
            }

            if (cid >= 201 && cid <= 300 && card_get_type(cid) == CardType.ATTACK)
            {
                found = di;
                break;
            }
        }

        if (found < 0) break;

        var selected_entry = obj_hand_controller.deck[found];
        array_delete(obj_hand_controller.deck, found, 1);
        if (array_length(obj_hand_controller.hand) >= obj_hand_controller.max_hand_size)
        {
            obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] = selected_entry;
        }
        else
        {
            var spawned = card_spawn_from_entry(selected_entry,
                room_width * 0.5, room_height - 115);
            spawned.cost = 0;
            spawned.cost_temporary = true;
            spawned.is_dealing = true;
            obj_hand_controller.hand[array_length(obj_hand_controller.hand)] = spawned;
            card_on_draw(spawned);
        }
    }

    obj_hand_controller.check_merge();
}

// 诛屠：免费使用抽牌堆顶的两张牌，然后将一张猩红置入弃牌堆。
// 诛屠：依次使用抽牌堆顶的两张牌，然后将一张猩红置入弃牌堆。
function character3_play_top_cards(_count)
{
    var controller = instance_find(obj_hand_controller, 0);
    if (!instance_exists(controller)) return;

    repeat (_count)
    {
        // 抽牌堆为空时，把弃牌堆洗回抽牌堆。
        if (controller.deck_index >= array_length(controller.deck)
        && array_length(controller.discard_pile) > 0)
        {
            controller.deck = array_shuffle(controller.discard_pile);
            controller.deck_index = 0;
            controller.discard_pile = [];
        }

        if (controller.deck_index >= array_length(controller.deck)) break;

        var entry = controller.deck[controller.deck_index];
        controller.deck_index++;
        var temp_card = card_spawn_from_entry(entry, -1000, -1000);
        var cid = temp_card.card_id;
        var ctype = card_get_type(cid);
        var owner_n = card_get_owner(cid);
        var actor = card_get_owner_instance(cid);

        if (!instance_exists(actor)) actor = controller.char_3;

        // 【猩红】等异常牌无法被使用，直接进入弃牌堆，不触发其手牌回合结束效果。
        if (card_is_unplayable(cid))
        {
            controller.discard_pile[array_length(controller.discard_pile)] =
                card_entry_from_instance(temp_card);
            with (temp_card) instance_destroy();
            continue;
        }

        controller.turn_played_ids[array_length(controller.turn_played_ids)] = cid;

        if (ctype == CardType.ATTACK && owner_n == 3)
        {
            controller.attack_used_this_turn[3] = true;

            // 剑鸣：每使用一张剑招，消耗一次免费次数。
            if (card_has_tag(cid, CardTag.SWORD)
            && controller.char_3.sword_song_charges > 0)
                controller.char_3.sword_song_charges--;

            // 攻击牌照常使心羽进入前场；远程剑招不改变站位。
            if (!card_has_tag(cid, CardTag.RANGED))
                controller.bring_to_front(controller.char_3);
        }
        else if (ctype == CardType.ATTACK && owner_n > 0)
        {
            controller.attack_used_this_turn[owner_n] = true;

            // 从牌堆顶视为使用的其他角色攻击牌，同样推进攻击计数并切换前场。
            if (owner_n == 2) controller.char_2.attack_cards_used_battle++;
            if (!card_has_tag(cid, CardTag.RANGED) && instance_exists(actor))
                controller.bring_to_front(actor);
        }

        var enemy_target = (array_length(controller.enemies) > 0)
            ? controller.enemies[0] : noone;
        var friend_target = actor;

        // 若抽到需要友方目标的牌，默认由牌的拥有者作为目标。
        if (card_target_kind(cid) == TargetKind.FRIEND)
            friend_target = actor;

        // 状态牌按照普通出牌规则登记状态覆盖关系。
        if (ctype == CardType.STATUS && owner_n > 0)
            state_card_played(actor, cid);

        // 视为使用卡牌本身；不允许诛屠再次触发诛屠，以免形成递归连锁。
        if (cid != 231)
            card_play_effects(temp_card, friend_target, enemy_target);

        // 剑影：诛屠视为使用的第一张剑招也会触发本回合的额外结算。
        if (cid != 231 && ctype == CardType.ATTACK && owner_n == 3
        && card_has_tag(cid, CardTag.SWORD)
        && controller.char_3.sword_shadow_active
        && !controller.char_3.sword_shadow_used)
        {
            controller.char_3.sword_shadow_used = true;
            card_play_effects(temp_card, friend_target, enemy_target);
        }

        // 血沸在攻击牌结算后生效；天赋血色也在攻击结算后获得。
        if (ctype == CardType.ATTACK && owner_n == 3)
        {
            if (controller.char_3.blood_boil_active)
                add_status(controller.char_3, StatusType.TEMP_STRENGTH, 1);
            add_status(controller.char_3, StatusType.BLOOD, 1);
        }

        // 被使用的非消耗牌进入弃牌堆；剑招等消耗牌则直接移出战斗。
        if (!card_is_exhaust(cid))
            controller.discard_pile[array_length(controller.discard_pile)] =
                card_entry_from_instance(temp_card);

        with (temp_card) instance_destroy();
    }

    controller.discard_pile[array_length(controller.discard_pile)] =
        card_make_entry(obj_card_scarlet);
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
        case EffectType.SCRY:
        {
            if (card_get_owner(_inst.card_id) == 2
            && instance_exists(obj_hand_controller.char_2))
                v += obj_hand_controller.char_2.scry_bonus;
        }
        break;

        case EffectType.DAMAGE:
        case EffectType.DAMAGE_OTHERS:
        case EffectType.RANDOM_DAMAGE:
        {
            var dt = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.PHYSICAL;

            // 力量：物理伤害 +1/层
            // 力量：物理伤害 +1/层。煞的猩红力量已包含在 get_status 中。
            if (dt == DamageType.PHYSICAL)
            {
                v += get_status(owner, StatusType.STRENGTH) + get_status(owner, StatusType.TEMP_STRENGTH);
            }
            else
            {
                v += get_status(owner, StatusType.MAGIC_POWER) + get_status(owner, StatusType.TEMP_MAGIC);
            }

            // 猩红余烬：每张手牌中的猩红额外造成6点伤害。
            if (variable_struct_exists(_e, "bonus_scarlet_in_hand")
            && owner == obj_hand_controller.char_3)
                v += character3_scarlet_hand_count() * _e.bonus_scarlet_in_hand;


            // 星幕：全队伤害提高
            if (instance_exists(obj_hand_controller.char_2) && obj_hand_controller.char_2.star_damage_bonus_active)
                v += 2;

            // 落星：伤害随当前星光增加
            if (variable_struct_exists(_e, "bonus_starlight") && instance_exists(obj_hand_controller.char_2))
                v += obj_hand_controller.char_2.starlight;

            // 客星：其他友方角色本回合先打出过攻击牌
            if (variable_struct_exists(_e, "other_attack_bonus"))
            {
                var other_attacked = false;
                for (var ai = 1; ai <= 4; ai++)
                    if (ai != 2 && obj_hand_controller.attack_used_this_turn[ai]) other_attacked = true;
                if (other_attacked) v += _e.other_attack_bonus;
            }

            // 剑招：带剑招标签的牌，所有伤害 +N
            if (card_has_tag(_inst.card_id, CardTag.SWORD))
            {
                v += get_status(owner, StatusType.SWORD_FORM);
                if (instance_exists(obj_hand_controller.char_3)
                && owner == obj_hand_controller.char_3)
                    v += owner.temp_sword_form;
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

            // 格：该牌获得的护甲同样受到剑招加成。
            if (_inst.card_id == 203 && instance_exists(obj_hand_controller.char_3))
            {
                v += get_status(obj_hand_controller.char_3, StatusType.SWORD_FORM);
                v += obj_hand_controller.char_3.temp_sword_form;
            }

            if (get_status(receiver, StatusType.ROCK_WALL) > 0) v *= 2;
        }
        break;

        case EffectType.CUSTOM:
        {
            // 回星引月：该自定义物理伤害也受力量与星幕加成。
            if (variable_struct_exists(_e, "action") && _e.action == "pull_and_damage")
            {
                v += get_status(owner, StatusType.STRENGTH);
                v += get_status(owner, StatusType.TEMP_STRENGTH);
                if (instance_exists(obj_hand_controller.char_2)
                && obj_hand_controller.char_2.star_damage_bonus_active)
                    v += 2;
            }
        }
        break;
    }

    return max(v, 0);
}

// 这张牌上伤害效果的重复次数（卡面文字用）
function card_current_times(_inst)
{
    // 昴宿：基础重复1次，每次抽到时再增加1次，最多重复7次。
    if (_inst.card_id == 131)
    {
        var repeats = variable_instance_exists(_inst, "echo_repeats") ? _inst.echo_repeats : 1;
        return 1 + min(repeats, 7);
    }

    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        if ((effects[i].type == EffectType.DAMAGE || effects[i].type == EffectType.RANDOM_DAMAGE)
        && variable_struct_exists(effects[i], "times"))
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

// 读取倒计时效果中嵌套的某种效果数值（用于同步卡牌描述）。
function card_current_countdown_value(_inst, _type)
{
    var total = 0;
    var effects = card_current_effects(_inst);

    for (var i = 0; i < array_length(effects); i++)
    {
        var e = effects[i];
        if (e.type != EffectType.COUNTDOWN || !variable_struct_exists(e, "effects")) continue;

        for (var k = 0; k < array_length(e.effects); k++)
        {
            var nested = e.effects[k];
            if (nested.type == _type)
                total += card_effect_final(nested, _inst, noone);
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
// 从手牌中消耗一张指定编号的牌；返回是否成功
function card_try_consume_from_hand(_card_id)
{
    var controller = instance_find(obj_hand_controller, 0);
    if (!instance_exists(controller)) return false;

    for (var i = 0; i < array_length(controller.hand); i++)
    {
        var hand_card = controller.hand[i];

        if (instance_exists(hand_card) && hand_card.card_id == _card_id)
        {
            array_delete(controller.hand, i, 1);
            with (hand_card) instance_destroy();
            return true;
        }
    }

    return false;
}

// 执行一张牌的所有效果
// 立即执行一个效果
function card_apply_effect(_e, _v, _target, _enemy)
{
    switch (_e.type)
    {
        case EffectType.DAMAGE:
{
    if (instance_exists(_enemy))
    {
        // 条件伤害：目标被冻结才造成
        if (variable_struct_exists(_e, "if_frozen") && get_status(_enemy, StatusType.FROZEN) <= 0) break;

        var dt = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.PHYSICAL;
        var damage_target = _enemy;
        var hp_before = damage_target.hp;
        var incoming = _v;

        // 计算易伤和本次攻击真正能穿透的护甲，供摧枯拉朽计算溢出伤害。
        if (get_status(damage_target, StatusType.VULNERABLE) > 0)
            incoming = floor(incoming * 1.5);

        var matching_armor = (dt == DamageType.PHYSICAL)
            ? damage_target.armor_physical : damage_target.armor_magic;
        var matching_used = min(incoming, matching_armor);
        var general_used = min(max(incoming - matching_used, 0), damage_target.armor_general);
        var overkill_amount = max(incoming - matching_used - general_used - hp_before, 0);

        var dealt = deal_damage(damage_target, _v, dt);
        var target_killed = !instance_exists(damage_target);
        if (!target_killed && instance_exists(damage_target))
            target_killed = (damage_target.hp <= 0);

        // 直踢、侧踢：按实际扣除的体力判断额外效果。
        if (variable_struct_exists(_e, "on_damage_at_least") && dealt >= _e.on_damage_at_least)
        {
            if (variable_struct_exists(_e, "apply_status"))
                add_status(damage_target, _e.apply_status, _e.status_amount);
            if (variable_struct_exists(_e, "gain_energy"))
                obj_hand_controller.energy += _e.gain_energy;
        }

        // 红尘：回复实际造成伤害的一半。
        if (variable_struct_exists(_e, "heal_half_damage") && _e.heal_half_damage)
            heal_hp(obj_hand_controller.char_3, floor(dealt * 0.5));

        // 摧枯拉朽：击杀目标后，将穿透护甲并超过其剩余体力的伤害分给所有其他敌人。
        if (variable_struct_exists(_e, "overkill_to_others")
        && _e.overkill_to_others && target_killed && overkill_amount > 0)
        {
            var other_targets = copy_array(obj_hand_controller.enemies);
            for (var oi = 0; oi < array_length(other_targets); oi++)
            {
                var other = other_targets[oi];
                if (instance_exists(other) && other != damage_target)
                    deal_damage(other, overkill_amount, DamageType.PHYSICAL);
            }
        }

        // 击杀奖励
        if (variable_struct_exists(_e, "on_kill_id") && target_killed)
            with (obj_hand_controller) add_card_to_hand_id(_e.on_kill_id, _e.on_kill_cost, 0);
        if (variable_struct_exists(_e, "on_kill_starlight") && target_killed)
            add_starlight(obj_hand_controller.char_2, _e.on_kill_starlight);
        if (variable_struct_exists(_e, "on_kill_energy") && target_killed)
            obj_hand_controller.energy += _e.on_kill_energy;
        if (variable_struct_exists(_e, "on_kill_draw") && target_killed)
            obj_hand_controller.draw_cards(_e.on_kill_draw);
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
                    if (variable_struct_exists(_e, "on_kill_starlight") && !instance_exists(en))
                        add_starlight(obj_hand_controller.char_2, _e.on_kill_starlight);
                }
            }
        }
        break;

        case EffectType.SCRY:
            break;

        case EffectType.STAR_PROJECTILE:
        {
            var projectile_target = _enemy;
            if (!instance_exists(projectile_target) && array_length(obj_hand_controller.enemies) > 0)
                projectile_target = obj_hand_controller.enemies[0];
            if (instance_exists(projectile_target) && _v > 0)
            {
                var projectile_damage = _v;
                if (instance_exists(obj_hand_controller.char_2)
                && obj_hand_controller.char_2.star_damage_bonus_active)
                    projectile_damage += 2;

                var shot = instance_create_layer(obj_hand_controller.char_2.x, obj_hand_controller.char_2.y,
                    "Instances", obj_star_projectile);
                shot.target_enemy = projectile_target;
                shot.damage = projectile_damage;
                shot.damage_type = DamageType.MAGIC;
            }
        }
        break;

        case EffectType.ARMOR_BACKLINE:
        {
            for (var bi = 0; bi < array_length(obj_hand_controller.back_chars); bi++)
            {
                var back_friend = obj_hand_controller.back_chars[bi];
                if (char_is_alive(back_friend))
                    add_armor(back_friend, _e.armor, _v + get_status(back_friend, StatusType.DEXTERITY));
            }
        }
        break;

        case EffectType.RANDOM_DAMAGE:
        {
            var hit_times = variable_struct_exists(_e, "times") ? _e.times : 1;
            var random_type = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.MAGIC;
            repeat (hit_times)
            {
                var living_targets = [];
                for (var ei = 0; ei < array_length(obj_hand_controller.enemies); ei++)
                    if (instance_exists(obj_hand_controller.enemies[ei]))
                        living_targets[array_length(living_targets)] = obj_hand_controller.enemies[ei];

                if (array_length(living_targets) <= 0) break;
                var random_target = living_targets[irandom(array_length(living_targets) - 1)];
                deal_damage(random_target, _v, random_type);
            }
        }
        break;

        case EffectType.CUSTOM:
        {
            var dust = obj_hand_controller.char_2;
            switch (_e.action)
            {
                case "discard_choose":
                    obj_hand_controller.discard_choice_start(5, _v);
                    break;

                case "starseal":
                    if (instance_exists(_enemy))
                    {
                        add_status(_enemy, StatusType.STRENGTH_DOWN, 6);
                        add_status(_enemy, StatusType.MAGIC_DOWN, 6);
                    }
                    break;
                case "both_armor":
                    if (instance_exists(_target) && _target != dust)
                        add_armor(_target, ArmorType.GENERAL, _v + get_status(_target, StatusType.DEXTERITY));
                    add_armor(dust, ArmorType.GENERAL, _v + get_status(dust, StatusType.DEXTERITY));
                    break;
                case "pull_and_damage":
                    if (instance_exists(_enemy))
                    {
                        obj_hand_controller.bring_enemy_to_front(_enemy);
                        deal_damage(_enemy, _v, DamageType.PHYSICAL);
                    }
                    break;
                case "purple_star": dust.purple_star = true; break;
                case "wish_star": dust.scry_bonus += _v; break;
                case "mingche": dust.mingche_active = true; break;
                case "move_enemy":
                    if (instance_exists(_enemy))
                    {
                        if (array_length(obj_hand_controller.enemies) > 0
                        && obj_hand_controller.enemies[0] == _enemy)
                            obj_hand_controller.send_enemy_to_back(_enemy);
                        else
                            obj_hand_controller.bring_enemy_to_front(_enemy);
                    }
                    break;
                case "star_aura": dust.star_damage_bonus_active = true; break;
                case "long_life":
                    if (instance_exists(_target)) _target.long_life = true;
                    break;
                case "retreat_mark":
                    dust.retreat_mark_target = _enemy;
                    if (instance_exists(_enemy)) obj_hand_controller.send_enemy_to_back(_enemy);
                    break;
                case "front_lock":
                    if (instance_exists(_enemy)) _enemy.force_front = true;
                    break;
                case "temp_allies":
                    for (var ti = 0; ti < array_length(obj_hand_controller.party_insts); ti++)
                    {
                        var f = obj_hand_controller.party_insts[ti];
                        if (!char_is_alive(f)) continue;
                        add_status(f, StatusType.TEMP_STRENGTH, _v);
                        add_status(f, StatusType.TEMP_MAGIC, _v);
                    }
                    break;
                case "remove_armor":
                    if (instance_exists(_enemy))
                    {
                        var left = _v;
                        var cut = min(_enemy.armor_general, left);
                        _enemy.armor_general -= cut; left -= cut;
                        cut = min(_enemy.armor_physical, left);
                        _enemy.armor_physical -= cut; left -= cut;
                        cut = min(_enemy.armor_magic, left);
                        _enemy.armor_magic -= cut;
                    }
                    break;
                case "weaken_enemies":
                    for (var wi = 0; wi < array_length(obj_hand_controller.enemies); wi++)
                    {
                        var weak = obj_hand_controller.enemies[wi];
                        if (!instance_exists(weak)) continue;
                        add_status(weak, StatusType.STRENGTH_DOWN, _v);
                        add_status(weak, StatusType.MAGIC_DOWN, _v);
                    }
                    break;
                case "ally_rotate_temp_magic":
                    if (instance_exists(_target) && _target != dust)
                    {
                        obj_hand_controller.rotate_character(_target);
                        add_status(_target, StatusType.TEMP_MAGIC, _v);
                    }
                    break;
                case "rotate_and_mark":
                    obj_hand_controller.rotate_character(dust);
                    obj_hand_controller.mark_random_deck_card();
                    break;
                case "showmanship":
                    obj_hand_controller.bring_to_front(dust);
                    add_armor(dust, ArmorType.GENERAL, _v + get_status(dust, StatusType.DEXTERITY));
                    dust.showmanship_active = true;
                    dust.showmanship_hit = false;
                    break;
                case "next_attack_bonus": dust.next_attack_bonus = _v; break;
                case "shared_guard":
                    if (instance_exists(_target) && _target != dust)
                    {
                        add_armor(_target, ArmorType.GENERAL, _v + get_status(_target, StatusType.DEXTERITY));
                        _target.shared_damage_owner = dust;
                    }
                    break;
                case "assist_star":
                    if (!dust.assist_star_used)
                    {
                        dust.assist_star_used = true;
                        obj_hand_controller.energy += _v;
                        var gifts = [];
                        for (var gi = 101; gi <= 156; gi++)
                            if (gi != 140 && card_get_object(gi) != -1)
                                gifts[array_length(gifts)] = gi;
                        repeat (2)
                        {
                            if (array_length(gifts) <= 0) break;
                            var gp = irandom(array_length(gifts) - 1);
                            var gid = gifts[gp];
                            array_delete(gifts, gp, 1);
                            obj_hand_controller.add_card_to_hand_id(gid, 0, 0);
                        }
                    }
                    break;
                case "wish_discover":
                    var wish_pool = [];
                    for (var wt = 0; wt < 3; wt++)
                    {
                        var ids = [];
                        for (var wish_card_id = 101; wish_card_id <= 156; wish_card_id++)
                            if (card_get_type(wish_card_id) == wt && card_rarity(wish_card_id) != Rarity.NONE && card_get_object(wish_card_id) != -1)
                                ids[array_length(ids)] = wish_card_id;
                        if (array_length(ids) > 0)
                            wish_pool[array_length(wish_pool)] = card_get_object(ids[irandom(array_length(ids) - 1)]);
                    }
                    obj_hand_controller.request_discover(wish_pool, array_length(wish_pool), "retain_once");
                    break;
                // 心羽：猩红与血色相关效果
                case "scarlet_to_deck":
                    character3_add_scarlet_to_deck(_v, false);
                    break;

                case "guard_stance":
                {
                    var heart_guard = obj_hand_controller.char_3;
                    var guard_bonus = (heart_guard.hp_lost_last_turn ? 0 : _e.bonus);
                    add_armor(heart_guard, ArmorType.GENERAL,
                        _v + guard_bonus + get_status(heart_guard, StatusType.DEXTERITY));
                }
                break;

                case "step_draw":
                    obj_hand_controller.bring_to_front(obj_hand_controller.char_3);
                    obj_hand_controller.draw_cards(_v);
                    break;

                case "blood_debt":
                    obj_hand_controller.energy += _v;
                    character3_add_scarlet_to_deck(2, false);
                    break;

                case "pursuit_draw":
                    // 当前追锋本身已记入本回合记录，因此至少要有另一张攻击牌。
                    if (character3_attack_count_this_turn() > 1)
                        obj_hand_controller.draw_cards(_v);
                    break;

                case "finish_stance":
                    add_armor(obj_hand_controller.char_3, ArmorType.GENERAL,
                        _v + get_status(obj_hand_controller.char_3, StatusType.DEXTERITY));
                    if (character3_attack_count_this_turn() >= 2)
                        obj_hand_controller.draw_cards(1);
                    break;

                case "blood_curtain":
                {
                    var curtain_target = obj_hand_controller.front_char;
                    if (instance_exists(curtain_target))
                        add_armor(curtain_target, ArmorType.PHYSICAL,
                            _v + get_status(curtain_target, StatusType.DEXTERITY));
                    character3_add_scarlet_to_deck(1, false);
                }
                break;

                case "murder_intent":
                {
                    var owned_attacks = [];
                    for (var ci = 201; ci <= 259; ci++)
                    {
                        if (card_get_type(ci) != CardType.ATTACK) continue;
                        var card_obj = card_get_object(ci);
                        if (card_obj == -1) continue;

                        var owned = false;
                        for (var pi = 0; pi < array_length(global.card_collection); pi++)
                        {
                            if (global.card_collection[pi] == card_obj) { owned = true; break; }
                        }
                        if (owned) owned_attacks[array_length(owned_attacks)] = ci;
                    }

                    if (array_length(owned_attacks) > 0)
                    {
                        var picked_attack = owned_attacks[irandom(array_length(owned_attacks) - 1)];
                        var hand_before_murder = array_length(obj_hand_controller.hand);
                        obj_hand_controller.add_card_to_hand_id(picked_attack, -1, 0);
                        if (array_length(obj_hand_controller.hand) > hand_before_murder)
                        {
                            var gained_attack = obj_hand_controller.hand[array_length(obj_hand_controller.hand) - 1];
                            gained_attack.cost = 0;
                            gained_attack.cost_temporary = true;
                        }
                    }
                    obj_hand_controller.add_card_to_hand(obj_card_scarlet, 0);
                }
                break;

                case "ancient_battlefield":
                    obj_hand_controller.char_3.ancient_battlefield_active = true;
                    break;

                case "blood_beast":
                    obj_hand_controller.char_3.blood_beast_active = true;
                    break;

                case "sword_sheath":
                    add_status(obj_hand_controller.char_3, StatusType.BLOOD,
                        (obj_hand_controller.battle_round == 1) ? 6 : _v);
                    break;

                case "drawn_sheath":
                    add_armor(obj_hand_controller.char_3, ArmorType.GENERAL,
                        _v + get_status(obj_hand_controller.char_3, StatusType.DEXTERITY));
                    if (array_length(obj_hand_controller.turn_played_ids) == 1)
                    {
                        obj_hand_controller.char_3.no_attack_this_turn = true;
                        obj_hand_controller.char_3.next_strength_bonus += 3;
                    }
                    break;

                case "red_dye":
                {
                    var current_strength = get_status(obj_hand_controller.char_3, StatusType.STRENGTH);
                    add_status(obj_hand_controller.char_3, StatusType.BLOOD,
                        _v + ((current_strength > 3) ? 2 : 0));
                    character3_add_scarlet_to_deck(1, false);
                }
                break;

                case "play_top_two":
                    character3_play_top_cards(_v);
                    break;

                case "red_tide":
                    obj_hand_controller.char_3.red_tide_active = true;
                    break;

                case "sword_song":
                    obj_hand_controller.char_3.sword_song_charges += _v;
                    break;

                case "scarlet_oath":
                    if (instance_exists(_target))
                        add_armor(_target, ArmorType.GENERAL,
                            _v + get_status(obj_hand_controller.char_3, StatusType.BLOOD)
                            + get_status(_target, StatusType.DEXTERITY));
                    break;

                case "flash_step":
                    if (array_length(obj_hand_controller.back_chars) > 0)
                    {
                        var flash_target = obj_hand_controller.back_chars[0];
                        if (char_is_alive(flash_target))
                        {
                            obj_hand_controller.bring_to_front(flash_target);
                            add_armor(flash_target, ArmorType.GENERAL,
                                _v + get_status(flash_target, StatusType.DEXTERITY));
                        }
                    }
                    break;

                case "terror":
                    if (instance_exists(_enemy))
                    {
                        var armor_left_terror = _v;
                        var cut_terror = min(_enemy.armor_general, armor_left_terror);
                        _enemy.armor_general -= cut_terror;
                        armor_left_terror -= cut_terror;
                        cut_terror = min(_enemy.armor_physical, armor_left_terror);
                        _enemy.armor_physical -= cut_terror;
                        armor_left_terror -= cut_terror;
                        cut_terror = min(_enemy.armor_magic, armor_left_terror);
                        _enemy.armor_magic -= cut_terror;

                        if (unit_armor_total(_enemy) <= 0)
                            add_status(_enemy, StatusType.VULNERABLE, 1);
                    }
                    break;

                case "blood_boil":
                    obj_hand_controller.char_3.blood_boil_active = true;
                    break;

                case "blood_mark":
                    if (instance_exists(_enemy)) _enemy.blood_mark_next_damage = true;
                    break;

                case "unload_guard":
                    obj_hand_controller.char_3.unload_active = true;
                    break;

                case "gather_strength":
                    obj_hand_controller.char_3.pending_sword_form += _v;
                    break;

                case "consume_scarlet_in_hand":
                    for (var sci = array_length(obj_hand_controller.hand) - 1; sci >= 0; sci--)
                    {
                        var scard = obj_hand_controller.hand[sci];
                        if (instance_exists(scard) && scard.card_id == 401)
                            obj_hand_controller.remove_card_from_hand(scard);
                    }
                    break;

                case "sword_shadow":
                    obj_hand_controller.char_3.sword_shadow_active = true;
                    break;

                case "scar_decree":
                    obj_hand_controller.char_3.scarlet_retain_active = true;
                    break;

                case "blood_history":
                    obj_hand_controller.char_3.history_active = true;
                    break;

                case "endless_blood_war":
                    obj_hand_controller.char_3.endless_blood_war_active = true;
                    obj_hand_controller.request_discover(
                        discover_pool_xinyu(obj_hand_controller.discover_46_unlocked), 3);
                    break;

                case "war_flames":
                    character3_draw_attacks_free(_v);
                    break;

                case "star_bond": dust.star_bond_active = true; break;
                case "heal_allies":
                    for (var hi = 0; hi < array_length(obj_hand_controller.party_insts); hi++)
                    {
                        var hf = obj_hand_controller.party_insts[hi];
                        if (!char_is_alive(hf)) continue;
                        heal_hp(hf, _v);
                        add_armor(hf, ArmorType.MAGIC, 10 + get_status(hf, StatusType.DEXTERITY));
                    }
                    break;
                case "team_echo": dust.team_echo_active = true; break;
                case "mark_hand_draw":
                {
                    // 将剩余手牌全部施加繁星并弃置，再抽取等量的牌。
                    var marked_hand = copy_array(obj_hand_controller.hand);
                    var draw_num = array_length(marked_hand);
                    for (var mi = 0; mi < draw_num; mi++)
                    {
                        var mc = marked_hand[mi];
                        if (!instance_exists(mc)) continue;
                        var marked_entry = card_entry_from_instance(mc);
                        marked_entry.star_marked = true;
                        obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] = marked_entry;
                        obj_hand_controller.remove_card_from_hand(mc);
                    }
                    obj_hand_controller.draw_cards(draw_num);
                }
                break;
                case "night_guard": dust.night_guard_active = true; break;
                case "stars_to_power":
                    var stars = dust.starlight;
                    add_status(dust, StatusType.MAGIC_POWER, stars);
                    add_armor(dust, ArmorType.GENERAL, stars + get_status(dust, StatusType.DEXTERITY));
                    break;
                case "armor_allies_equal":
                    var total_armor = unit_armor_total(dust);
                    for (var ai = 0; ai < array_length(obj_hand_controller.party_insts); ai++)
                    {
                        var ally = obj_hand_controller.party_insts[ai];
                        if (char_is_alive(ally) && ally != dust) add_armor(ally, ArmorType.GENERAL, total_armor);
                    }
                    break;
                case "star_walk":
                    dust.star_walk_active = true;
                    dust.starlight_unlimited = true;
                    // 无限补费启用后，星光指示立即恢复为可用状态。
                    dust.starlight_used = false;
                    break;
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
            if (variable_struct_exists(_e, "first_card_only")
            && _e.first_card_only
            && array_length(obj_hand_controller.turn_played_ids) > 1) break;

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
    // 消耗材料失败时，中止这次牌的后续效果（例如聚能的第二次结算）
    if (!card_try_consume_from_hand(_e.card_id)) return false;
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

    if (instance_exists(_enemy) && instance_exists(armor_who))
    {
        var armor_damage = unit_armor_total(armor_who);
        var armor_damage_type = variable_struct_exists(_e, "dtype") ? _e.dtype : DamageType.PHYSICAL;

        // 将护甲总量作为基础伤害，之后仍按物理/魔法伤害结算角色属性加成
        if (armor_damage_type == DamageType.PHYSICAL)
        {
            armor_damage += get_status(armor_who, StatusType.STRENGTH);
        }
        else
        {
            armor_damage += get_status(armor_who, StatusType.MAGIC_POWER)
                          + get_status(armor_who, StatusType.TEMP_MAGIC);
        }

        deal_damage(_enemy, armor_damage, armor_damage_type);
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
    for (var played_index = 0; played_index < array_length(obj_hand_controller.turn_played_ids); played_index++)
    {
        if (obj_hand_controller.turn_played_ids[played_index] == _e.card_id)
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

            // 这张生成的火球也算实际使用了一张初始牌
            obj_hand_controller.turn_played_ids[array_length(obj_hand_controller.turn_played_ids)] = 1;
            obj_hand_controller.attack_used_this_turn[1] = true;

            // 星火与燎原强化本回合实际打出的第一张初始牌
            var fire_owner = card_get_owner_instance(1);
            if (obj_hand_controller.starfire_ready && get_status(fire_owner, StatusType.STARFIRE) > 0)
            {
                card_double_effects(fire_inst);
                obj_hand_controller.starfire_ready = false;
            }

            var current_volley_target = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;
            card_play_effects(fire_inst, _target, current_volley_target);
            var used_fire_entry = card_entry_from_instance(fire_inst);
            with (fire_inst) instance_destroy();
            obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] = used_fire_entry;
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
    var random_card_owner = card_get_owner_instance(random_id);

    // 岩盾需要友方目标；随机选择一名存活队友，而不是固定选择 char_1
    if (random_id == 4)
    {
        random_owner = card_pick_random_living_ally();
    }

    if (!instance_exists(random_owner))
    {
        with (random_inst) instance_destroy();
        break;
    }

    // 岩盾只指向友方角色，不传入敌方目标
    var random_enemy = (random_id == 4 || array_length(obj_hand_controller.enemies) <= 0)
        ? noone : obj_hand_controller.enemies[0];

    // 视为使用：记录初始牌编号，使其他“本回合使用过初始牌”的效果也能识别
    obj_hand_controller.turn_played_ids[array_length(obj_hand_controller.turn_played_ids)] = random_id;
    if (random_id <= 3)
    {
        obj_hand_controller.attack_used_this_turn[1] = true;
        with (obj_hand_controller) bring_to_front(random_owner);
    }
    else if (random_id == 4 && obj_hand_controller.rock_wall_ready)
    {
        with (obj_hand_controller) bring_to_front(random_owner);
        add_status(random_owner, StatusType.ROCK_WALL, 1);
    }

    // 星火与燎原也会作用于这次视为使用的初始牌
    if (obj_hand_controller.starfire_ready && get_status(random_card_owner, StatusType.STARFIRE) > 0)
    {
        card_double_effects(random_inst);
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

        // 合成后的火球是一次真实的初始牌使用
        obj_hand_controller.turn_played_ids[array_length(obj_hand_controller.turn_played_ids)] = 1;
        obj_hand_controller.attack_used_this_turn[1] = true;

        // 若本回合尚未使用初始牌，星火与燎原会进一步强化这张合成后的火球
        var fire_owner = card_get_owner_instance(1);
        if (obj_hand_controller.starfire_ready && get_status(fire_owner, StatusType.STARFIRE) > 0)
        {
            card_double_effects(merged_inst);
            obj_hand_controller.starfire_ready = false;
        }

        var merged_target = (array_length(obj_hand_controller.enemies) > 0) ? obj_hand_controller.enemies[0] : noone;
        card_play_effects(merged_inst, _target, merged_target);
        with (merged_inst) instance_destroy();
    }
}
break;

case EffectType.REPLAY_STARTER:
{
    var replay_obj = card_get_object(_e.card_id);
    var replay_entry = variable_struct_exists(_e, "entry") ? _e.entry : card_make_entry(replay_obj);
    var replay_inst = card_spawn_from_entry(replay_entry, -1000, -1000);
    var replay_card_owner = card_get_owner_instance(_e.card_id);
    var replay_owner = replay_card_owner;

    // 岩盾的延迟重放同样需要友方目标，随机选取存活队友
    if (_e.card_id == 4)
    {
        replay_owner = card_pick_random_living_ally();
    }

    if (!instance_exists(replay_owner))
    {
        with (replay_inst) instance_destroy();
        break;
    }

    // 岩盾只指向友方角色，不传入敌方目标
    var replay_enemy = (_e.card_id == 4 || array_length(obj_hand_controller.enemies) <= 0)
        ? noone : obj_hand_controller.enemies[0];

    // 倒计时重放也视为本回合使用过这张初始牌
    obj_hand_controller.turn_played_ids[array_length(obj_hand_controller.turn_played_ids)] = _e.card_id;
    if (_e.card_id >= 1 && _e.card_id <= 3)
    {
        obj_hand_controller.attack_used_this_turn[1] = true;
        with (obj_hand_controller) bring_to_front(replay_owner);
    }
    else if (_e.card_id == 4 && obj_hand_controller.rock_wall_ready)
    {
        with (obj_hand_controller) bring_to_front(replay_owner);
        add_status(replay_owner, StatusType.ROCK_WALL, 1);
    }

    if (obj_hand_controller.starfire_ready && get_status(replay_card_owner, StatusType.STARFIRE) > 0)
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

    return true;
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

        // 尘的下一张攻击牌获得一次性伤害加成
        if (i == 0 && card_get_owner(_card.card_id) == 2
        && card_get_type(_card.card_id) == CardType.ATTACK
        && instance_exists(obj_hand_controller.char_2)
        && obj_hand_controller.char_2.next_attack_bonus > 0)
        {
            effects = effects_add_damage(effects, obj_hand_controller.char_2.next_attack_bonus);
            obj_hand_controller.char_2.next_attack_bonus = 0;
        }

        // 数值在出牌这一刻算好（含力量、魔力、敏捷、剑招等加成）
        var v = card_effect_final(e, _card, effect_target_char(e, _target));

        // 见隙：若目标此刻没有任何护甲，额外造成3点伤害。
        if (e.type == EffectType.DAMAGE
        && variable_struct_exists(e, "bonus_if_no_armor")
        && instance_exists(_enemy) && unit_armor_total(_enemy) <= 0)
            v += e.bonus_if_no_armor;

        if (e.type == EffectType.SCRY)
        {
            var followups = [];
            for (var qi = i + 1; qi < array_length(effects); qi++)
            {
                var qe = effects[qi];
                var qv = card_effect_final(qe, _card, effect_target_char(qe, _target));
                followups[array_length(followups)] = { effect: qe, value: qv, target: _target, enemy: _enemy };
            }
            with (obj_hand_controller)
            {
                scry_followups = followups;
                scry_start(v);
            }
            return;
        }

        // "等量"：数值等于这张牌当前造成的伤害
        if (variable_struct_exists(e, "equal_damage"))
        {
            v = card_current_damage(_card);
        }

        var effect_to_apply = e;
        var times = variable_struct_exists(e, "times") ? e.times : 1;

        // 昴宿的重复次数由 RANDOM_DAMAGE 内部结算，避免外层和内层重复循环相乘。
        if (_card.card_id == 131 && e.type == EffectType.RANDOM_DAMAGE)
        {
            effect_to_apply = effect_copy(e);
            effect_to_apply.times = card_current_times(_card);
            times = 1;
        }

        var base_delay = variable_struct_exists(e, "delay") ? e.delay : 0;
        var gap = variable_struct_exists(e, "times_gap") ? e.times_gap : 15;

        for (var r = 0; r < times; r++)
        {
            var d = base_delay + r * gap;

            if (d > 0)
            {
                var pe = { timer: d, effect: effect_to_apply, value: v, target: _target, enemy: _enemy };

                with (obj_hand_controller)
                {
                    array_push(pending_effects, pe);
                }
            }
            else
            {
                if (card_apply_effect(effect_to_apply, v, _target, _enemy) == false)
                {
                    return;
                }
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
        case 7:  return obj_card_0007;
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

        // 尘（扩展牌）
        case 111: return obj_card_0111;
        case 112: return obj_card_0112;
        case 113: return obj_card_0113;
        case 114: return obj_card_0114;
        case 115: return obj_card_0115;
        case 116: return obj_card_0116;
        case 117: return obj_card_0117;
        case 118: return obj_card_0118;
        case 119: return obj_card_0119;
        case 120: return obj_card_0120;
        case 121: return obj_card_0121;
        case 122: return obj_card_0122;
        case 123: return obj_card_0123;
        case 124: return obj_card_0124;
        case 125: return obj_card_0125;
        case 126: return obj_card_0126;
        case 127: return obj_card_0127;
        case 128: return obj_card_0128;
        case 129: return obj_card_0129;
        case 130: return obj_card_0130;
        case 131: return obj_card_0131;
        case 132: return obj_card_0132;
        case 133: return obj_card_0133;
        case 134: return obj_card_0134;
        case 135: return obj_card_0135;
        case 136: return obj_card_0136;
        case 137: return obj_card_0137;
        case 138: return obj_card_0138;
        case 139: return obj_card_0139;
        case 140: return obj_card_0140;
        case 141: return obj_card_0141;
        case 142: return obj_card_0142;
        case 143: return obj_card_0143;
        case 144: return obj_card_0144;
        case 145: return obj_card_0145;
        case 146: return obj_card_0146;
        case 147: return obj_card_0147;
        case 148: return obj_card_0148;
        case 149: return obj_card_0149;
        case 150: return obj_card_0150;
        case 151: return obj_card_0151;
        case 152: return obj_card_0152;
        case 153: return obj_card_0153;
        case 154: return obj_card_0154;
        case 155: return obj_card_0155;
        case 156: return obj_card_0156;

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
        case 211: return obj_card_0211;
        case 212: return obj_card_0212;
        case 213: return obj_card_0213;
        case 214: return obj_card_0214;
        case 215: return obj_card_0215;
        case 216: return obj_card_0216;
        case 217: return obj_card_0217;
        case 218: return obj_card_0218;
        case 219: return obj_card_0219;
        case 220: return obj_card_0220;
        case 221: return obj_card_0221;
        case 222: return obj_card_0222;
        case 223: return obj_card_0223;
        case 224: return obj_card_0224;
        case 225: return obj_card_0225;
        case 226: return obj_card_0226;
        case 227: return obj_card_0227;
        case 228: return obj_card_0228;
        case 229: return obj_card_0229;
        case 230: return obj_card_0230;
        case 231: return obj_card_0231;
        case 232: return obj_card_0232;
        case 233: return obj_card_0233;
        case 234: return obj_card_0234;
        case 235: return obj_card_0235;
        case 236: return obj_card_0236;
        case 237: return obj_card_0237;
        case 238: return obj_card_0238;
        case 239: return obj_card_0239;
        case 240: return obj_card_0240;
        case 241: return obj_card_xinyu_1;
        case 242: return obj_card_xinyu_2;
        case 243: return obj_card_xinyu_3;
        case 244: return obj_card_xinyu_4;
        case 245: return obj_card_xinyu_5;
        case 246: return obj_card_xinyu_6;
        case 247: return obj_card_0247;
        case 248: return obj_card_0248;
        case 249: return obj_card_0249;
        case 250: return obj_card_0250;
        case 251: return obj_card_0251;
        case 252: return obj_card_0252;
        case 253: return obj_card_0253;
        case 254: return obj_card_0254;
        case 255: return obj_card_0255;
        case 256: return obj_card_0256;
        case 257: return obj_card_0257;
        case 258: return obj_card_0258;
        case 259: return obj_card_0259;

        // 通用
        case 301: return obj_card_0301;
        case 302: return obj_card_0302;
        case 303: return obj_card_0303;
        case 304: return obj_card_0304;
        case 401: return obj_card_scarlet;
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
        case 40:  return spr_card_40_hd;
        case 101: return spr_card_101_hd;
        case 103: return spr_card_103_hd;
        case 109: return spr_card_109_hd;
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
// 这些牌要求选择尘以外的友方角色。
function card_requires_other_friend(_id)
{
    return (_id == 110 || _id == 135 || _id == 139);
}

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
    if (variable_instance_exists(_inst, "ethereal") && _inst.ethereal)
        entry.ethereal = true;

    if (variable_instance_exists(_inst, "effects"))
    {
        entry.effects = card_copy_effects(_inst.effects);
    }

    entry.merge_level = card_merge_level(_inst);
    if (variable_instance_exists(_inst, "cost")
    && !(variable_instance_exists(_inst, "cost_temporary") && _inst.cost_temporary))
        entry.cost = _inst.cost;
    if (variable_instance_exists(_inst, "star_marked") && _inst.star_marked) entry.star_marked = true;
    if (variable_instance_exists(_inst, "echo_repeats")) entry.echo_repeats = _inst.echo_repeats;

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

    // 苏灵兮的四张初始牌：获得时附带一次性保留，经过一个回合后正常弃置。
    if (inst.card_id >= 1 && inst.card_id <= 4)
    {
        inst.retain_once = true;
    }

    if (!is_undefined(_entry.cost)) inst.cost = _entry.cost;
    if (variable_struct_exists(_entry, "star_marked") && _entry.star_marked) inst.star_marked = true;
    if (variable_struct_exists(_entry, "echo_repeats")) inst.echo_repeats = _entry.echo_repeats;
    if (variable_struct_exists(_entry, "ethereal") && _entry.ethereal) inst.ethereal = true;

    return inst;
}

function card_on_draw(_inst)
{
    if (!instance_exists(_inst)) return;
    var dust = obj_hand_controller.char_2;
    var heart = obj_hand_controller.char_3;

    if (variable_instance_exists(_inst, "star_marked") && _inst.star_marked)
    {
        add_starlight(dust, 1);
        var starmark_armor = card_effect_final(
            { type: EffectType.ARMOR, armor: ArmorType.MAGIC, amount: 5 }, _inst, dust);
        add_armor(dust, ArmorType.MAGIC, starmark_armor);
        _inst.star_marked = false;
    }

    // 血兽：每次抽到猩红，获得1点力量。
    var consume_scarlet = false;
    var draw_after_consume = false;

    if (_inst.card_id == 401 && instance_exists(heart))
    {
        if (heart.blood_beast_active)
            add_status(heart, StatusType.STRENGTH, 1);

        // 赤潮：抽到猩红时消耗并回复2点体力。
        if (heart.red_tide_active)
        {
            heal_hp(heart, 2);
            consume_scarlet = true;
        }
    }

    // 历战之境：每回合第一次抽到异常牌时，消耗它，抽1张并获得1费。
    if (instance_exists(heart) && heart.history_active && !heart.history_used
    && card_is_unplayable(_inst.card_id))
    {
        heart.history_used = true;
        obj_hand_controller.energy += 1;
        consume_scarlet = true;
        draw_after_consume = true;
    }

    if (consume_scarlet)
    {
        obj_hand_controller.remove_card_from_hand(_inst);
        if (draw_after_consume) obj_hand_controller.draw_cards(1);
        return;
    }

    // 虚无：这些效果在抽到卡牌时立即触发。
    switch (_inst.card_id)
    {
        case 121:
            obj_hand_controller.next_turn_energy_bonus += 2;
            break;
        case 128:
        {
            var physical_armor = card_effect_final(
                { type: EffectType.ARMOR, armor: ArmorType.PHYSICAL, amount: 10 }, _inst, dust);
            var magic_armor = card_effect_final(
                { type: EffectType.ARMOR, armor: ArmorType.MAGIC, amount: 10 }, _inst, dust);
            add_armor(dust, ArmorType.PHYSICAL, physical_armor);
            add_armor(dust, ArmorType.MAGIC, magic_armor);
        }
        break;

        case 154:
        {
            var general_armor = card_effect_final(
                { type: EffectType.ARMOR, armor: ArmorType.GENERAL, amount: 8 }, _inst, dust);
            add_armor(dust, ArmorType.GENERAL, general_armor);
        }
        break;
        case 131:
            if (!variable_instance_exists(_inst, "echo_repeats")) _inst.echo_repeats = 1;
            _inst.echo_repeats = min(_inst.echo_repeats + 1, 7);
            break;
    }
}

// 卡牌标签
enum CardTag
{
    SWORD,   // 剑招
    HUNT,    // 追猎：可以攻击到后场的敌人
    RANGED   // 远程：不会进入前场
}

function card_has_tag(_id, _tag)
{
    switch (_tag)
    {
        case CardTag.SWORD:
            return ((_id >= 201 && _id <= 204)
                || _id == 217 || _id == 231 || _id == 232
                || (_id >= 241 && _id <= 246));

        case CardTag.HUNT:
            return (_id == 202 || _id == 126 || _id == 130
                || _id == 226 || _id == 243);

        case CardTag.RANGED:
            return (_id == 243);
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

// 虚无：若回合结束时仍在手牌中，则消耗。
function card_is_ethereal(_id)
{
    return (_id == 121 || _id == 128 || _id == 154);
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
    return { obj: _obj, effects: undefined, merge_level: 0, cost: undefined, ethereal: false };
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
        // 焚心：若仍留在手牌中，回合结束时将一张猩红置入弃牌堆。
        case 235:
            obj_hand_controller.discard_pile[array_length(obj_hand_controller.discard_pile)] =
                card_make_entry(obj_card_scarlet);
            break;

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
    if (_id == 303 || _id == 212) return true;
    if (_id == 401 && instance_exists(obj_hand_controller)
    && instance_exists(obj_hand_controller.char_3))
        return obj_hand_controller.char_3.scarlet_retain_active;
    return false;
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
            if (result[i] == pick) { dup = true; break; }
        }

        if (!dup) result[array_length(result)] = pick;
    }

    return result;
}
