life--;
if (life <= 0)
{
    instance_destroy();
    exit;
}

if (!instance_exists(target_enemy))
{
    target_enemy = noone;
    if (instance_exists(obj_hand_controller))
    {
        for (var i = 0; i < array_length(obj_hand_controller.enemies); i++)
        {
            var candidate = obj_hand_controller.enemies[i];
            if (instance_exists(candidate))
            {
                target_enemy = candidate;
                break;
            }
        }
    }
}

if (!instance_exists(target_enemy))
{
    instance_destroy();
    exit;
}

trail_x = x;
trail_y = y;
var aim_dir = point_direction(x, y, target_enemy.x, target_enemy.y);
image_angle = aim_dir;
var distance = point_distance(x, y, target_enemy.x, target_enemy.y);

if (distance <= projectile_speed)
{
    deal_damage(target_enemy, damage, damage_type);
    instance_destroy();
}
else
{
    x += lengthdir_x(projectile_speed, direction);
    y += lengthdir_y(projectile_speed, direction);
}
