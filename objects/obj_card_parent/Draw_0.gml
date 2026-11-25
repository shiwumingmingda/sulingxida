   /// obj_card_parent - Draw

   var card_tint = card_get_rarity_tint(id, sprite_index);
   draw_sprite_ext(sprite_index, image_index, x, y,
       image_xscale, image_yscale, image_angle, card_tint, image_alpha);
card_draw_text(id, sprite_index, x, y, image_xscale, image_yscale, image_angle);
card_draw_merge_frame(id, sprite_index, x, y, image_xscale, image_yscale, image_angle);