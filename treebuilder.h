#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <typeinfo>
#include <list>
#include <map>
#include <sstream>
#include <iostream>

using namespace std;

enum Type_t {
   INT_T,
   FLOAT_T
};

namespace AST {

string getStringType(int type);

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
   virtual string getString()
   {
      return "";
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
   virtual string getString()
   {
      ostringstream os;
      os << value;
      return os.str();
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
   virtual string getString()
   {
      ostringstream os;
      os << value;
      return os.str();
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
   virtual string getString()
   {
      return *id;
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
   virtual string getString()
   {
      return *id + "[" + var1->getString() + "]";
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
   virtual string getString()
   {
      return *id + "[" + ((string)var1->getString()) + "][" + ((string)var2->getString()) + "]";
   }
};

class Function: public Argument {

public:
   string *id;
   Node *parms;
   Node *statement;
   
   virtual ~Function()
   {
      delete id;
      delete parms;
      delete statement;
   }
   virtual void print(int tabIndex)
   {
      string tab = indent(tabIndex);

      cout << tab << "<Function>" << endl;
      cout << tab << "    <ReturnType> ";
      cout << getStringType(type);
      cout << " </ReturnType>" << endl;
      cout << tab << "    <ID> ";
      cout << *id;
      cout << " </ID>" << endl;
      parms->print(tabIndex + 1);
      statement->print(tabIndex+1);
      cout << tab << "</Function>" << endl;
   }
};

class FunctionCall : public Argument {

public:
   string *id;
   list<Variable*> parms;

   virtual ~FunctionCall()
   {
      delete id;
   }
   virtual void print(int tabIndex)
   {
      cout << *id << "(";

      list<Variable*>::iterator i;

      for(i = parms.begin(); i != parms.end(); i++)
         cout << " " << getStringType(static_cast<Argument*>(*i)->type) << " " << *(*i)->id;
      
      cout << " )"; 
   }
   virtual string getString()
   {
      ostringstream os;
      os << *id << "(";

      list<Variable*>::iterator i;
      for(i = parms.begin(); i != parms.end(); i++)
         os << " " << getStringType(static_cast<Argument*>(*i)->type) << " " << *(*i)->id;
      
      os << " )"; 
      return os.str();
   }
};

class Statement : public Node {

public:
   Statement(){}
   virtual ~Statement(){}
   virtual void print(int tabIndex){}
};

class ReturnStatement : public Statement {

public:
   int type;
   Node *expression;

   virtual ~ReturnStatement()
   {
      delete expression;
   }
   virtual void print(int tabIndex)
   {
      string tab = indent(tabIndex);
      cout << tab << "<ReturnStatement>" << endl;
      cout << tab << "    <Type> ";
      cout << getStringType(type);
      cout << " </Type>" << endl;
      cout << tab << "    <Expression Type = ";
      cout << getStringType(static_cast<Argument*>(expression)->type);
      cout << "> ";
      expression->print(tabIndex + 1);
      cout << " </Expression>" << endl;

      cout << tab << "</ReturnStatement>" << endl;
   }
};

class DeclarationStatement : public Statement {

public:
   int type;
   list<Argument*> variables;

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
      cout << getStringType(type);
      cout << " </Type>" << endl;

      list<Argument*>::iterator i;
      for(i = variables.begin(); i != variables.end(); i++)
      {
         cout << tab << "    <Variable> ";
         (*i)->print(tabIndex + 1);
         cout << " </Variable>" << endl;
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
      cout << getStringType(static_cast<Argument*>(expression)->type);
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
      cout << getStringType(static_cast<Argument*>(expression)->type);
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
      cout << getStringType(static_cast<Argument*>(expression)->type);
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
   cout << getStringType(static_cast<Argument*>(expression)->type);
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
   string getString()
   {
      string slash;
      if( *operation == "<" || *operation == ">")
        slash = "\\";
 
      if(right == NULL)
         return "! (" + left->getString() + ")";
      else
         return "(" + left->getString() + " " + slash + *operation + " " + right->getString() + ")";
   }
};

class StateNode {
public:
   string instructions;
   int state;
   int leftEdge;
   int rightEdge;

   StateNode()
   {
      leftEdge = -1;
      rightEdge = -1;
   }
   ~StateNode(){}
};

class TreeBuilder {

   int stateIndex;
   list<StateNode*> stateNodes;

public:
   list<Function*> functions;
   list<Statement*> statements;
   list<Variable*> tempParmList;
   map<string, int, ltstr> symbolTable;
   
   virtual ~TreeBuilder()
   {
      functions.clear();
      statements.clear();
      tempParmList.clear();
      symbolTable.clear();
   }
   void validateType(Argument *a1, Argument *a2)
   {
      int t1 = a1->type;
      int t2 = a2->type;

      if (t1 != t2)
         throw "invalid syntax";
   }
   int getFunctionType(string id)
   {
      list<Function*>::iterator i;

      for(i = functions.begin(); i != functions.end(); ++i)
      {
         if(id.compare(*(*i)->id) == 0)
         {
            DeclarationStatement *parms = static_cast<DeclarationStatement*>((*i)->parms);

            if(parms->variables.size() != tempParmList.size())
               return -1;

            if(parms->variables.front()->type != tempParmList.front()->type)
               return -1;

            return (*i)->type;
         }
      }

      return -1;
   }
   int getVariableType(string id)
   {

      if(symbolTable.find(id) == symbolTable.end())
         return -1;

      return symbolTable[id];
   }
   void print()
   {
      list<Function*>::iterator j;

      for(j = functions.begin(); j != functions.end(); ++j)
         (*j)->print(0);

      list<Statement*>::iterator i;

      for(i = statements.begin(); i != statements.end(); ++i)
         (*i)->print(0);
   }
   void BuildControlFlowGraph()
   {
      stateIndex = 0;
      StateNode *sn = new StateNode;
      sn->state = 0;

      stateNodes.push_back(sn);

      list<Statement*>::iterator i;

      for(i = statements.begin(); i != statements.end(); ++i)
         BuildControlFlowGraph(*i);

      list<StateNode*>::iterator j;

      cout << "digraph g {" << endl;
      cout << "graph [fontsize=30 overlap=false rankdir = \"LR\"];" << endl;

      int index = 0;
      for(j = stateNodes.begin(); j != stateNodes.end(); j++)
      {
         ostringstream label;
         if(index == 0)
            label << "start|" << (*j)->instructions;
         else if(index == stateNodes.size() -1)
            label << "end|" << (*j)->instructions;
         else
            label << "s" << (*j)->state << "|" << (*j)->instructions;

         cout << "\"state" << (*j)->state << "\" [shape = \"record\" label = \"" << label.str() << "\"];" << endl;

         index++;
      }
      for(j = stateNodes.begin(); j != stateNodes.end(); j++)
      {
         if((*j)->leftEdge != -1)
            cout << "state" << (*j)->state << " -> " << "state" << (*j)->leftEdge << ";" << endl;
         
         if((*j)->rightEdge != -1)
            cout << "state" << (*j)->state << " -> " << "state" << (*j)->rightEdge << ";" << endl;
      }
      cout << "}" << endl;
   }
   void BuildControlFlowGraph(Node *node)
   {
      StateNode *currentState = stateNodes.back();

      if(typeid(*node) == typeid(IfStatement))
      {
         IfStatement *is = static_cast<IfStatement*>(node);

         StateNode *ifState = new StateNode;
         ifState->state = ++stateIndex;
         stateNodes.push_back(ifState);

         BuildControlFlowGraph(is->statement1);

         StateNode *nextState = new StateNode;
         nextState->state = ++stateIndex;

         stateNodes.back()->leftEdge = nextState->state;
         stateNodes.push_back(nextState);

         ostringstream instr;
         instr << "if " << is->expression->getString() << " goto " << ifState->state << "\\n"
         << "else goto " << nextState->state;
         currentState->instructions += instr.str() + "\\n";
         currentState->rightEdge = ifState->state;
         currentState->leftEdge  = nextState->state;
      }
      else if(typeid(*node) == typeid(IfElseStatement))
      {
         IfElseStatement *is = static_cast<IfElseStatement*>(node);

         StateNode *ifState = new StateNode;
         ifState->state = ++stateIndex;
         stateNodes.push_back(ifState);

         BuildControlFlowGraph(is->statement1);

         StateNode *elseState = new StateNode;
         elseState->state = ++stateIndex;

         StateNode *prevState = stateNodes.back();
         stateNodes.push_back(elseState);

         BuildControlFlowGraph(is->statement2);

         StateNode *nextState = new StateNode;
         nextState->state = ++stateIndex;

         prevState->leftEdge = nextState->state;
         stateNodes.back()->leftEdge = nextState->state;
         stateNodes.push_back(nextState);

         ostringstream instr;
         instr << "if " << is->expression->getString() << " goto " << ifState->state << "\\n"
         << "else goto " << elseState->state;
         currentState->instructions += instr.str() + "\\n";
         currentState->rightEdge = ifState->state;
         currentState->leftEdge  = elseState->state;
      } 
      else if(typeid(*node) == typeid(WhileStatement))
      {
         WhileStatement *ws = static_cast<WhileStatement*>(node);

         StateNode *whileState = new StateNode;
         whileState->state = ++stateIndex;
         stateNodes.push_back(whileState);

         StateNode *whileBody = new StateNode;
         whileBody->state = ++stateIndex;
         stateNodes.push_back(whileBody);

         BuildControlFlowGraph(ws->statement1);
         stateNodes.back()->leftEdge = whileState->state;

         StateNode *nextState = new StateNode;
         nextState->state = ++stateIndex;
         stateNodes.push_back(nextState);

         currentState->leftEdge = whileState->state;

         if(whileBody->leftEdge == -1)
            whileState->leftEdge = whileState->state;

         ostringstream instr;
         instr << "if " << ws->expression->getString() << " goto " << whileBody->state << "\\n"
         << "else goto " << nextState->state;
         whileState->instructions += instr.str() + "\\n";
         whileState->rightEdge = whileBody->state;
         whileState->leftEdge  = nextState->state;
      } 
      else if(typeid(*node) == typeid(ReturnStatement))
      {
      } 
      else if(typeid(*node) == typeid(DeclarationStatement))
      {
         DeclarationStatement *ds = static_cast<DeclarationStatement*>(node);
        
         string instr = getStringType(ds->type) + " ";

         list<Argument*>::iterator i;
         for(i = ds->variables.begin(); i != ds->variables.end();)
         {
            instr += (*i)->getString();
            if(++i != ds->variables.end())
               instr += ", ";
         }
         currentState->instructions += instr + ";\\n";
      } 
      else if(typeid(*node) == typeid(AssignmentStatement))
      {
         AssignmentStatement *as = static_cast<AssignmentStatement*>(node);

         string instr = as->variable->getString() + " = " + as->expression->getString();

         currentState->instructions += instr + ";\\n";
      } 
      else if(typeid(*node) == typeid(BlockStatement))
      {
         BlockStatement *bs = static_cast<BlockStatement*>(node);

         list<Node*>::iterator i;
         for(i = bs->statements.begin(); i != bs->statements.end(); i++)
            BuildControlFlowGraph(*i);
      } 

/*      list<StateNode*>::iterator i;
      for(i = stateNodes.begin(); i != stateNodes.end(); i++)
      {
         cout << "state: " << (*i)->state << endl;
         cout << (*i)->instructions << endl;
      }
*/
   }
};

};


