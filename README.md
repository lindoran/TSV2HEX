# TSV2HEX
Tiny Free Pascal Program for dumping a TSV ASCII Truth Table to Intel .HEX file

(C) 2021 David Collins 
Released under the MIT Licence 

This is Beta 1.0 of my simple program for converting a TSV (Tab Separated Values) ASCII file
to a Intel .HEX file. This is usefull if you need to make a simple combined logic replacement
with an eeprom.

You can easily build a truth table by building a design in logisim and then copy and pasting
the truth table from logisim to a text file.

so far it works if you leave the lables on the top. 
here is an example file: 
<PRE>
a	b	c	d	w	x	y	z
0	0	0	0	0	0	0	0
0	0	0	1	0	0	0	1
0	0	1	0	0	0	1	0
0	0	1	1	0	0	1	1
0	1	0	0	0	1	0	0
0	1	0	1	0	1	0	1
0	1	1	0	0	1	1	0
0	1	1	1	0	1	1	1
1	0	0	0	1	0	0	0
1	0	0	1	1	0	0	1
1	0	1	0	1	0	1	0
1	0	1	1	1	0	1	1
1	1	0	0	1	1	0	0
1	1	0	1	1	1	0	1
1	1	1	0	1	1	1	0
1	1	1	1	1	1	1	1
</PRE>
make shure there are no trailing spaces at the end of the file, these can cause issues.
you can run the program from a shell (win32 binary is included, working on building on 
linux but this was built in lazerus so it 'should' just build if you want to try it your
self on linux or OSX.)

you can run by typing: 
<pre>
TSV2HEX [arguments]
</pre>

The arguments and paramiters need to be seprated by spaces, it will produce an error 
if you try to enter more than 8 arguments. the current supported commands are: 
<PRE>
  INP [Argument] : Example INP 4 sets the number of inputs to 4
  OTP [Argument] : Example OUP 4 sets the number of outputs to 4
  OFN [Argument] : Example OFN <filename> sets output filename
  IFN [Argument] : Example IFN <filename> sets input filename
  
  try : TSV2HEX INP 4 OTP 4 OFN out.hex INF test.txt
  
  with the test.txt file it should produce a OUT.HEX with the following first line:
  :10000000000102030405060708090A0B0C0D0E0F78
  :1000100000000000000000000000000000000000E0
  ... {more or less the same until}
  :107FD00000000000000000000000000000000000A1
  :107FE0000000000000000000000000000000000091
  :107FF0000000000000000000000000000000000081
  :00000001FF
</PRE>

  if you are missing an argument or two or enter none, it will drop you to a ":" prompt. 
  from here you can type HELP or QUIT to continue.
