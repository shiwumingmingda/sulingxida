/// obj_damage_text - Create

text = "-5";          // 创建后会被覆盖成实际伤害
life = 60;            // 存活帧数,60帧约1秒
rise_speed = 1.2;     // 每帧上升的像素

depth = -20000;       // 显示在所有东西最上面

// Create 里加：
col = make_color_rgb(255, 70, 70);   // 默认红色，回血时会改成绿色