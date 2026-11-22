draw_set_alpha(0.45);
draw_set_color(make_color_rgb(255, 225, 125));
draw_line_width(trail_x, trail_y, x, y, 7);
draw_set_alpha(0.9);
draw_set_color(c_white);
draw_sprite_ext(spr_star, 0, x, y, 0.42, 0.42, image_angle, c_white, 1);
draw_set_alpha(1);
draw_set_color(c_white);
