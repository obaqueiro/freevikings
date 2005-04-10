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
gpointer nullsprite = NULL;



/**** Initializes the new SpriteManager. 
   Actually, it only frees all the sprites linked list elements.
   It means - whenever you think you've just made a new SpriteManager,
   You've only destroyed the old one's contents. */

VALUE sm_initialize(VALUE self_obj, VALUE location)
{
  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_initialize entered.");

  g_slist_free(sprites);

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_initialize exited.");
}

/**** Adds the sprite into the SpriteManager. */

VALUE sm_add(VALUE self_obj, VALUE sprite)
{
  gpointer sprite_p;

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_add entered.");

  fv_log(G_LOG_LEVEL_DEBUG, "Copying the sprite's VALUE");
  sprite_p = g_new(VALUE, 1);
  fv_log(G_LOG_LEVEL_DEBUG, "Inserting the copied VALUE to the sprites list.");
  sprites = g_slist_append(sprites, nullsprite);

  fv_log(G_LOG_LEVEL_DEBUG, "Function sm_add exited.");
}
