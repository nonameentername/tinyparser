#include "treebuilder.h"

namespace AST {

string getStringType(int type)
{
   if(type == INT_T)
      return "int";
   else
      return "float";
}

}
