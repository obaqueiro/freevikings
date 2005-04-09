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

/* A linked list of all the sprites (at the moment we don't recognize
   the individual SpriteManagers - it can be a problem). */
GSList *sprites = NULL;



/* Initializes the new SpriteManager. 
   Actually, it only frees all the sprites linked list elements.
   It means - whenever you think you've just made a new SpriteManager,
   You've only destroyed the old one's contents. */

VALUE sm_initialize(VALUE self_obj, VALUE location)
{
  g_slist_free(sprites);
}

/* Adds the sprite into the SpriteManager. */

VALUE sm_add(VALUE self_obj, VALUE sprite)
{
  /* g_ptr_array_add(sprites_p, (gpointer *) &sprite); */
  gpointer sprite_p;
  sprite_p = g_memdup(&sprite, sizeof(sprite));
  sprites = g_slist_append(sprites, sprite_p);
  return Qtrue;
}

/* Returns true if the sprite is present in the manager or nil otherwise */

VALUE sm_include_sprite(VALUE self_obj, VALUE sprite)
{
  GSList *s = sprites; /* A temporary variable for iterating over the
		    linked list */

  do {
    VALUE *obj_in_s = (VALUE *) s->data; /* A ruby object stored in the
					  linked list item just iterated over*/
    if (rb_funcall(sprite, rb_intern("equal?"), 1, *obj_in_s)) {
      return Qtrue;
    }
  } while ((s = g_slist_next(sprites)) != NULL);
  return Qnil;
}
