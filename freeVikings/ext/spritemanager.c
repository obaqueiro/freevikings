/*
spritemanager.c

igneus 8.4.2005
A standard SpriteManager replacement - it's a try to make it quicker.

This file contains all the ruby interface stuff - no other parts of this
module communicate with the interpreted through it's API.
*/

#include <glib.h>
#include "ruby.h"
#include "spritemanager.h"

/* FreeVikings module name */
#define FV_MODULE_NAME "FreeVikings"
/* FreeVikings::Extensions module name */
#define EXT_MODULE_NAME "Extensions"
/* SpriteManager class name */
#define SPRITE_MANAGER_CLASS_NAME "SpriteManager"


static void define_modules();
static void define_SpriteManager_class();


/* Extension library global variables: */
VALUE free_vikings_module;
VALUE extensions_module;
VALUE sprite_manager_klass;


/* Initialises the extension module */

Init_extspritemanager()
{
  /* Define modules and SpriteManager class: */
  define_modules();
  define_SpriteManager_class();
}

static void define_modules()
{
  free_vikings_module = rb_define_module(FV_MODULE_NAME);
  extensions_module = rb_define_module_under(free_vikings_module, EXT_MODULE_NAME);
}

static void define_SpriteManager_class()
{
  sprite_manager_klass = rb_define_class_under(extensions_module, SPRITE_MANAGER_CLASS_NAME, rb_cObject);

  rb_define_method(sprite_manager_klass, "initialize", sm_initialize, 1);
}
