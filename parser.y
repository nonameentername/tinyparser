%{
    /*** C includes ***/

#include <stdio.h>
#include "parser.tab.h"
//#define DEBUG

void printp(char *token);

%}
    /*** Other Declarations ***/

%token SEMICOLON LPAREN RPAREN COMMA LBRACE RBRACE RBRACKET LBRACKET ASSIGN
%token LT GT EQ PLUS MINUS MULT DIV NOT AND OR IF ELSE WHILE INT FLOAT ID ICONST FCONST COMMENT

%%
    /*** Rules ***/

program
        : program_line                  { printp("program") }
        | program_line program          { printp("program") }
        ;

program_line
        : variable_declaration SEMICOLON { printp("program_line") }
        | statement                      { printp("program_line") }
        | COMMENT                        { printp("program_line") }
        ;

variable_declaration
        : type variable                         { printp("variable_declaration") }
        | variable_declaration COMMA variable   { printp("variable_declaration") }
        ;

type
        : INT                           { printp("type") }
        | FLOAT                         { printp("type") }
        ;
              
variable
        : ID                            { printp("variable") }
        | ID LBRACKET ICONST RBRACKET   { printp("variable") }
        | ID LBRACKET ICONST RBRACKET LBRACKET ICONST RBRACKET { printp("variable") }
        ;

statement
        : block_statement               { printp("statement") }
        | assignment_expression         { printp("statement") }
        | while_statement               { printp("statement") }
        | if_statement                  { printp("statement") }
        ;

while_statement
        : WHILE conditional_expression statement        { printp("while_statement") }
        ;
        
if_statement
        : IF conditional_expression statement                   { printp("if_statement") }
        | IF conditional_expression statement ELSE statement    { printp("if_statement") }
        ;
        
statement_list
        : statement                     { printp("statement_list") }
        | statement_list statement      { printp("statement_list") }
        ;
        
block_statement
        : LBRACE RBRACE                 { printp("block_statement") }
        | LBRACE statement_list RBRACE  { printp("block_statement") }
        ;

assignment_expression
        : variable ASSIGN conditional_expression SEMICOLON      { printp("assignment_expression") }
        | conditional_expression SEMICOLON                      { printp("assignment_expression") }
        ;

conditional_expression
        : variable                                      { printp("conditional_expression") }
        | ICONST                                        { printp("conditional_expression") }
        | FCONST                                        { printp("conditional_expression") }
        | LPAREN conditional_expression RPAREN          { printp("conditional_expression") }
        | NOT conditional_expression                    { printp("conditional_expression") }
        | conditional_expression arithmetic_operator  conditional_expression    { printp("conditional_expression") }
        | conditional_expression conditional_operator conditional_expression    { printp("conditional_expression") }
        ;       

arithmetic_operator
        : PLUS                          { printp("arithmetic_operator") }
        | MINUS                         { printp("arithmetic_operator") }
        | MULT                          { printp("arithmetic_operator") }
        | DIV                           { printp("arithmetic_operator") }
        ; 

conditional_operator
        : AND                           { printp("conditional_operator") }
        | OR                            { printp("conditional_operator") }
        | LT                            { printp("conditional_operator") }
        | GT                            { printp("conditional_operator") }
        | EQ                            { printp("conditional_operator") }
        ;


%%
    /*** Subroutines ***/

int main(void)
{
    /* Call the parser, then quit. */
    yyparse();

    return 0;
}

void printp(char *token)
{
#ifdef DEBUG
    printf(token);
    printf("\n");
#endif
}

yyerror( char * s ) 
{ 
    fprintf( stderr, "%s\n", s ); 
}
