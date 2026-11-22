// 阵亡：只画失去作战能力的形态，不画血条、护甲条和状态图标
if (is_dead)
{
    draw_self();
    exit;
}
/// obj_character_1 - Draw

// 绘制角色本身
draw_self();

// 血条的位置
var bar_x = x - hp_bar_width * 0.5;
var bar_y = y + hp_bar_offset_y+60;

// 血条背景（深灰色）
draw_set_color(make_color_rgb(55, 55, 55));
draw_rectangle(
    bar_x,
    bar_y,
    bar_x + hp_bar_width,
    bar_y + hp_bar_height,
    false
);

// 计算剩余生命值比例，避免出现负数或超过上限
var hp_ratio = clamp(hp / max_hp, 0, 1);

// 绘制当前生命值（红色）
draw_set_color(make_color_rgb(220, 45, 45));

if (hp_ratio > 0)
{
    draw_rectangle(
        bar_x,
        bar_y,
        bar_x + hp_bar_width * hp_ratio,
        bar_y + hp_bar_height,
        false
    );
}

// 绘制血条边框（白色）
draw_set_color(c_white);
draw_rectangle(
    bar_x,
    bar_y,
    bar_x + hp_bar_width,
    bar_y + hp_bar_height,
    true
);

// 在血条中央绘制生命值数字
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(
    x,
    bar_y + hp_bar_height * 0.5,
    string(hp) + "/" + string(max_hp)
);

// 恢复文字对齐设置
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ----------------// ---------------------------------
// 护甲条：血条下方，三种护甲共用一条
// ---------------------------------
var total_armor = armor_general + armor_physical + armor_magic;

// 没有任何护甲就不显示
if (total_armor > 0)
{
    var ab_y = bar_y + hp_bar_height + 4;   // 血条下方留 4 像素
    var ab_h = hp_bar_height;               // 和血条一样粗

    // 背景
    draw_set_color(make_color_rgb(55, 55, 55));
    draw_rectangle(
        bar_x, ab_y,
        bar_x + hp_bar_width, ab_y + ab_h,
        false
    );

    // 从左到右：通用（白）→ 物理（黄）→ 魔法（紫）
    var armor_values = [armor_general, armor_physical, armor_magic];
    var armor_colors = [
        c_white,
        make_color_rgb(240, 200, 60),
        make_color_rgb(160, 90, 220)
    ];

    // 数字颜色：白、黄底用黑字，紫底用白字
    var armor_text_colors = [c_black, c_black, c_white];

    var seg_x = bar_x;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var n = 0; n < 3; n++)
    {
        // 没有这种护甲就不画对应颜色，也不写数字
        if (armor_values[n] <= 0) continue;

        // 按占总护甲的比例分配宽度
        var seg_w = hp_bar_width * armor_values[n] / total_armor;

        draw_set_color(armor_colors[n]);
        draw_rectangle(
            round(seg_x), ab_y,
            round(seg_x + seg_w), ab_y + ab_h,
            false
        );

        // 这一段正中间显示这种护甲的数值
        draw_set_color(armor_text_colors[n]);
        draw_text(
            seg_x + seg_w * 0.5,
            ab_y + ab_h * 0.5,
            string(armor_values[n])
        );

        seg_x += seg_w;
    }

    // 边框
    draw_set_color(c_dkgray);
    draw_rectangle(
        bar_x, ab_y,
        bar_x + hp_bar_width, ab_y + ab_h,
        true
    );

    // 恢复默认设置
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
// 状态图标：放在血条下方；护甲条显示时放在护甲条下方
var status_y = bar_y + hp_bar_height + 4;

if (total_armor > 0)
{
    status_y += hp_bar_height + 4;
}

draw_status_icons(id, bar_x, status_y);