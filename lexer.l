%{
    /*** C includes ***/

#include <string>
#include <iostream>
#include <math.h>
#include "treebuilder.h"
#include "parser.tab.h"

//#define DEBUG

using namespace std;
using namespace AST;

void printn(string token);

char *p;
%}
    /*** Definitions ***/

ALPHA    [a-zA-Z]
NUM      [0-9]
ALPHANUM [a-zA-Z0-9]

%%
    /*** Rules ***/

";"                     { printn("SEMICOLON");  return ';';             }
"("                     { printn("LPAREN");     return '(';             }
")"                     { printn("RPAREN");     return ')';             }
","                     { printn("COMMA");      return ',';             }
"{"                     { printn("LBRACE");     return '{';             }
"}"                     { printn("RBRACE");     return '}';             }
"["                     { printn("LBRACKET");   return '[';             }
"]"                     { printn("RBRACKET");   return ']';             }
"="                     { printn("ASSIGN");     return '=';             }
"<"                     { printn("LT");         return '<';             }
">"                     { printn("GT");         return '>';             }
"=="                    { printn("EQ");         return EQ;              }
"+"                     { printn("PLUS");       return '+';             }
"-"                     { printn("MINUS");      return '-';             }
"*"                     { printn("MULT");       return '*';             }
"/"                     { printn("DIV");        return '/';             }
"!"                     { printn("NOT");        return '!';             }
"&&"                    { printn("AND");        return AND;             }
"||"                    { printn("OR");         return OR;              }
"if"                    { printn("IF");         return IF;              }
"else"                  { printn("ELSE");       return ELSE;            }
"while"                 { printn("WHILE");      return WHILE;           }
"int"                   { printn("INT");        return INT;             }
"float"                 { printn("FLOAT");      return FLOAT;           }
"return"                { printn("RETURN");     return RETURN;          }
{ALPHA}{ALPHANUM}*      {
                           printn("ID");
                           yylval.t_string = new string(yytext);
                           return ID;              
                        }
{NUM}+                  { 
                           printn("ICONST");
                           yylval.t_int = new IntConst();
                           yylval.t_int->value = atoi(yytext);
                           return ICONST;
                        }
({NUM}+[\.E]{NUM}+)|({NUM}+\.{NUM}+e[\+-]{NUM}+) { 
                           printn("FCONST");
                           yylval.t_double = new DoubleConst();
                           yylval.t_double->value = atof(yytext);
                           return FCONST;                               }
"/*"(\*[^/]|[^\*])*"*/" { printn("COMMENT");    return COMMENT;         }
[ \t\v\n\f]		         { printn("WHITE");                              }
.                       { printn("IGNORING");                           }

%%
    /*** Subroutines ***/

//int main(void)
//{
//    /* Call the lexer, then quit. */
//    while(1)
//       yylex();
//    return 0;
//}

void printn(string token)
{
#ifdef DEBUG
   cout << token << endl;
#endif
}

int yywrap()
{
    return 1;
}

