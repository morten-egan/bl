create or replace package body bl

as

	procedure log_table_create (
		lineout						in				varchar2
	)
	
	as

		bl_table_create_stmt		varchar2(32000);
		bl_table_insert_stmt		varchar2(32000);

		grabbed_module				varchar2(4000);
		grabbed_action				varchar2(4000);
	
	begin
	

		-- Create the table
		bl_table_create_stmt := 'create table ' || bl.bl_table_name || '(ldate timestamp, llevel number, lmodule varchar2(4000), laction varchar2(4000), lline varchar2(4000))';
		execute immediate bl_table_create_stmt;

		-- Insert the row that caught the exception
		bl_table_insert_stmt := 'insert into ' || bl_table_name || '(ldate, llevel, lmodule, laction, lline) values (:ldate, :llevel, :lmodule, :laction, :lline)';
		execute immediate bl_table_insert_stmt using systimestamp, 1, 'test', 'test', lineout;
	
	
		exception
			when others then
				raise;
	
	end log_table_create;

	procedure log_to_table (
		lineout						in				varchar2
	)
	
	as

		bl_table_not_created		exception;
		pragma exception_init(bl_table_not_created, -942);
		bl_table_insert_stmt		varchar2(32000);

		grabbed_module				varchar2(4000);
		grabbed_action				varchar2(4000);
	
	begin
	

		dbms_application_info.read_module(grabbed_module, grabbed_action);

		-- Define insert statement
		bl_table_insert_stmt := 'insert into ' || bl_table_name || '(ldate, llevel, lmodule, laction, lline) values (:ldate, :llevel, :lmodule, :laction, :lline)';
		execute immediate bl_table_insert_stmt using systimestamp, 1, 'test', 'test', lineout;
	
	
		exception
			when bl_table_not_created then
				log_table_create(lineout);
			when others then
				raise;
	
	end log_to_table;

	procedure ln (
		lineout						in				varchar2
		, level						in				number
	)
	
	as
	
	begin
	

		-- Do the type dance
		if level >= bl.bl_default_level then
			case bl.bl_type_set
				when 1 then
					dbms_output.put_line(lineout);
				when 2 then
					log_to_table(lineout);
				else
					dbms_output.put_line(lineout);
			end case;
		end if;
	
	
		exception
			when others then
				raise;
	
	end ln;

	procedure stream_output_lines (
		logstring						in				varchar2
		, loglevel						in				number
		, line_size						in				pls_integer default bl.bl_linesize
		, line_seperator				in				varchar2 default bl.bl_seperator
	)
	
	as

		working_string					varchar2(4000) := logstring || line_seperator;
		string_line						varchar2(4000);
		working_string_position			pls_integer;
	
	begin
	

		while working_string is not null loop
			string_line := substr(working_string, 1, line_size);
			working_string_position := instr(string_line, line_seperator, -1);
			string_line := substr(string_line, 1, working_string_position);
			ln(string_line, loglevel);
			working_string := substr(working_string, working_string_position + 1);
		end loop;
	
	
		exception
			when others then
				raise;
	
	end stream_output_lines;

	procedure o (
		logstring						in				sys.anydata
		, loglevel						in				number default bl.bl_default_level
	)
	
	as

		o_string_length					number;
		o_type							varchar2(4000) := sys.anydata.gettypename(logstring);
	
	begin
	

		if o_type = 'SYS.VARCHAR2' then
			-- Lets get the length before outputting
			o_string_length := length(sys.anydata.accessvarchar2(logstring));
			if o_string_length < bl.bl_linesize then
				ln(sys.anydata.accessvarchar2(logstring), loglevel);
			else
				-- Stream output in multiple lines
				stream_output_lines(sys.anydata.accessvarchar2(logstring), loglevel);
			end if;
		elsif o_type = 'SYS.CLOB' then
			-- Lets get the length before outputting
			o_string_length := length(sys.anydata.accessclob(logstring));
			if o_string_length < bl.bl_linesize then
				ln(sys.anydata.accessclob(logstring), loglevel);
			else
				-- Stream output in multiple lines
				stream_output_lines(sys.anydata.accessclob(logstring), loglevel);
			end if;
		elsif o_type = 'SYS.NUMBER' then
			ln(to_char(sys.anydata.accessnumber(logstring)), loglevel);
		elsif o_type = 'SYS.DATE' then
			ln(to_char(sys.anydata.accessdate(logstring)), loglevel);
		end if;	
	
		exception
			when others then
				raise;
	
	end o;

	procedure o (
		logstring						in				varchar2
		, loglevel						in				number default bl.bl_default_level
	)
	
	as

		o_string_length					number := length(logstring);
	
	begin
	

		if o_string_length < bl.bl_linesize then
			ln(logstring, loglevel);
		else
			-- Stream output in multiple lines
			stream_output_lines(logstring, loglevel);
		end if;
	
	
		exception
			when others then
				raise;
	
	end o;

	procedure o (
		logstring						in				clob
		, loglevel						in				number default bl.bl_default_level
	)
	
	as

		o_string_length					number := length(logstring);
	
	begin
	

		if o_string_length < bl.bl_linesize then
			ln(logstring, loglevel);
		else
			-- Stream output in multiple lines
			stream_output_lines(logstring, loglevel);
		end if;
	
	
		exception
			when others then
				raise;
	
	end o;

	procedure o (
		logstring						in				number
		, loglevel						in				number default bl.bl_default_level
	)
	
	as
	
	begin
	
		ln(to_char(logstring), loglevel);
	
		exception
			when others then
				raise;
	
	end o;

	procedure o (
		logstring						in				date
		, loglevel						in				number default bl.bl_default_level
	)
	
	as
	
	begin
	
		ln(to_char(logstring), loglevel);
	
		exception
			when others then
				raise;
	
	end o;

	procedure o (
		logstring						in				timestamp
		, loglevel						in				number default bl.bl_default_level
	)
	
	as
	
	begin
	
		ln(to_char(logstring), loglevel);
	
		exception
			when others then
				raise;
	
	end o;

	procedure o (
		logstring						in				boolean
		, loglevel						in				number default bl.bl_default_level
	)
	
	as
	
	begin
	
		if logstring then
			ln('true', loglevel);
		else
			ln('false', loglevel);
		end if;
	
		exception
			when others then
				raise;
	
	end o;

begin

	dbms_application_info.set_client_info('bl');
	dbms_session.set_identifier('bl');

end bl;
/