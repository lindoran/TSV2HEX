program TSV2HEX (input, output, stdErr);
{$IF defined(FPC)}{$MODE OBJFPC}{$H+}{$IFEND}
{
 MIT License

Copyright (c) 2021 Dave Collins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}
uses classes,sysutils;
const
  CLINELENGTH   = 16;            // # of b in a line in .HEX (0-15 = 16)
  CLASTLINE     = 2047;          // # of lines in .HEX counting line 1 as 0
  CROMBYTES     = 32767;         // total number of bytes in ROM
  CVERSION      = '1.0 Beta';    // version #
  CXOFFSET      = ':00000001FF'; //XGPro adds this, I am too it's prob. not req.
var
  inputfilename,outfilename :string;
  inputs,outputs            :integer;

  databytes                 :array[0..CROMBYTES] of uint8;
  CommandsList              :Array [1..8] of string;
  breakfromloop :boolean;


//totally stole this from :
//https://programming-idioms.org/idiom/137/check-if-string-contains-only-digits/1746/pascal
//'Character' class only supports unicode to lazy to rewrite to support it.
Function IsNumber(S : string) : boolean;
var
  C : char;
  B : boolean;
begin
  for C in S do
      begin
       B := C in ['0' .. '9'];
       if not B then
        begin
         IsNumber := False;
         exit;
        end;
      end;
  IsNumber := True;
end;


Procedure TestCommand (InputCommand,Argument : String);
begin
     case InputCommand OF
       'INP' :
          begin
           if IsNumber(Argument) then
            begin
             inputs := STRTOINT(Argument);
             exit;
            end;
          end;
       'OTP' :
          begin
           if IsNumber(Argument) then
            begin
             outputs := STRTOINT(Argument);
             exit;
            end;
          end;
       'OFN' :
          begin
            outfilename := Argument;
            exit;
          end;
       'IFN' :
          begin
           inputfilename := Argument;
           exit;
          end;
       'QUIT': halt(1);
       'VARS': begin
                  writeln('Inputs  : ',inputs);
                  writeln('Outputs : ',outputs);
                  writeln('Out File: ',outfilename);
                  writeln('In File : ',inputfilename);
                  exit;
               end;
       'HELP': begin
                  writeln('Dirt Simple TSV Truth Table To .HEX assembler');
                  writeln('By D. Collins (Z80Dad) (C) 2021');
                  writeln('Under the MIT Licence');
                  writeln('V.',CVERSION);
                  writeln;
                  writeln('This will take a pre-formatted tab seperated value truth table');
                  writeln('in ascii text file format and output a .hex file sutible for');
                  writeln('burning an eeprom. Curently only a 32k eeprom is supported.');
                  writeln;
                  writeln('Hint: You are here because you forgot to specify a value at');
                  writeln('exicution. Writing will start when all needed values are met.');
                  writeln;
                  writeln('THERE WILL BE BUGS USE AT YOUR OWN RISK');
                  writeln;
                  writeln('Rule 1: RFTM!');
                  writeln;
                  writeln('Accepted arguments:');
                  writeln('INP <Argument> : Example INP 4 sets the number of inputs to 4');
                  writeln('OTP <Argument> : Example OUP 4 sets the number of outputs to 4');
                  writeln('OFN <Argument> : Example OFN <filename> sets output filename');
                  writeln('IFN <Argument> : Example IFN <filename> sets input filename');
                  writeln('VARS           : Displays currently set Variables');
                  writeln('QUIT           : Exits before doing anything further (abort)');
                  exit;
               end;
           end;

         Writeln('Invallid or unknown keyword "',InputCommand,'" or argument "',
                  Argument, '" Try again. TRY: HELP OR QUIT');


end;

Procedure TestValues;
var
  minimumIOmet,minimumIFNmet,
  minimumOFNmet              : boolean;

begin
     minimumIOmet := false;
     minimumIFNmet := false;
     minimumOFNmet := false;
     if (inputs OR outputs) <> 0 then minimumIOmet := true;
     if inputfilename <> '' then minimumIFNmet := true;
     if outfilename <> '' then minimumOFNmet := true;
     if ((minimumIOmet AND minimumIFNmet) AND minimumOFNmet) = TRUE then breakfromloop :=true;
end;

Procedure RunCommands(args: integer);
var
  operation : integer;

begin
   operation := 1;
   if args = 1 then
   begin
    TestCommand(UpCase(CommandsList[1]),' ');
    exit
   end;
   if odd(args) or (args < 0) then
    begin
     writeln ('command mismatch: ',args, ' or more arguments!');
     exit;
    end;
   while args <> 0 do
    begin
     args := args -2;
     TestCommand(UpCase(CommandsList[operation]),UpCase(CommandsList[operation+1]));
     operation := operation + 2;
    end;
end;

Procedure ParceCommand (unparcedinput :string);
var
  WorkString      : TStrings;
  ThisPart,NullSt : string;
  count           : integer;

