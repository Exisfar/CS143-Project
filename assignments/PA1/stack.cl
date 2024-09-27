(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *  Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)
class Stack {
  -- Define operations on empty stack.
  isEmpty() : Bool { true };

  -- Since abort() has return type Object and top() has return type
  -- String, we need to have a String as the result of the method body,
  -- even though abort() never returns.
  top(): String { { abort(); ""; } };

  -- As for getNext(), the self is just to make sure the return type of
  -- getNext() is correct.
  getNext(): Stack { { abort(); self; } };

  push(i: String): Stack {
    (new Cons).init(i, self)
  };
};

(*
 *  Cons inherits all operations from List. We can reuse only the cons
 *  method though, because adding an element to the front of an emtpy
 *  list is the same as adding it to the front of a non empty
 *  list. All other methods have to be redefined, since the behaviour
 *  for them is different from the empty list.
 *
 *  Cons needs two attributes to hold the integer of this list
 *  cell and to hold the rest of the list.
 *
 *  The init() method is used by the cons() method to initialize the
 *  cell.
 *)

class Cons inherits Stack {
  item : String;	-- The element in this stack cell
  next : Stack;	-- The rest of the stack

  isEmpty(): Bool { false };
  top(): String { item };
  getNext(): Stack { next };
  init(i: String, n: Stack): Cons {
    {
      item <- i;
      next <- n;
      self;
    }
  };
};

class StackCommand{
  io: IO <- new IO;
  a2i: A2I <- new A2I;
  a: String;
  b: String;

  push_a_plus(stack: Stack): Stack {
    stack.push("+")
  };

  push_an_s(stack: Stack): Stack {
    stack.push("s")
  };

  push_int(stack: Stack, i: String): Stack {
    stack.push(i)
  };

  evaluate(stack: Stack): Stack {
    if stack.isEmpty() then
      stack
    else if stack.top() = "+" then {
      stack <- stack.getNext(); -- pop "+"
      a <- stack.top();
      stack <- stack.getNext();
      b <- stack.top();
      stack <- stack.getNext();
      stack <- stack.push(a2i.i2a(a2i.a2i(a) + a2i.a2i(b))); -- push a + b
    } else if stack.top() = "s" then {
      stack <- stack.getNext(); -- pop "s"
      a <- stack.top();
      stack <- stack.getNext(); -- pop the first item
      b <- stack.top();
      stack <- stack.getNext(); -- pop the second item
      stack <- stack.push(a);   -- push the first item
      stack <- stack.push(b);   -- push the second item
    } else 
      stack
    fi fi fi
  };

  display(stack: Stack): Object {
    if stack.isEmpty() then
      io.out_string("The stack is empty.\n")
    else {
      io.out_string(stack.top());
      io.out_string("\n");
      display(stack.getNext());
    }
    fi
  };
};

class Main inherits IO {
  command: String;
  stack: Stack <- new Stack;
  stack_command: StackCommand <- new StackCommand;

  main(): Object { {
      out_string("<");
      command <- in_string();
      while (not(command = "x")) loop {
        if command = "+" then
          stack <- stack_command.push_a_plus(stack)
        else if command = "s" then
          stack <- stack_command.push_an_s(stack)
        else if command = "e" then
          stack <- stack_command.evaluate(stack)
        else if command = "d" then
          stack_command.display(stack)
        else
          stack <- stack_command.push_int(stack, command)
        fi fi fi fi;
        out_string("<");
        command <- in_string();
      }
      pool;
    }
  };
};
