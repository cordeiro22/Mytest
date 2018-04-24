lex  uccompiler.l
yacc -d -v uccompiler.y 
clang-3.8 -Wall -o uccompiler -Wno-unused-function  y.tab.c ast.c   lex.yy.c




