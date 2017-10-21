with gwarshall;
with Ada.Text_IO; use Ada.Text_IO;

procedure usegwarshall is
	package IIO is new Integer_IO(integer);
	use IIO;
		
	subtype string3 is String(1..3);
	
	function "or"(x: integer; y: integer) return integer is
	begin
		if (x + y > 0) then
			return 1;
		else
			return 0;
		end if;
	end;
	
	procedure StrPut(x: string3) is
		Output: File_Type;
	begin
		Open(Output, Append_File, "Temp_Output.txt");
		Ada.Text_IO.Put(Output, x);
		Close(Output);
	end;
	
	procedure IntPut(x: integer) is
		Output: File_Type;
	begin
		Open(Output, Append_File, "Temp_Output.txt");
		IIO.Put(Output, x, 0);
		Close(Output);
	end;
	
	package A_Data1 is new gwarshall(string3, "A_Input1.txt", "A_Output1.txt", "or", StrPut, IntPut);
	use A_Data1;
	package A_Data2 is new gwarshall(string3, "A_Input2.txt", "A_Output2.txt", "or", StrPut, IntPut);
	use A_Data2;
	package B_Data is new gwarshall(string3, "B_Input.txt", "B_Output.txt", "or", StrPut, IntPut);
	use B_Data;
	package C_Data is new gwarshall(string3, "C_Input.txt", "C_Output.txt", "or", StrPut, IntPut);
	use C_Data;
begin
	null;
end usegwarshall;