create or replace package body bl

as

	procedure log_to_file (
		lineout						in				varchar2
		, level						in				number
	)

	as

		file_name					varchar2(200) := user || '_' || sys_context('USERENV', 'SESSIONID') || '_bl.log';
		file_pointer				utl_file.file_type;
		bl_directory_set			varchar2(30);

	begin

		if sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ') = 'DEFAULT' then
			bl_directory_set := 'BL_LOG_OUTPUT';
		else
			bl_directory_set := sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ');
		end if;

		file_pointer := utl_file.fopen(bl_directory_set, file_name, 'A', 32760);
		utl_file.put_line(file_pointer, to_char(systimestamp, 'DD-MM-YYYY HH24:MI:SS') || ' - ' ||  lineout);
		utl_file.fclose(file_pointer);

		exception
			when others then
				raise;

	end log_to_file;

	procedure log_table_create (
		lineout						in				varchar2
		, level						in				number
	)
	
	as

		bl_table_create_stmt		varchar2(32000);
		bl_table_insert_stmt		varchar2(32000);

		grabbed_module				varchar2(4000);
		grabbed_action				varchar2(4000);
		bl_set_table				varchar2(30);
	
	begin
	
		if sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ') = 'DEFAULT' then
			bl_set_table := 'BL_LOG';
		else
			bl_set_table := sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ');
		end if;

		-- Create the table
		bl_table_create_stmt := 'create table ' || bl_set_table || '(ldate timestamp, luser varchar2(60), llevel varchar2(100), lmodule varchar2(4000), laction varchar2(4000), lline varchar2(4000))';
		execute immediate bl_table_create_stmt;

		dbms_application_info.read_module(grabbed_module, grabbed_action);

		-- Insert the row that caught the exception
		bl_table_insert_stmt := 'insert into ' || bl_set_table || '(ldate, luser, llevel, lmodule, laction, lline) values (:ldate, :llevel, :lmodule, :laction, :lline)';
		execute immediate bl_table_insert_stmt using systimestamp, user, bl.bl_level_names(level), grabbed_module, grabbed_action, lineout;
	
	
		exception
			when others then
				raise;
	
	end log_table_create;

	procedure log_to_table (
		lineout						in				varchar2
		, level						in				number
	)
	
	as

		bl_table_not_created		exception;
		pragma exception_init(bl_table_not_created, -942);
		bl_table_insert_stmt		varchar2(32000);

		grabbed_module				varchar2(4000);
		grabbed_action				varchar2(4000);
		bl_set_table				varchar2(30);
	
	begin
	

		dbms_application_info.read_module(grabbed_module, grabbed_action);

		if sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ') = 'DEFAULT' then
			bl_set_table := 'BL_LOG';
		else
			bl_set_table := sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ');
		end if;

		-- Define insert statement
		bl_table_insert_stmt := 'insert into ' || bl_set_table || '(ldate, luser, llevel, lmodule, laction, lline) values (:ldate, :llevel, :lmodule, :laction, :lline)';
		execute immediate bl_table_insert_stmt using systimestamp, user, bl.bl_level_names(level), grabbed_module, grabbed_action, lineout;
	
		exception
			when bl_table_not_created then
				log_table_create(lineout, level);
			when others then
				raise;
	
	end log_to_table;

	procedure log_to_module (
		lineout						in				varchar2
		, level						in				number
	)

	as

		module_name					varchar2(30);
		module_call_stmt			varchar2(100);
		module_call_res				number;

	begin

		if sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ') = 'DEFAULT' then
			dbms_output.put_line(lineout);
		else
			module_name := sys_context('BL_SETTINGS', 'BL_OUTPUT_OBJ');
			module_call_stmt := 'select ' || module_name || '.bl_ln(:b1, :b2) from dual';
			execute immediate module_call_stmt into module_call_res using lineout, level;
		end if;

	end log_to_module;

	procedure ln (
		lineout						in				varchar2
		, level						in				number
	)
	
	as
	
	begin
	
		-- Do the type dance
		if level >= nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level) then
			case nvl(to_number(sys_context('BL_SETTINGS', 'BL_OUTPUT')), bl.bl_default_output)
				when 1 then
					dbms_output.put_line(lineout);
				when 2 then
					log_to_table(lineout, level);
				when 3 then
					log_to_file(lineout, level);
				when 5 then
					log_to_module(lineout, level);
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
		, line_size						in				pls_integer default sys_context('BL_SETTINGS', 'BL_LINESIZE')
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

	procedure bl_init (
		bl_output_set					in				number	default bl.bl_file
		, bl_output_obj_name			in				varchar2 default 'DEFAULT'
		, bl_linesize					in				number default 80
		, bl_level						in				number default bl.bl_log
	)

	as

	begin

		-- Clearing old settings
		dbms_session.clear_context('BL_SETTINGS', null, 'BL_OUTPUT');
		dbms_session.clear_context('BL_SETTINGS', null, 'BL_OUTPUT_OBJ');
		dbms_session.clear_context('BL_SETTINGS', null, 'BL_LINESIZE');
		dbms_session.clear_context('BL_SETTINGS', null, 'BL_LEVEL');

		-- Initialize settings
		dbms_session.set_context('BL_SETTINGS', 'BL_OUTPUT', bl_output_set, null, null);
		dbms_session.set_context('BL_SETTINGS', 'BL_OUTPUT_OBJ', bl_output_obj_name, null, null);
		dbms_session.set_context('BL_SETTINGS', 'BL_LINESIZE', bl_linesize, null, null);
		dbms_session.set_context('BL_SETTINGS', 'BL_LEVEL', bl_level, null, null);

	end bl_init;

	procedure o (
		logstring						in				sys.anydata
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	)
	
	as

		o_string_length					number;
		o_type							varchar2(4000) := sys.anydata.gettypename(logstring);
	
	begin
	

		if o_type = 'SYS.VARCHAR2' then
			-- Lets get the length before outputting
			o_string_length := length(sys.anydata.accessvarchar2(logstring));
			if o_string_length < to_number(sys_context('BL_SETTINGS', 'BL_LINESIZE')) then
				ln(sys.anydata.accessvarchar2(logstring), loglevel);
			else
				-- Stream output in multiple lines
				stream_output_lines(sys.anydata.accessvarchar2(logstring), loglevel);
			end if;
		elsif o_type = 'SYS.CLOB' then
			-- Lets get the length before outputting
			o_string_length := length(sys.anydata.accessclob(logstring));
			if o_string_length < to_number(sys_context('BL_SETTINGS', 'BL_LINESIZE')) then
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
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	)
	
	as

		o_string_length					number := length(logstring);
	
	begin
	

		if o_string_length < to_number(sys_context('BL_SETTINGS', 'BL_LINESIZE')) then
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
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	)
	
	as

		o_string_length					number := length(logstring);
	
	begin
	

		if o_string_length < to_number(sys_context('BL_SETTINGS', 'BL_LINESIZE')) then
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
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
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
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
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
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
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
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
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

	bl.bl_level_names(1) := 'DEBUG';
	bl.bl_level_names(2) := 'TRACE';
	bl.bl_level_names(3) := 'LOG';

end bl;
/