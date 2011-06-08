%{
    /*** C includes ***/

#include <stdio.h>
#include "parser.tab.h"
//#define DEBUG

int  yywrap();
void printn(char *token);

%}
    /*** Definitions ***/

ALPHA    [A-za-z]
NUM      [0-9]
ALPHANUM [A-za-z0-9]

%%
    /*** Rules ***/

";"                     { printn("SEMICOLON");  return SEMICOLON;       }
"("                     { printn("LPAREN");     return LPAREN;          }
")"                     { printn("RPAREN");     return RPAREN;          }
","                     { printn("COMMA");      return COMMA;           }
"{"                     { printn("LBRACE");     return LBRACE;          }
"}"                     { printn("RBRACE");     return RBRACE;          }
"["                     { printn("LBRACKET");   return LBRACKET;        }
"]"                     { printn("RBRACKET");   return RBRACKET;        }
"="                     { printn("ASSIGN");     return ASSIGN;          }
"<"                     { printn("LT");         return LT;              }
">"                     { printn("GT");         return GT;              }
"=="                    { printn("EQ");         return EQ;              }
"+"                     { printn("PLUS");       return PLUS;            }
"-"                     { printn("MINUS");      return MINUS;           }
"*"                     { printn("MULT");       return MULT;            }
"/"                     { printn("DIV");        return DIV;             }
"!"                     { printn("NOT");        return NOT;             }
"&&"                    { printn("AND");        return AND;             }
"||"                    { printn("OR");         return OR;              }
"if"                    { printn("IF");         return IF;              }
"else"                  { printn("ELSE");       return ELSE;            }
"while"                 { printn("WHILE");      return WHILE;           }
"int"                   { printn("INT");        return INT;             }
"float"                 { printn("FLOAT");      return FLOAT;           }
{ALPHA}{ALPHANUM}*      { printn("ID");         return ID;              }
{NUM}+                  { printn("ICONST");     return ICONST;          }
({NUM}+[\.E]{NUM}+)|({NUM}+\.{NUM}+e[\+-]{NUM}+) { 
                          printn("FCONST");     return FCONST;          }
"/*"(\*[^/]|[^\*])*"*/" { printn("COMMENT");    return COMMENT;         }
[ \t\v\n\f]		{                                               }
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

void printn(char *token)
{
#ifdef DEBUG
    printf(token);
    printf("\n");
#endif
}

int yywrap()
{
    return 1;
}

