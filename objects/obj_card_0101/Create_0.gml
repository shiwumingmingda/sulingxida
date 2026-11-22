card_id = 101;


// 这张牌当前的费用和伤害（初始值来自 scr_card_data，之后可被效果修改）
cost = card_get_cost(card_id);
// 这张牌自己的效果列表（从数据表复制一份，之后可以单独修改这张牌）
effects = card_get_effects(card_id);


global.chinese_font = font_add("QingNiaoHuaGuangJianMeiHei-2.ttf", 24, false, false, 32, 65535);