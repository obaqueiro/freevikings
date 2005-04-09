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


/**** Fetches the VALUE from the g_pointer */
#define G_POINTER_TO_VALUE(p) (* ( (VALUE *) p ) )


int eql(VALUE obj1, VALUE obj2);


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
  rb_raise(rb_eRuntimeError, "'add' method still unimplemented.");
}

/**** Deletes the sprite from the SpriteManager. */

VALUE sm_delete(VALUE self_obj, VALUE sprite)
{
  GSList *s = sprites;
  gpointer data;

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_delete entered.");

  while (s != NULL) {
    if (eql(sprite, G_POINTER_TO_VALUE(s->data))) break;
    s = g_slist_next(s);
  }

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
    fv_log(G_LOG_LEVEL_DEBUG, "Going to test whether the sprites equal.");
    //if (eql(sprite, G_POINTER_TO_VALUE(s->data))) {
      /* The sprite we were looking for is here, we can return true. */
      //fv_log(G_LOG_LEVEL_DEBUG, "Function sm_include_sprite exited");
      //return Qtrue;
    //}
    fv_log(G_LOG_LEVEL_DEBUG, "Iterate on!");
    s = g_slist_next(s);
  }
  fv_log(G_LOG_LEVEL_DEBUG, "SpriteManager does not include the sprite.");

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_include_sprite exited.");
  return Qnil;
}

VALUE sm_sprites_on_rect(VALUE self_obj, VALUE rect)
{
  VALUE ary = rb_ary_new(); /* An array of the sprites colliding 
		 with the specified rect */
  VALUE *return_ary; /* A dynamic allocated array to be returned */
  GSList *s = NULL;

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_sprites_on_rect entered.");

  // for (s = sprites; s != NULL; s = g_slist_next(s)) {  }

  return_ary = (VALUE *) g_malloc(sizeof(ary));
  *return_ary = ary;

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_sprites_on_rect exited.");
  return *return_ary;
}


/**** Finds out whether the two VALUEs are equal (uses the eql? method) */

int eql(VALUE obj1, VALUE obj2) 
{
  fv_log(G_LOG_LEVEL_DEBUG, "Function eql entered.");

  if (rb_funcall((obj1), rb_intern("eql?"), 1, (obj2))) {
    fv_log(G_LOG_LEVEL_DEBUG, "Function eql exited.");
    return 1;
  } else {
    fv_log(G_LOG_LEVEL_DEBUG, "Function eql exited.");
    return 0;
  }
}
