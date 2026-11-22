/// scr_arrow
/// 画一条从 (_x0,_y0) 弯向 (_x2,_y2) 的箭头

function draw_target_arrow(_x0, _y0, _x2, _y2, _col)
{
    var head_len = 32;   // 箭头头部长度
    var head_w   = 18;   // 箭头头部半宽
    var steps    = 30;   // 曲线分段数

    // 曲线控制点：取两端中间，并向上抬高，让箭头向上弯
    var x1 = (_x0 + _x2) * 0.5;
    var y1 = min(_y0, _y2) - 140;

    // 先画黑色描边，再画彩色主体
    for (var pass = 0; pass < 2; pass++)
    {
        draw_set_color((pass == 0) ? c_black : _col);
        var lw = (pass == 0) ? 12 : 7;

        var px = _x0;
        var py = _y0;

        for (var k = 1; k <= steps; k++)
        {
            var t = k / steps;
            var bx = sqr(1 - t) * _x0 + 2 * (1 - t) * t * x1 + sqr(t) * _x2;
            var by = sqr(1 - t) * _y0 + 2 * (1 - t) * t * y1 + sqr(t) * _y2;

            // 快到箭头头部了就停
            if (point_distance(bx, by, _x2, _y2) < head_len) break;

            draw_line_width(px, py, bx, by, lw);
            px = bx;
            py = by;
        }

        // 最后一段接到箭头头部的底边
        var dir = point_direction(px, py, _x2, _y2);
        var base_x = _x2 - lengthdir_x(head_len, dir);
        var base_y = _y2 - lengthdir_y(head_len, dir);
        draw_line_width(px, py, base_x, base_y, lw);
    }

    // 箭头头部
    var dir2 = point_direction(base_x, base_y, _x2, _y2);
    var lx = base_x + lengthdir_x(head_w, dir2 + 90);
    var ly = base_y + lengthdir_y(head_w, dir2 + 90);
    var rx = base_x + lengthdir_x(head_w, dir2 - 90);
    var ry = base_y + lengthdir_y(head_w, dir2 - 90);

    draw_set_color(_col);
    draw_triangle(_x2, _y2, lx, ly, rx, ry, false);

    draw_set_color(c_black);
    draw_triangle(_x2, _y2, lx, ly, rx, ry, true);

    draw_set_color(c_white);
}