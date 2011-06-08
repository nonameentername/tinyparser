%{
    /*** C includes ***/

#include <string>
#include <iostream>
#include <list>
#include "treebuilder.h"
#include "parser.tab.h"
//#define DEBUG

using namespace std;
using namespace AST;

void printp(string token);

void yyerror(char *s); 
int yylex();

TreeBuilder tree;

%}
    /*** Other Declarations ***/

%union {
   AST::Argument    *t_argument;
   AST::IntConst    *t_int;
   AST::DoubleConst *t_double;
   std::string      *t_string;
   int              t_type;
   std::string      *t_operator;
   AST::Variable    *t_variable;
   AST::Variable1D  *t_variable1D;
   AST::Variable2D  *t_variable2D;
   AST::Statement   *t_statement;
   AST::Expression  *t_expression;
   AST::IfStatement *t_if;
   AST::IfElseStatement *t_ifelse;
   AST::WhileStatement  *t_while;
   AST::BlockStatement  *t_block;
   AST::DeclarationStatement *t_declaration;
   AST::AssignmentStatement  *t_assignment;
}

%token IF ELSE WHILE INT FLOAT ID ICONST FCONST COMMENT
%nonassoc IFELSE
%token ';' '(' ')' ',' '{' '}' '[' ']' '='
%left  OR
%left  AND
%left  EQ
%left  '<' '>'
%left  '+' '-'
%left  '*' '/'
%right '!'

%type <t_int>    ICONST
%type <t_double> FCONST
%type <t_string> ID
%type <t_type>   INT FLOAT

%expect 1

%%
    /*** Rules ***/
program
   : statement                      {
                                       printp("program:1");
                                       tree.statements.push_back($<t_statement>1);
                                    }
   | program statement              {
                                       printp("program:2");
                                       tree.statements.push_back($<t_statement>2);
                                    }
   ;

declaration_statement
   : type variable                  {
                                       printp("declaration_statement");
                                       $<t_declaration>$ = new DeclarationStatement();
                                       $<t_declaration>$->type = $<t_type>1;
                                       $<t_variable>2->type = $<t_type>1;
                                       $<t_declaration>$->variables.push_back($<t_variable>2);

                                       tree.symbolTable[*$<t_variable>2->id] = $<t_variable>2->type;
                                    }
   | declaration_statement 
     ',' variable                   {
                                       printp("declaration_statement");
                                       $<t_declaration>$ = $<t_declaration>1;
                                       $<t_variable>3->type = $<t_declaration>1->type;
                                       $<t_declaration>$->variables.push_back($<t_variable>3);

                                       tree.symbolTable[*$<t_variable>3->id] = $<t_variable>3->type;
                                    }
   ;

type
   : INT                            {
                                       printp("type");
                                       $<t_type>$ = INT_T;
                                    }
   | FLOAT                          {
                                       printp("type");
                                       $<t_type>$ = FLOAT_T;
                                    }
   ;
              
variable
   : ID                             {
                                       printp("variable:1");
                                       $<t_variable>$ = new Variable();
                                       $<t_variable>$->id = $1;
                                    }
   | ID '[' single_expression ']'   {
                                       printp("variable:2");
                                       $<t_variable1D>$ = new Variable1D();
                                       $<t_variable1D>$->id = $1;
                                       $<t_variable1D>$->var1 = $<t_argument>3;
                                    }
   | ID '[' single_expression ']' 
        '[' single_expression ']'   {
                                       printp("variable:3");
                                       $<t_variable2D>$ = new Variable2D();
                                       $<t_variable2D>$->id = $1;
                                       $<t_variable2D>$->var1 = $<t_argument>3;
                                       $<t_variable2D>$->var2 = $<t_argument>6;
                                    }
   ;

statement
   : if_statement                   {
                                       printp("statement");
                                       $<t_statement>$ = $<t_statement>1;
                                    }
   | while_statement                {
                                       printp("statement");
                                       $<t_statement>$ = $<t_while>1;
                                    }
   | block_statement                {
                                       printp("statement"); 
                                       $<t_statement>$ = $<t_block>1;
                                    }
   | assignment_statement           {
                                       printp("statement");
                                       $<t_statement>$ = $<t_assignment>1;
                                    }
   | declaration_statement ';'      {
                                       printp("statement");
                                       $<t_statement>$ = $<t_declaration>1;
                                    }
   | COMMENT ';'                    {
                                       printp("statement");
                                    }
   ;

