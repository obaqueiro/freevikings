/*
smmethods.c

igneus 9.4.2005
A part of SpriteManager extension module.

This file contains all the procedures which are called whenever
Ruby code calls some of the FreeVikings::Extensions::SpriteManager methods.
*/

#include <glib.h>
#include "ruby.h"
#include "spritemanager.h"


/**** Finds out whether the two VALUEs are equal (uses the eql? method) */
#define eql(obj1, obj2) (rb_funcall(obj1, rb_intern("eql?"), 1, obj2))
/**** Fetches the VALUE from the g_pointer */
#define G_POINTER_TO_VALUE(p) (* ( (VALUE *) p ) )

/* A linked list of all the sprites (at the moment we don't recognize
   the individual SpriteManagers - it can be a problem). */
GSList *sprites = NULL;



/**** Initializes the new SpriteManager. 
   Actually, it only frees all the sprites linked list elements.
   It means - whenever you think you've just made a new SpriteManager,
   You've only destroyed the old one's contents. */

VALUE sm_initialize(VALUE self_obj, VALUE location)
{
  g_slist_free(sprites);
  fv_log(G_LOG_LEVEL_DEBUG, "Created a new SpriteManager");
}

/**** Adds the sprite into the SpriteManager. */

VALUE sm_add(VALUE self_obj, VALUE sprite)
{
  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_add entered.");

  gpointer sprite_p;
  sprite_p = g_memdup(&sprite, sizeof(sprite));
  sprites = g_slist_append(sprites, sprite_p);

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_add exited.");

  return Qtrue;
}

/**** Deletes the sprite from the SpriteManager. */

VALUE sm_delete(VALUE self_obj, VALUE sprite)
{
  GSList *s = sprites;
  gpointer data;

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_delete entered.");

  do {
    if (eql(sprite, G_POINTER_TO_VALUE(s->data))) break;
  } while ((s = g_slist_next(sprites)) != NULL);

  if (s == NULL) {
    fv_log(G_LOG_LEVEL_DEBUG, "Sprite was not find. It could not be deleted then.");
  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_delete exited.");
    return Qnil;
  } else {
    fv_log(G_LOG_LEVEL_DEBUG, "I'm going to delete the sprite.");
    data = s->data;
    sprites = g_slist_remove(sprites, data);
    fv_log(G_LOG_LEVEL_DEBUG, "Sprite deleted.");
    fv_log(G_LOG_LEVEL_DEBUG, "Function sm_delete exited.");
    return Qtrue;
  }
}

/**** Returns true if the sprite is present in the manager or nil otherwise */

VALUE sm_include_sprite(VALUE self_obj, VALUE sprite)
{
  GSList *s = sprites; /* A temporary variable for iterating over the
		    linked list */

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_include_sprite entered.");

  while (s != NULL) {
    if (eql(sprite, G_POINTER_TO_VALUE(s->data))) return Qtrue;
    s = g_slist_next(sprites);
  }
  fv_log(G_LOG_LEVEL_DEBUG, "SpriteManager does not include the sprite.");

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_include_sprite exited.");
  return Qnil;
}
