CC=gcc
LD = $(CC)
CFLAGS=-m32
LDFLAGS = -m32

robotasm.o: robotasm.asm
	nasm -felf robotasm.asm

robotarm.o: robotarm.c
	$(CC) $(CFLAGS) -c robotarm.c -lGL -lGLU -lglut

tarea: robotasm.o robotarm.o
	$(LD) $(LDFLAGS) robotarm.o robotasm.o -lGL -lGLU -lglut -o robotarm
	./robotarm instrucciones.txt
	
clean:
	rm -f *.o *.c~ *.asm~ Makefile~ 