begin
  for count := 1 to 8 do CommandsList[count] := '';
  count := 0;
  WorkString:=TStringlist.Create;
  try
    WorkString.Delimiter := #32;
    WorkString.StrictDelimiter := true;
    WorkString.DelimitedText := unparcedinput;
    for ThisPart in WorkString do
        if count <= 8 then
         begin
          count := count +1;
          CommandsList[count] := ThisPart;
         end
         else
           NullSt := ThisPart;
  finally
    WorkString.Free;
  end;
  if NullSt <> '' then writeln('Too Many Arguments found,');
  RunCommands(count);
end;


Procedure GetValues;
var

 commandinput : string;
begin
  testvalues;
  if breakfromloop = false then writeln('Type HELP for commands.');
  while breakfromloop <> true do
   begin
    write(':');
    readln(commandinput);
    ParceCommand(commandinput);
    testvalues;
   end;
end;
Procedure CheckInputValues;
var
 count: integer;
begin
  if paramCount() > 8 then
   begin
    writeln('Too Many Arguments found!');
    Halt(1);
   end;
  for count := 1 to 8 do CommandsList[count] := '';
  for count := 1 to paramCount() do CommandsList[count] := paramStr(count);
  RunCommands(count);
end;

Procedure BlankTable;
var count : integer;

begin
     for count := 0 to CROMBYTES do databytes[count] := 0;
     breakfromloop := false;
end;
        // this is a recursive mess but it works.
procedure LoadTable;

var
 tsvTfile : TextFile;
 inpLine:TStrings;
 thisPart,WorkLine,readLine:string;
begin
  AssignFile(tsvTfile,inputfilename);  // open work file check for errors.
  try
   reset(tsvTfile);
   readln(tsvTfile,readLine); // read in the first line to skip it.
   while not eof(tsvTfile) do
    begin
     readln(tsvTfile,readLine);
     inpLine:=TStringlist.Create;
     try  // trys to pull just the data in the line from the tabs.
      inpLine.Delimiter := #9;     // #9 = TAB/ASCII
      inpLine.StrictDelimiter := true;
      inpLine.DelimitedText := readLine;
      WorkLine := '';        // zero out the formatted output string
      for ThisPart in inpLine do  // build the output string 1 bit at a time
            WorkLine := WorkLine + ThisPart;
     finally
       // copy data to address location in databytes, by parceing the line useing copy,
       // looking at the numbers as binary, by appending % to the begining of the sub
       // string and useing the strtoint. this is then casted to a 'unit8' data type by
       // the compiler; this is lazy and not very iso portable but should work on lazurus.
      databytes[strtoint('%'+copy(WorkLine,1,inputs))] := strtoint('%'+copy(WorkLine,inputs+1,outputs));
      inpLine.Free;
     end;
    end;    // while;
    CloseFile(tsvTfile);
    except       // on a file error exit.
     on E: EInOutError do begin
       writeln('File handling error: ',E.Message);
       halt(1);      // end exicute on error
     end;
    end;
end;
Function CurrentLine(LineNumber : integer) : string;

var
 LineValue,count : integer;
 workstring,checksum,addressstring : string;
begin
     // stage variables premble
     addressstring := inttohex((LineNumber * CLINELENGTH),4);
     workstring := inttohex(CLINELENGTH,2) + addressstring + '00';
     linevalue := 0;
     // build string
     for count := 0 to 15 do
         workstring := workstring+inttohex(databytes[count+(CLINELENGTH*LineNumber)],2);
     // calculate checksum
     linevalue := CLINELENGTH + strtoint('$'+copy(addressstring,1,2)) + strtoint('$'+copy(addressstring,3,2));
     for count := 0 to 15 do linevalue := linevalue + databytes[count+(CLINELENGTH*LineNumber)];
     checksum := copy(inttohex((not linevalue)+1,2),15,2); // this might be a bug waiting to happen
     CurrentLine := ':'+workstring+checksum;
end;
procedure SaveTable;
var
  OutFile: TextFile;
  count : integer;

begin
     AssignFile(OutFile, outfilename);
     try   // 2047 * 16 = 23752b with 16b per line (32767b total).
        rewrite(OutFile);
        For count := 0 to CLASTLINE do Writeln(OutFile, CurrentLine(count));
        Write(OutFile, CXOFFSET); // prob. not req. (there's no ext.offset)
        CloseFile(OutFile);
     except               // on file error exit
        on E: EInOutError do
        begin
         writeln('File Handleing Error: ', E.ClassName, '/', E.Message);
         halt(1);   // end exicute on error
        end;
     end;
end;

begin
  writeln('Dirt Simple TSV Truth Table To .HEX assembler');
  writeln('By D. Collins (Z80Dad) (C) 2021');
  writeln('Under the MIT Licence');
  writeln('V.',CVERSION);
  writeln;
  writeln('THERE WILL BE BUGS USE AT YOUR OWN RISK');
  writeln;
  BlankTable;
  CheckInputValues;
  GetValues;
  LoadTable;
  SaveTable;
end.
