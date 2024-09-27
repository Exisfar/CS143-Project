(*
 *  This file shows how to implement a list data type for lists of integers.
 *  It makes use of INHERITANCE and DYNAMIC DISPATCH.
 *
 *  The List class has 4 operations defined on List objects. If 'l' is
 *  a list, then the methods dispatched on 'l' have the following effects:
 *
 *    isNil() : Bool		Returns true if 'l' is empty, false otherwise.
 *    head()  : Int		Returns the integer at the head of 'l'.
 *				If 'l' is empty, execution aborts.
 *    tail()  : List		Returns the remainder of the 'l',
 *				i.e. without the first element.
 *    cons(i : Int) : List	Return a new list containing i as the
 *				first element, followed by the
 *				elements in 'l'.
 *
 *  There are 2 kinds of lists, the empty list and a non-empty
 *  list. We can think of the non-empty list as a specialization of
 *  the empty list.
 *  The class List defines the operations on empty list. The class
 *  Cons inherits from List and redefines things to handle non-empty
 *  lists.
 *)


class List {
  -- Define operations on empty lists.

  isNil() : Bool { true };

  -- Since  abort() has return type Object and head() has return type
  -- Int, we need to have an Int as the result of the method body,
  -- even though abort() never returns.

  head()  : Int { { abort(); 0; } };

  -- As for tail(), the self is just to make sure the return type of
  -- tail() is correct.

  tail()  : List { { abort(); self; } };

  -- When we cons and element onto the empty list we get a non-empty
  -- list. The (new Cons) expression creates a new list cell of class
  -- Cons, which is initialized by a dispatch to init().
  -- The result of init() is an element of class Cons, but it
  -- conforms to the return type List, because Cons is a subclass of
  -- List.

  -- 在面向对象编程中，使用子类对象来替换父类对象是一种常见的做法，
  -- 这被称为多态性（polymorphism）。多态性允许子类的对象在程序中被当作父类的对象来使用。
  cons(i : Int) : List {
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

(*
 * Cons类在这个代码中代表了一个非空列表的数据结构。
 * 在面向对象编程中，特别是在实现链表时，"Cons"是一个常用的术语，
 * 来源于Lisp编程语言中的构造函数cons，用于构建链表。
 * Cons类用于创建一个包含至少一个元素的列表节点，
 * 这个节点可以链接到其他Cons节点或一个空列表，从而形成一个链表结构。
 *)

class Cons inherits List {

  car : Int;	-- The element in this list cell

  cdr : List;	-- The rest of the list

  isNil() : Bool { false };

  head()  : Int { car };

  tail()  : List { cdr };

  init(i : Int, rest : List) : List {
    {
      car <- i;
      cdr <- rest;
      self;
    }
  };

};



(*
 *  The Main class shows how to use the List class. It creates a small
 *  list and then repeatedly prints out its elements and takes off the
 *  first element of the list.
 *)

class Main inherits IO {

  mylist : List;

  -- Print all elements of the list. Calls itself recursively with
  -- the tail of the list, until the end of the list is reached.

  print_list(l : List) : Object {
    if l.isNil() then out_string("\n")
                  else {
        out_int(l.head());
        out_string(" ");
        print_list(l.tail());
          }
    fi
  };

  -- Note how the dynamic dispatch mechanism is responsible to end
  -- the while loop. As long as mylist is bound to an object of 
  -- dynamic type Cons, the dispatch to isNil calls the isNil method of
  -- the Cons class, which returns false. However when we reach the
  -- end of the list, mylist gets bound to the object that was
  -- created by the (new List) expression. This object is of dynamic type
  -- List, and thus the method isNil in the List class is called and
  -- returns true.

  main() : Object {
    {
      mylist <- new List.cons(1).cons(2).cons(3).cons(4).cons(5);
      while (not mylist.isNil()) loop
      {
          print_list(mylist);
          mylist <- mylist.tail();
      }
      pool;
    }
  };

};



