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
   AST::ReturnStatement *t_return;
   AST::FunctionCall *t_functioncall;
   AST::Function    *t_function;
}

%token IF ELSE WHILE INT FLOAT ID ICONST FCONST COMMENT RETURN
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
   : functions body                 {
                                       printp("program:1");
                                    }
   | body                           {
                                       printp("program:2");
                                    }
   ;

functions
   : function_declaration           {
                                       printp("functions:1");
                                       tree.functions.push_back($<t_function>1);
                                    }
   | functions 
     function_declaration           {
                                       printp("functions:2");
                                       tree.functions.push_back($<t_function>2);
                                    }
   ;

body
   : statement                      {
                                       printp("body:1");
                                       tree.statements.push_back($<t_statement>1);
                                    }
   | body statement                 {
                                       printp("body:2");
                                       tree.statements.push_back($<t_statement>2);
                                    }
   ;

function_declaration
   : type ID
     '(' declaration_statement ')'  
      block_statement               { 
                                       printp("function_declaration");
                                       $<t_function>$ = new Function();
                                       $<t_function>$->type = $<t_type>1;
                                       $<t_function>$->id = $2;
                                       $<t_function>$->parms = $<t_declaration>4;
                                       $<t_function>$->statement = $<t_statement>6;
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
                                       $<t_variable>$->type = tree.getVariableType(*$1);
                                    }
   | ID '[' single_expression ']'   {
                                       printp("variable:2");
                                       $<t_variable1D>$ = new Variable1D();
                                       $<t_variable1D>$->id = $1;
                                       $<t_variable>$->type = tree.getVariableType(*$1);
                                       $<t_variable1D>$->var1 = $<t_argument>3;
                                    }
   | ID '[' single_expression ']' 
        '[' single_expression ']'   {
                                       printp("variable:3");
                                       $<t_variable2D>$ = new Variable2D();
                                       $<t_variable2D>$->id = $1;
                                       $<t_variable>$->type = tree.getVariableType(*$1);
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
   | return_statement               {
                                       printp("statement");
                                       $<t_statement>$ = $<t_return>1;
                                    }
   | COMMENT ';'                    {
                                       printp("statement");
                                    }
   ;

function_call
   : ID '(' ')'                     {
                                       printp("function_call:1");

                                       int funcType = tree.getFunctionType(*$1);
                                       if(funcType == -1)
                                          throw "undefined function";

                                       $<t_functioncall>$ = new FunctionCall();
                                       $<t_functioncall>$->id = $1;
                                       $<t_functioncall>$->type = funcType;
                                    } 
   | ID '(' function_call_parms ')' {
                                       printp("function_call:2");

                                       int funcType = tree.getFunctionType(*$1);
                                       if(funcType == -1)
                                          throw "undefined function";

                                       $<t_functioncall>$ = new FunctionCall();
                                       $<t_functioncall>$->id = $1;
                                       $<t_functioncall>$->type = funcType;
                                       $<t_functioncall>$->parms = tree.tempParmList;
                                    }
   ;

function_call_parms
   : variable                       {
                                       printp("function_call_parms:1");

                                       tree.tempParmList.clear();
                                       int varType = tree.getVariableType(*$<t_variable>1->id);

                                       if(varType == -1)
                                          throw "undefined variable";

                                       $<t_variable>1->type = varType;
                                       tree.tempParmList.push_back($<t_variable>1);
                                    }
   | function_call_parms
     ',' variable                   {
                                       printp("function_call_parms:2");

                                       int varType = tree.getVariableType(*$<t_variable>3->id);

                                       if(varType == -1)
                                          throw "undefined variable";

                                       $<t_variable>3->type = varType;
                                       tree.tempParmList.push_back($<t_variable>3);
                                    }
   ;

return_statement
   : RETURN expression ';'          {
                                       printp("return_statement");
                                       $<t_return>$ = new ReturnStatement();
                                       $<t_return>$->type = $<t_expression>2->type;
                                       $<t_return>$->expression = $<t_expression>2;
                                    }
        
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
   : variable '=' 
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

                                       int varType = tree.getVariableType(*$<t_variable>1->id);

                                       if(varType == -1)
                                          throw "undefined variable";

                                       $<t_variable>$->type = varType;
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
   | function_call                  {
                                       printp("single_expression:4");
                                       $<t_functioncall>$ = $<t_functioncall>1;
                                    }
   ;       


%%
    /*** Subroutines ***/

int main(int argc, char **argv)
{
   string gConst   = "-g";
   bool printGraph = false;

   if(argc > 1 && gConst.compare(argv[1]) == 0)
      printGraph = true;
 
   try
   {
   /* Call the parser, then quit. */
      yyparse();

      if(printGraph)
         tree.BuildControlFlowGraph();
      else
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
