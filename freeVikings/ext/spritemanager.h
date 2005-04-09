/*
spritemanager.h

igneus 9.4.2005
SpriteManager extension module global definitions.
*/

/* Structure for SpriteManager objects internal data storage */


/* SpriteManager instance methods routines: */
VALUE sm_initialize(VALUE self_obj, VALUE location);
VALUE sm_add(VALUE self_obj, VALUE sprite);
VALUE sm_delete(VALUE self_obj, VALUE sprite);
VALUE sm_paint(VALUE self_obj, VALUE arguments);
VALUE sm_update(VALUE self_obj, VALUE arguments);
VALUE sm_sprites_on_rect(VALUE self_obj, VALUE arguments);
VALUE sm_include_sprite(VALUE self_obj, VALUE sprite);

/* Some glib logging stuff: */

/* Log domain used by glib functions: */
#define G_LOG_DOMAIN "SpriteManager"
/* Loggs the message of a specified level */
#define fv_log(level, message) (g_log(G_LOG_DOMAIN, level, "%s(%i): %s", __FILE__, __LINE__, message))
