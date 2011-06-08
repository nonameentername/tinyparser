#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <typeinfo>
#include <list>
#include <map>

using namespace std;

enum Type_t {
   INT_T,
   FLOAT_T
};

namespace AST {

struct ltstr
{
   bool operator()(const string s1, const string s2) const
   {
      return s1.compare(s2) < 0;
   }
};

class Node {

public:
   virtual ~Node(){}
   virtual void print(int tabIndex){}
   virtual string indent(int tabIndex)
   {
      string result = "";
      for(int index = 0; index < tabIndex; index++)
         result = result + "    ";

      return result;
   }
};

class Argument : public Node {

public:
   int type;

   Argument()
   {
      type = -1;
   }
   virtual ~Argument()
   {
   }
   virtual int GetType(map<string, int, ltstr> symbolTable)
   {
      return type;
   }
   string StringType()
   {
      if(type == INT_T)
         return "int";
      else
         return "float";
   }
};

class IntConst : public Argument {

public:
   int value;

   IntConst(){}
   virtual ~IntConst(){}
   virtual void print(int tabIndex)
   {
      cout << value;
   }
};

class DoubleConst : public Argument {

public:
   double value;

   DoubleConst(){}
   virtual ~DoubleConst(){}
   virtual void print(int tabIndex)
   {
      cout << value;
   }
};

class Variable : public Argument {

public:
   string *id;

   Variable(){}
   virtual ~Variable()
   {
      delete id;
   }

   virtual void print(int tabIndex)
   {
      cout << *id;
   }
   virtual int GetType(map<string, int, ltstr> symbolTable)
   {
      return type;
      if(symbolTable.find(*id) == symbolTable.end())
         throw "undefined variable";

      return symbolTable[*id];
   }
};

class Variable1D : public Variable {

public:
   Node *var1;

   Variable1D(){}
   virtual ~Variable1D()
   {
      delete var1;
   }
   virtual void print(int tabIndex)
   {
      cout << *id << "[";
      var1->print(tabIndex + 1);
      cout << "]";
   }
};

class Variable2D : public Variable {

public:
   Node *var1;
   Node *var2;

   Variable2D(){}
   virtual ~Variable2D()
   {
      delete var1;
      delete var2;
   }
   virtual void print(int tabIndex)
   {
      cout << *id << "[";
      var1->print(tabIndex + 1);
      cout << "][";
      var2->print(tabIndex + 1);
      cout << "]";
   }
};

class Statement : public Node {

public:
   Statement(){}
   virtual ~Statement(){}
   virtual void print(int tabIndex){}
};

class DeclarationStatement : public Statement {

public:
   int type;
   list<Node*> variables;

   DeclarationStatement()
   {
      type = -1;
   }
   virtual ~DeclarationStatement()
   {
      variables.clear();
   }
   virtual void print(int tabIndex)
   {
      string tab = indent(tabIndex);
      cout << tab << "<DeclarationStatement>" << endl;
      cout << tab << "    <Type> ";
      if(type == INT_T)
         cout << "int";
      else
         cout << "float";
      cout << tab << " </Type>" << endl;
      cout << tab;

      list<Node*>::iterator i;
      for(i = variables.begin(); i != variables.end(); i++)
      {
         cout << tab << "    <Variable> ";
         (*i)->print(tabIndex + 1);
         cout << tab << " </Variable>" << endl;
      }
      cout << tab << "</DeclarationStatement>" << endl;
   }
};

class IfStatement : public Statement {

public:
   Node *expression;
   Node *statement1;

   IfStatement(){}
   virtual ~IfStatement()
   {
      delete expression;
      delete statement1;
   }
   virtual void print(int tabIndex)
   {
      string tab = indent(tabIndex);

      cout << tab << "<IfStatement>" << endl;
      cout << tab << "    <Expression Type = ";
      cout << static_cast<Argument*>(expression)->StringType();
      cout << "> ";
      expression->print(tabIndex + 1);
      cout << " </Expression>" << endl;
      statement1->print(tabIndex + 1);
      cout << tab << "</IfStatement>" << endl;
   }
};

class IfElseStatement : public Statement {

public:
   Node *expression;
   Node *statement1;
   Node *statement2;

