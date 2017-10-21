with Ada.Text_IO; use Ada.Text_IO;
with Unchecked_Conversion;

package body gwarshall is

	package IIO is new Integer_IO(integer); use IIO;	
	function Convert is new Unchecked_Conversion(String, MyItem);
	
	function Get_Size return integer is		--reads and returns first line of txt file
		Input: File_Type;
		First_Line: integer;
	begin
		Open(Input, In_File, Input_File);
		
		for i in 1..1 loop
			declare
				Line: String := Get_Line(Input);
			begin
				First_Line := Integer'Value(Line);
			end;
		end loop;
		Close(Input);
		return First_Line;
	end Get_Size;

	Array_Size: integer := Get_Size;												
	M: array(1..Array_Size, 1..Array_Size) of integer := (others => (others => 0));
	Index_Array: array(1..Array_Size) of MyItem;
	back: integer := 1;
	
	procedure Get_First is				--collects pairs of nodes and sends to First(...)
		Input: File_Type;
	begin
		Open(Input, In_File, Input_File);
		
		for i in 1..1 loop							--skip the first line of txt file
			declare
				Skip: String := Get_Line(Input);
			begin
				null;
			end;
		end loop;
		
		while not End_Of_File(Input) loop			--collects all pairs and send to First
			declare
				Line1: String := Get_Line(Input);	--retrieve in pairs
				Line2: String := Get_Line(Input);
			begin
				Fill_Index_Array(Convert(Line1));		--will add to array while placing..
				Fill_Index_Array(Convert(Line2));		--.. a 1 in BMR simultaneously
				First(Convert(Line1), Convert(Line2));
			end;
		end loop;
		Close(Input);
	end Get_First;
	
	procedure Fill_Index_Array(x: MyItem) is	--fills array with unique MyItem values..
		match: boolean := false;				--.. to be used as BMR labels
	begin
		for i in 1..Array_Size loop				--sees if incoming item is already added
			if x = Index_Array(i) then
				match := true;
			end if;
		end loop;
		if match = false then			--if not already in array, put there (utilizes..
			Index_Array(back) := x;		--.. an array pointer "back")
			if back /= Array_Size then
				back := back + 1;
			end if;
		end if;
	end Fill_Index_Array;
	
	procedure First(R_Item,C_Item: MyItem) is	--places 1's in initial BMR
		R,C: integer;
	begin
		for i in 1..back loop					--loop retrieves numeric values for R..
			if Index_Array(i) = R_Item then		--.. and C to know where to place the 1
				R := i;
			end if;
			if Index_Array(i) = C_Item then
				C := i;
			end if;
		end loop;
		if (R_Item = C_Item) then			--if the two items paired are the same,..
			M(R,C) := 0;					--.. like Sam <-> Sam, place a 0
		else
			M(R,C) := 1;					--else place a 1 to represent connection
		end if;
	end First;
	
	procedure Warshall is					--place additional 1's where needed
	begin
		for i in 1..Array_Size loop
			for j in 1..Array_size loop
				if (M(j,i) = 1) then
					for k in 1..Array_Size loop
						M(j,k) := M(j,k) or M(i,k);
					end loop;
				end if;
			end loop;
		end loop;
	end Warshall;
	
	procedure Print_Temp is			--sequentially prints results to temporary file..
		Input: File_Type;			--.. (intermediate step due to File IO limitations)
	begin
		Create(Input, In_File, "Temp_Output.txt");
		Close(Input);
		for i in 1..Array_Size loop		--generates top column labels
			PutItem(Index_Array(i));
		end loop;
		for i in 1..Array_Size loop		--generates complete rows
			PutItem(Index_Array(i));
			for j in 1..Array_Size loop
				PutInt(M(i,j));
			end loop;
		end loop;
	end Print_Temp;
	
	procedure Print_Final is			--runs through algorithm to format Temp_Output
		Input, Output: File_Type;
		Knt: integer := 1;
		Top_Finished: boolean := false;
	begin
		Open(Input, In_File, "Temp_Output.txt"); --the Temp_Output created is now input
		Create(Output, Out_File, Output_File);	 --final file using name in instantiation
		
		Put(Output, "Results of " & Input_File & ":");	--print appropriate header
		Put_Line(Output, "");
		Put_Line(Output, "");		--Lines to separate header from BMR
		Put(Output, "    ");
		
		while not End_Of_File(Input) loop	--cycle through all contents of Temp_Output
			declare
				Line: String := Get_Line(Input);
			begin
				if (Top_Finished = true and Knt < Array_Size + 1) then
					if (Knt = 1) then				--case 1: print far left column
						Put(Output, Line & " ");
						Knt := Knt + 1;
					else							--case 2: print somewhere in middle
						Put(Output, Line & "   ");
						Knt := Knt + 1;
					end if;
				else								--case 3: print far right column
					if (Top_Finished = true) then
						Put(Output, Line);
						Put_Line(Output, "");
						Knt := 1;
					end if;
				end if;
			
				if (Top_Finished = false) then		--prints top column labels
					Put(Output, Line & " ");
					if (Knt = Array_Size) then		--start new line when finished
						Put_Line(Output, "");
						Top_Finished := true;
						Knt := 0;
					end if;
					Knt := Knt + 1;
				end if;
			end;
		end loop;
		Close(Output);
		Delete(Input);					--delete Temp_Output when finished with it
	end Print_Final;
	
begin
	Get_First;			--place initial 1's
	Warshall;			--place additional 1's
	Print_Temp;			--utilize a temporary, unformatted output
	Print_Final;		--print final, formatted results to file
end gwarshall;