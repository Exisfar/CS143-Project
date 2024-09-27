# test_script.py
import os

my_output = os.popen("make dotest").read()
std_output = os.popen("lexer test.cl").read()

begin_index = my_output.index("#name")
my_output = my_output[begin_index:]

while my_output and std_output:
    my_end = my_output.index("\n")
    std_end = std_output.index("\n")
    if my_output[0:my_end] != std_output[0:std_end]:
        print("my lexer: ", my_output[0:my_end])
        print("std lexer: ", std_output[0:std_end])
        print("")
    my_output = my_output[my_end + 1 :]
    std_output = std_output[std_end + 1 :]
