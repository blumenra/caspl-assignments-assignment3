
all: ass3

ass3: scheduler.o  ass3.o  coroutines.o  cell.o  printer.o
	gcc -g -Wall -m32 scheduler.o  ass3.o  coroutines.o  cell.o  printer.o -o ass3

# ass3: scheduler.o  ass3.o  coroutines.o  printer.o
# 	gcc -g -Wall -m32 ass3.o  scheduler.o  coroutines.o  printer.o -o ass3

scheduler.o: scheduler.s
	nasm -g -f elf -w+all -o scheduler.o scheduler.s

ass3.o: ass3.s
	nasm -g -f elf -w+all -o ass3.o ass3.s

coroutines.o: coroutines.s
	nasm -g -f elf -w+all -o coroutines.o coroutines.s

printer.o: printer.s
	nasm -g -f elf -w+all -o printer.o printer.s

cell.o: cell.c
	gcc -g -Wall -m32 -c cell.c -o cell.o

.PHONY:
	clean

clean:
	rm -f ./*.o  ass3