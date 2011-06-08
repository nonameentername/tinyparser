#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <list>

using namespace std;

namespace AST {

class Node {

public:
   virtual ~Node(){}
   virtual void print(){}
};

class Argument : public Node {

public:
   Argument(){}
   virtual ~Argument(){}
};

class IntConst : public Argument {

public:
   int value;

   IntConst(){}
   virtual ~IntConst(){}
   virtual void print()
   {
      cout << value;
   }
};

class DoubleConst : public Argument {

public:
   double value;

   DoubleConst(){}
   virtual ~DoubleConst(){}
   virtual void print()
   {
      cout << value;
   }
};

class Variable : public Argument {

public:
   string *type;
   string *id;

   Variable(){}
   virtual ~Variable()
   {
      delete id;
   }

   virtual void print()
   {
      cout << *id;
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
   virtual void print()
   {
      cout << *id << "[";
      var1->print();
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
   virtual void print()
   {
      cout << *id << "[";
      var1->print();
      cout << "][";
      var2->print();
      cout << "]";
   }
};

class Statement : public Node {

public:
   Statement(){}
   virtual ~Statement(){}
   virtual void print()
   {
      cout << "implement" << endl;
   }
};

class DeclarationStatement : public Statement {

public:
   string *type;
   list<Node*> variables;

   DeclarationStatement(){}
   virtual ~DeclarationStatement()
   {
      variables.clear();
   }
   virtual void print()
   {
      cout << "DeclarationStatement{" << endl;
      cout << "   ";
      cout << *type;
      cout << " ";

      list<Node*>::iterator i;
      for(i = variables.begin(); i != variables.end(); i++)
      {
         cout << "   ";
         (*i)->print();
      }
      cout << endl;
      cout << "}" << endl;
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
   virtual void print()
   {
      cout << "IfStatement{" << endl;
      cout << "   expression:" << endl;
      expression->print();
      cout << endl << "   statement:" << endl;
      statement1->print();
      cout << "}" << endl;
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
   virtual void print()
   {
      cout << "IfElseStatement{" << endl;
      cout << "   expression:" << endl;
      expression->print();
      cout << endl << "   if_statement:" << endl;
      statement1->print();
      cout << "   else_statement:" << endl;
      statement2->print();
      cout << "}" << endl;
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
   virtual void print()
   {
      cout << "WhileStatement{" << endl;
      cout << "   expression:" << endl;
      cout << "   ";
      expression->print();
      cout << endl << "   statement:" << endl;
      statement1->print();
      cout << "}" << endl;
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
   virtual void print()
   {
      cout << "BlockStatement{" << endl;

      list<Node*>::iterator i;
      cout << "   statements:" << endl;
      for(i = statements.begin(); i != statements.end(); i++)
      {
         (*i)->print();
      }
      cout << "}" << endl;
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
   virtual void print()
   {
      cout << "AssignmentStatement{" << endl;
      cout << "   ";
      variable->print();
      cout << " = " << endl;
      cout << "   expression:" << endl;
      cout << "   ";
      expression->print();
      cout << endl << "}" << endl;
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
      delete left;
      delete right;
   }
   virtual void print()
   {
      if(right == NULL)
      {
         cout << "! (";
         left->print(); 
         cout << ")";
      }
      else
      {
         cout << "(";
         left->print();
         cout << " " << *operation << " ";
         right->print();
         cout << ")";
      }
   }
};

};