while_statement
   : WHILE '(' expression ')'
     statement                      {
                                       printp("while_statement");
                                       $<t_while>$ = new WhileStatement();
                                       $<t_while>$->expression = $<t_expression>3;
                                       $<t_while>$->statement1 = $<t_statement>5;
                                    }
   ;
        
if_statement
   : IF '(' expression ')'
     statement                      {
                                       printp("if_statement");
                                       $<t_if>$ = new IfStatement();
                                       $<t_if>$->expression = $<t_expression>3;
                                       $<t_if>$->statement1 = $<t_statement>5;
                                    }
   | IF '(' expression ')'
     statement 
     ELSE statement                 {
                                       printp("if_statement");
                                       $<t_ifelse>$ = new IfElseStatement();
                                       $<t_ifelse>$->expression = $<t_expression>3;
                                       $<t_ifelse>$->statement1 = $<t_statement>5;
                                       $<t_ifelse>$->statement2 = $<t_statement>7;
                                    }
   ;
        
statement_list
   : statement                      {
                                       printp("statement_list");
                                       $<t_block>$ = new BlockStatement();
                                       $<t_block>$->statements.push_back($<t_statement>1);
                                    }
   | statement_list statement       {
                                       printp("statement_list");
                                       $<t_block>$ = $<t_block>1;
                                       $<t_block>$->statements.push_back($<t_statement>2);
                                    }
   ;
        
block_statement
   : '{' '}'                        {
                                       printp("block_statement");
                                       $<t_block>$ = new BlockStatement();
                                    }
   | '{' statement_list '}'         {
                                       printp("block_statement");
                                       $<t_block>$ = $<t_block>2;
                                    }
   ;

assignment_statement
   : single_expression '=' 
     expression ';'                 {
                                       printp("assignment_statement");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_assignment>$ = new AssignmentStatement();
                                       $<t_assignment>$->variable = $<t_variable>1; 
                                       $<t_assignment>$->expression = $<t_expression>3; 
                                    }

expression
   : expression OR expression       {
                                       printp("expression:1");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("OR");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression AND expression      {
                                       printp("expression:2");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("AND");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression EQ expression       {
                                       printp("expression:3");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("EQ");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression '<' expression      {
                                       printp("expression:4");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("<");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    } 
   | expression '>' expression      {
                                       printp("expression:5");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string(">");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression '+' expression      {
                                       printp("expression:6");

                                       tree.validateType($<t_argument>1, $<t_argument>3);

                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("+");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression '-' expression      {
                                       printp("expression:7");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("-");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression '*' expression      {
                                       printp("expression:8");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("*");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | expression '/' expression      {
                                       printp("expression:9");

                                       tree.validateType($<t_argument>1, $<t_argument>3);
                                          
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>1;
                                       $<t_expression>$->operation = new string("/");
                                       $<t_expression>$->right = $<t_argument>3;
                                       $<t_expression>$->type = $<t_argument>1->type;
                                    }
   | '(' expression ')'             {
                                       printp("expression:10");
                                       $<t_argument>$ = $<t_argument>2;
                                    }
   | '!' expression                 {
                                       printp("expression:11");
                                       $<t_expression>$ = new Expression();
                                       $<t_expression>$->left = $<t_argument>2;
                                       $<t_expression>$->operation = new string("!");
                                       $<t_expression>$->right = NULL;
                                       $<t_expression>$->type = $<t_argument>2->type;
                                    }
   | single_expression              {
                                       printp("expression:12");
                                       $<t_argument>$ = $<t_argument>1;
                                    }

single_expression
   : variable                       {
                                       printp("single_expression:1");
                                       $<t_variable>$ = $<t_variable>1;
                                       if(tree.symbolTable.find(*$<t_variable>1->id) == tree.symbolTable.end())
                                          throw "undefined variable";
                                       $<t_variable>$->type = tree.symbolTable[*$<t_variable>1->id];
                                    }
   | ICONST                         {
                                       printp("single_expression:2");
                                       $<t_int>$ = $1;
                                       $<t_int>$->type = INT_T;
                                    }
   | FCONST                         {
                                       printp("single_expression:3");
                                       $<t_double>$ = $1;
                                       $<t_double>$->type = FLOAT_T;
                                    }
   ;       


%%
    /*** Subroutines ***/

int main(void)
{
   /* Call the parser, then quit. */
   
   try
   {
      yyparse();
      tree.print();
   }
   catch (char const* error)
   {
      cout << error << endl;
   }

   return 0;
}

void printp(string token)
{
#ifdef DEBUG
   cout << token << endl;
#endif
}

void yyerror( char * s ) 
{ 
   fprintf( stderr, "%s\n", s ); 
}
