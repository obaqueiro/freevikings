# freeVikings C/C++ extensions Makefile
# igneus 8.4.2005

RUBY_FLAGS=-I/usr/lib/ruby/1.8/i586-linux
GLIB_FLAGS=`glib-config --libs --cflags`

all: extspritemanager.so

extspritemanager.so: spritemanager.o smmethods.o
	gcc -fpic -shared spritemanager.o smmethods.o -o extspritemanager.so

spritemanager.o: spritemanager.c
	gcc -c spritemanager.c $(RUBY_FLAGS) $(GLIB_FLAGS)

smmethods.o: smmethods.c
	gcc -c smmethods.c $(RUBY_FLAGS) $(GLIB_FLAGS)

clean:
	rm -f *.o *.so