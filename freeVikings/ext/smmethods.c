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

GList *sprites = NULL;

VALUE sm_initialize(VALUE self_obj, VALUE location)
{
}

VALUE sm_add(VALUE self_obj, VALUE sprite)
{
  /* g_ptr_array_add(sprites_p, (gpointer *) &sprite); */
  gpointer sprite_p;
  sprite_p = g_memdup(&sprite, sizeof(sprite));
  sprites = g_list_append(sprites, sprite_p);
  return Qtrue;
}

VALUE sm_include_sprite(VALUE self_obj, VALUE sprite)
{
  GList *s = NULL;
  while ((s = g_list_next(sprites)) != NULL) {
    if ( (VALUE) s->data == sprite ) {
      return Qtrue;
    }
  }
  return Qnil;
}
