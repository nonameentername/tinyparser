all: parser

lex.yy.cpp: lexer.l parser.tab.h
	flex -o lex.yy.cpp lexer.l

parser.tab.cpp: parser.y
	bison parser.y -o parser.tab.cpp

parser.tab.h: parser.y
	bison parser.y -d
	rm parser.tab.c

lex.yy.o: lex.yy.cpp
	g++ -c lex.yy.cpp -o lex.yy.o

parser: lex.yy.o parser.tab.cpp treebuilder.h
	g++ lex.yy.o parser.tab.cpp -o parser

clean:
	rm -f *.o lex.yy.cpp  parser.tab.cpp parser.tab.h parser
	
