all: test

test: y.tab.c lex.yy.c tab_symboles.c
	gcc y.tab.c lex.yy.c tab_symboles.c -ll -o test

y.tab.c: parser.y
	yacc -d parser.y
	
lex.yy.c: test.l
	flex test.l

clean:
	rm -rf *.o
	rm -rf lex.yy.c
	rm -rf y.tab.c
	rm -rf y.tab.h
	rm -rf test

mrproper: clean
	rm -rf test