   IfElseStatement(){}
   virtual ~IfElseStatement()
   {
      delete expression;
      delete statement1;
      delete statement2;
   }
   virtual void print(int tabIndex)
   {
      string tab = indent(tabIndex);

      cout << tab << "<IfElseStatement>" << endl;
      cout << tab << "    <Expression Type = ";
      cout << static_cast<Argument*>(expression)->StringType();
      cout << "> ";
      expression->print(tabIndex + 1);
      cout << " </Expression>" << endl;
      statement1->print(tabIndex + 1);
      statement2->print(tabIndex + 1);
      cout << tab << "</IfElseStatement>" << endl;
   }
};

class WhileStatement : public Statement {

public:
   Node *expression;
   Node *statement1;

   WhileStatement(){}
   virtual ~WhileStatement()
   {
      delete expression;
      delete statement1;
   }
   virtual void print(int tabIndex)
   {
      string tab = indent(tabIndex);

      cout << tab << "<WhileStatement>" << endl;
      cout << tab << "    <Expression Type = ";
      cout << static_cast<Argument*>(expression)->StringType();
      cout << "> ";
      expression->print(tabIndex + 1);
      cout << " </Expression>" << endl;
      statement1->print(tabIndex + 1);
      cout << tab << "</WhileStatement>" << endl;
   }
};

class BlockStatement : public Statement {

public:
   list<Node*> statements;

BlockStatement(){}
virtual ~BlockStatement()
{
   statements.clear();
}
virtual void print(int tabIndex)
{
   string tab = indent(tabIndex);

   cout << tab << "<BlockStatement>" << endl;

   list<Node*>::iterator i;
   for(i = statements.begin(); i != statements.end(); i++)
   {
      (*i)->print(tabIndex + 1);
   }
   cout << tab << "</BlockStatement>" << endl;
}
};

class AssignmentStatement : public Statement {

public:
Node *variable;
Node *expression;

AssignmentStatement(){}
virtual ~AssignmentStatement()
{
   delete variable;
   delete expression;
}
virtual void print(int tabIndex)
{
   string tab = indent(tabIndex);

   cout << tab << "<AssignmentStatement>" << endl;
   cout << tab << "    <Variable> ";
   variable->print(tabIndex + 1);
   cout << " </Variable>" << endl;
   cout << tab << "    <Expression Type = ";
   cout << static_cast<Argument*>(expression)->StringType();
   cout << "> ";
   expression->print(tabIndex + 1);
   cout << " </Expression>" << endl;
   cout << tab << "</AssignmentStatement>" << endl;
}
};

class Expression : public Argument {

public:
   string *operation;
   Node *left;
   Node *right;

Expression(){}
   virtual ~Expression()
   {
      delete operation;
      delete left;
      delete right;
   }
   virtual void print(int tabIndex)
   {
      if(right == NULL)
      {
         cout << "! (";
         left->print(tabIndex + 1); 
         cout << ")";
      }
      else
      {
         cout << "(";
         left->print(tabIndex + 1);
         cout << " " << *operation << " ";
         right->print(tabIndex + 1);
         cout << ")";
      }
   }
};

class TreeBuilder {

public:
   list<Statement*> statements;
   map<string, int, ltstr> symbolTable;
   
   virtual ~TreeBuilder()
   {
      statements.clear();
      symbolTable.clear();
   }
   void validateType(Argument *a1, Argument *a2)
   {
      int t1 = a1->GetType(symbolTable);
      int t2 = a2->GetType(symbolTable);

      if (t1 != t2)
         throw "invalid syntax";
   }
   void print()
   {
      list<Statement*>::iterator i;

      for(i = statements.begin(); i != statements.end(); ++i)
         (*i)->print(0);
   }
};

};


