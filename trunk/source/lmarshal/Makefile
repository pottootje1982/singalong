#------
# Modules belonging unix (local domain sockets)
#

EXT=so
MARSHAL_SO=lmarshal.so

CC=gcc
DEF=
CFLAGS=$(DEF) -I$(CURDIR)/../lua5.1/include -pedantic -Wall -O2 -fpic
LDFLAGS=-O -shared -fpic
LD=gcc 

all: $(MARSHAL_SO)

lmarshal.o: lmarshal.c lmarshal.h

$(MARSHAL_SO): lmarshal.o 
	$(LD) $(LDFLAGS) -o $@ -L$(CURDIR)/../lua5.1/include -llua

#------
# List of dependencies
#

clean:
	rm -f $(MARSHAL_SO) *.o

#------
# End of makefile configuration
#
