/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 *  to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <vector>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

static int comment_num = 0;
%}

/*
 *  Add Your own definitions here
 */

%x INLINE_COMMENT
%x COMMENT
%x STRING

/*
 * Define names for regular expressions here.
 * Except for the constants true and false, keywords are case insensitive.
 */

DARROW          =>
CLASS           [Cc][Ll][Aa][Ss][Ss]
INHERITS        [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
IF              [Ii][Ff]
FI              [Ff][Ii]
THEN            [Tt][Hh][Ee][Nn]
ELSE            [Ee][Ll][Ss][Ee]
LET             [Ll][Ee][Tt]
IN              [Ii][Nn]
WHILE           [Ww][Hh][Ii][Ll][Ee]
LOOP            [Ll][Oo][Oo][Pp]
POOL            [Pp][Oo][Oo][Ll]
CASE            [Cc][Aa][Ss][Ee]
ESAC            [Ee][Ss][Aa][Cc]
OF              [Oo][Ff]
NEW             [Nn][Ee][Ww]
ISVOID          [Ii][Ss][Vv][Oo][Ii][Dd]
ASSIGN          <-
NOT             [Nn][Oo][Tt]
LE              <=
TRUE            t[Rr][Uu][Ee]
FALSE           f[Aa][Ll][Ss][Ee]

%%
 /*
  *  Nested comments
  */
<INITIAL>--             BEGIN(INLINE_COMMENT);
<INLINE_COMMENT><<EOF>> BEGIN(INITIAL);
<INLINE_COMMENT>.               
<INLINE_COMMENT>\n      {
  curr_lineno++; 
  BEGIN(INITIAL);
} 
<INITIAL,COMMENT>"(*" {
  comment_num++;
  BEGIN(COMMENT);
}
<COMMENT><<EOF>> {
  cool_yylval.error_msg = "EOF in comment";
  BEGIN(INITIAL);
  return ERROR;
}
<COMMENT>\n          ++curr_lineno;
<COMMENT>[^*()\n]*   /* single (, ), and * can't match it */
<COMMENT>[()*]
<COMMENT>"*)" {
  comment_num--;
  if (comment_num == 0) {
    BEGIN(INITIAL);
  }
}
<INITIAL>"*)" {
  cool_yylval.error_msg = "Unmatched *)";
  BEGIN(INITIAL);
  return ERROR;
}


 /*
  * The single legal character and single illegal character
  */
[ \t\f\r\v]   {}
\' {
  cool_yylval.error_msg = "'";
  return (ERROR);
}
\[ {
  cool_yylval.error_msg = "[";
  return (ERROR);
}
\] {
  cool_yylval.error_msg = "]";
  return (ERROR);
}
> {
  cool_yylval.error_msg = ">";
  return (ERROR);
}

"."    return int('.');
"{"    return int('{');
"}"    return int('}');
"("    return int('(');
")"    return int(')');
","    return int(',');
":"    return int(':');
";"    return int(';');
"@"    return int('@');
"~"    return int('~');

 /*
  * Arithmetic and Comparison Operations
  * Cool has four binary arithmetic operations: +, -, *, /
  * Cool has three comparison operations: <, <=, =
  */
"+"    return int('+');
"-"    return int('-');
"*"    return int('*');
"/"    return int('/');
"<"    return int('<');
"="    return int('=');
{LE}   return (LE);

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{DARROW}		{ return (DARROW); }
{CLASS}     { return (CLASS); }
{INHERITS}  { return (INHERITS); }
{IF}        { return (IF); }
{FI}        { return (FI); }
{THEN}      { return (THEN); }
{ELSE}      { return (ELSE); }
{LET}       { return (LET); }
{IN}        { return (IN); }
{WHILE}     { return (WHILE); }
{LOOP}      { return (LOOP); }
{POOL}      { return (POOL); }
{CASE}      { return (CASE); }
{ESAC}      { return (ESAC); }
{OF}        { return (OF); }
{NEW}       { return (NEW); }
{ISVOID}    { return (ISVOID); }
{ASSIGN}    { return (ASSIGN); }
{NOT}       { return (NOT); }

\n            { ++curr_lineno; }

{TRUE} {
  cool_yylval.boolean = true;
  return (BOOL_CONST);
}
{FALSE} {
  cool_yylval.boolean = false;
  return (BOOL_CONST);
}

 /*
  *  Type indentifiers
  *  Begin with a capital letter 
  */
SELF_TYPE {
  cool_yylval.symbol = idtable.add_string("SELF_TYPE");
  return (TYPEID);
}
[A-Z][A-Za-z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (TYPEID);
}

 /*
  *  Object indentifiers
  *  Begin with a lower case letter 
  */
self {
  cool_yylval.symbol = idtable.add_string("self");
  return (OBJECTID);
}
[a-z][A-Za-z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (OBJECTID);
}

 /*
  *  Integer constants
  *
  */
[0-9][0-9]* {
  cool_yylval.symbol = inttable.add_string(yytext, yyleng);
  return (INT_CONST);
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\" BEGIN(STRING);
<STRING><<EOF>> {
  cool_yylval.error_msg = "EOF in string constant";
  BEGIN(INITIAL);
  yyrestart(yyin);
  return ERROR;
}
<STRING>[^\\\n"]* {
  yymore();
}
<STRING>\\[^\n] {
  /* Note that yytext can be defined in two different ways: 
   * either as a character pointer or as a character array. The default is %pointer.
   * he advantage of using %pointer is substantially faster scanning and 
   * no buffer overflow when matching very large tokens (unless you run out of dynamic
   * memory). The disadvantage is that you are restricted in how your actions can modify
   * yytext (see Chapter 8 [Actions], page 15), and calls to the unput() function destroys 
   * the present contents of yytext, which can be a considerable porting headache 
   * when moving between different lex versions.
   */
  yymore();
}
<STRING>\\\n {
  curr_lineno++;
  yymore();
}
<STRING>\n {
  cool_yylval.error_msg = "Unterminated string constant";
  curr_lineno++;
  BEGIN(INITIAL);
  return ERROR;
}
<STRING>\" {
  char *p = yytext;
  char processed_str[yyleng];
  int i = 0; /* index of processed_str */

  /* 1. if \0 exists */
  for (p = yytext; p < yytext + yyleng; p++) {
    if (*p == '\0') {
      cool_yylval.error_msg = "String contains null character";
      BEGIN(INITIAL);
      return ERROR;
    }
  }
  /* 2. escaped characters */
  p = yytext;
  /* ignore right quote */
  while (p < yytext + yyleng - 1) {
    if (*p == '\\') {
      switch (*(p + 1)) {
        case 'b': processed_str[i++] = '\b'; break;
        case 't': processed_str[i++] = '\t'; break;
        case 'n': processed_str[i++] = '\n'; break;
        case 'f': processed_str[i++] = '\f'; break;
        default: processed_str[i++] = *(p + 1); break;
      }
      p += 2;
    }
    else {
      processed_str[i++] = *p++;
    }
  }
  
  /* 3. length check */
  if (i >= MAX_STR_CONST) {
    cool_yylval.error_msg = "String constant too long";
    BEGIN(INITIAL);
    return ERROR;
  }

  /* 4. save the result to string table */
  cool_yylval.symbol = stringtable.add_string(processed_str, i);
  BEGIN(INITIAL);
  return STR_CONST;
}

. {
  cool_yylval.error_msg = yytext;
  return (ERROR);
}

%%
