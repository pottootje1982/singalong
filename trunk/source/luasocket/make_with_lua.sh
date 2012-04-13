make clean
make LUAINC="-I$(pwd)/../lua5.1/include" LDFLAGS="-O -shared -fpic -L$(pwd)/../lua5.1/include -llua"