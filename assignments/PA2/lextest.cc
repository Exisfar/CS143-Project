//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

//////////////////////////////////////////////////////////////////////////////
//
//  lextest.cc
//
//  Reads input from file argument.
//  Used to test and debug.
//  Option -l prints summary of flex actions.
//
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>  // needed on Linux system
#include <unistd.h>  // Provides access to the POSIX operating system API, including getopt

#include "cool-parse.h"  // bison-generated file; defines tokens
#include "utilities.h"

//
//  The lexer keeps this global variable up to date with the line number
//  of the current line read from the input.
//

/*
  This section of the code sets up the necessary external variables and
  functions for the lexer to operate. It includes the file pointer for input,
  the Flex-generated lexer function, and variables for handling command-line
  options and debugging. The handle_flags function processes these options to
  control the behavior of the lexer.
*/
int curr_lineno = 1;
char *curr_filename = "<stdin>";  // this name is arbitrary
FILE *fin;  // This is the file pointer from which the lexer reads its input.

//
//  cool_yylex() is the function produced by flex. It returns the next
//  token each time it is called.
//
extern int cool_yylex();
/*
  Purpose: This variable holds the value of the current token. It is used to
  pass information from the lexer to the parser.
  Usage: It is typically defined in the Bison parser file, but since lextest.cc
  is not compiled with the parser, it must be defined here.
*/
YYSTYPE cool_yylval;  // Not compiled with parser, so must define this.

extern int optind;  // used for option processing (man 3 getopt for more info)

//
//  Option -v sets the lex_verbose flag. The main() function prints out tokens
//  if the program is invoked with option -v.  Option -l sets yy_flex_debug.
//
extern int yy_flex_debug;  // Flex debugging; see flex documentation.
extern int lex_verbose;    // Controls printing of tokens.
void handle_flags(int argc, char *argv[]);

//
//  The full Cool compiler contains several debugging flags, all of which
//  are handled and set by the routine handle_flags.  Here we declare
//  cool_yydebug, which is not used by the lexer but is needed to link
//  with handle_flags.
//
int cool_yydebug;

// defined in utilities.cc
extern void dump_cool_token(ostream &out, int lineno, int token,
                            YYSTYPE yylval);

int main(int argc, char **argv) {
  int token;
  // This function processes the command-line options and sets the appropriate
  // flags.
  handle_flags(argc, argv);
  // This loop iterates over the remaining arguments, which are expected to be
  // input file names.
  while (optind < argc) {
    fin = fopen(argv[optind], "r");
    if (fin == NULL) {
      cerr << "Could not open input file " << argv[optind] << endl;
      exit(1);
    }

    // sm: the 'coolc' compiler's file-handling loop resets
    // this counter, so let's make the stand-alone lexer
    // do the same thing
    curr_lineno = 1;

    //
    // Scan and print all tokens.
    //
    cout << "#name \"" << argv[optind] << "\"" << endl;
    while ((token = cool_yylex()) != 0) {
      dump_cool_token(cout, curr_lineno, token, cool_yylval);
    }
    fclose(fin);
    optind++;
  }
  exit(0);
}
