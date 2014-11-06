robotasm.o: robotasm.asm
	nasm -felf robotasm.asm

robotarm.o: robotarm.c
	gcc -c robotarm.c -lGL -lGLU -lglut

tarea: robotasm.o robotarm.o
	gcc robotarm.o robotasm.o -lGL -lGLU -lglut -o robotarm
	./robotarm instrucciones.txt
	
clean:
	rm -f *.o *.c~ *.asm~ Makefile~ 
