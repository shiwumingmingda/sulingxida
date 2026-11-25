   /// obj_card_parent - Draw

   var card_spr = card_get_rarity_sprite(id, sprite_index);
   if (card_spr == sprite_index)
       draw_self();
   else
       draw_sprite_ext(card_spr, image_index, x, y,
           image_xscale, image_yscale, image_angle, c_white, image_alpha);
card_draw_text(id, card_spr, x, y, image_xscale, image_yscale, image_angle);
card_draw_merge_frame(id, card_spr, x, y, image_xscale, image_yscale, image_angle);