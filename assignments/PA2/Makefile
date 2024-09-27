# Variables

# 1. Project and Directory Variables

# Project-specific variables
# Assignment number
ASSN = 2
# Class name
CLASS= cs143
# Directory for class files
CLASSDIR= ../..
# Libraries to link against: the Flex library (-lfl)
LIB= -lfl

# 2. Source and Object Files

# Lists of source files
# Sourec files
SRC= cool.flex test.cl README
# C++ source files
CSRC= lextest.cc utilities.cc stringtab.cc handle_flags.cc
# Test scripts
TSRC= mycoolc
# Header files (currently empty)
HSRC= 
# Generated C++ files
CGEN= cool-lex.cc
# Generated header files (currently empty)
HGEN= 
# List of libraries
LIBS= parser semant cgen
# Combined list of C++ source files and generated files
CFIL= ${CSRC} ${CGEN}
# List of Makefile source files
LSRC= Makefile
# List of object files derived from CFIL
OBJS= ${CFIL:.cc=.o}
# Output file name
OUTPUT= test.output

# 3. Compiler and Flags

# Include paths for the compiler
CPPINCLUDE= -I. -I${CLASSDIR}/include/PA${ASSN} -I${CLASSDIR}/src/PA${ASSN}
# Flags for Flex
FFLAGS= -d -ocool-lex.cc
# Compiler to use (g++)
CC=g++
# Compiler flags, including C++11 standard and include paths
CFLAGS= -g -Wall -Wno-unused -Wno-write-strings -std=c++11 ${CPPINCLUDE}
# Flex command with flags
FLEX=flex ${FFLAGS}
# Command to generate dependency files
DEPEND = ${CC} -MM ${CPPINCLUDE}

# Rules

# 1. Default Rule
# source is the default target, depending on source files, test scripts, Makefile, libraries, and lsource
source : ${SRC} ${TSRC} ${LSRC} ${LIBS} lsource

# 2. Source Rule
# lsource depends on the Makefile itself
lsource: ${LSRC}

# 3. Output Rule
# test.output depends on lexer and test.cl. It runs lexer on test.cl and redirects the output to test.output
${OUTPUT}: lexer test.cl
	@rm -f test.output
	-./lexer test.cl > test.output 2>&1

# 4. Lexer Rule
# This rule specifies that lexer depends on the object files (${OBJS}). It links them to create the lexer executable.
lexer: ${OBJS}
	${CC} ${CFLAGS} ${OBJS} ${LIB} -o lexer

# 5. Object File Rule
# This is a generic rule to compile .cc files into .o files.
.cc.o:
	${CC} ${CFLAGS} -c $<

# 6. Flex Rule
# This rule specifies that cool-lex.cc depends on cool.flex. It runs Flex to generate cool-lex.cc.
cool-lex.cc: cool.flex 
	${FLEX} cool.flex

# 7. Test Rule
# dotest depends on lexer and test.cl. It runs lexer on test.cl
# .PHONY: dotest
dotest:	lexer test.cl
	./lexer test.cl

# 8. Library Rule
# Rule to generate libraries using an external script
${LIBS}:
	${CLASSDIR}/etc/link-object ${ASSN} $@

# 9. Symlink Rules
# Rules to create symbolic links for source and header files.
${TSRC} ${CSRC}:
	-ln -s ${CLASSDIR}/src/PA${ASSN}/$@ $@
${HSRC}:
	-ln -s ${CLASSDIR}/include/PA${ASSN}/$@ $@

# 10. Clean Rules
# clean: Removes generated files and intermediate files
clean:
	-rm -f ${OUTPUT} *.s core ${OBJS} lexer cool-lex.cc *~ parser cgen semant
# clean-compile: Removes only intermediate files
clean-compile:
	@-rm -f core ${OBJS} cool-lex.cc ${LSRC}

# 11. Dependency Generation
# Generates dependency files for each .cc file and includes them in the Makefile.
%.d: %.cc ${SRC} ${LSRC}
	${SHELL} -ec '${DEPEND} $< | sed '\''s/\($*\.o\)[ :]*/\1 $@ : /g'\'' > $@'
-include ${CFIL:.cc=.d}

# Summary
# This Makefile automates the build process by defining dependencies 
# and rules for compiling and linking a C++ project with Flex. 
# It includes rules for generating lexer code, compiling source files, 
# linking object files, running tests, and cleaning up generated files. 
# The use of variables and generic rules makes it flexible and easy to maintain.
