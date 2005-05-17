# SpriteManager extension Makefile.
# igneus 11.4.2005

CPP=g++

RUBY_H=-I/usr/lib/ruby/1.8/i386-linux-gnu

all: extspritemanager.so

extspritemanager.so: spritemanager.o smmain.o smcontext.o
	$(CPP) -fpic -shared spritemanager.o smmain.o smcontext.o -o extspritemanager.so

smmain.o: smmain.cpp
	$(CPP) -Wno-return-type -c smmain.cpp $(RUBY_H)

spritemanager.o: spritemanager.cpp spritemanager.hpp
	$(CPP) -c spritemanager.cpp $(RUBY_H)

smcontext.o: smcontext.cpp smcontext.hpp
	$(CPP) -c smcontext.cpp $(RUBY_H)

clean:
	rm -f *.o *.so
