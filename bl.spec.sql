create or replace package bl

as

	/** Better Logging (BL) package. A logging facility for plsql, and also better screen output.
	* @author Morten Egan
	* @version 0.0.1
	* @project Better Logging 4 Oracle
	*/
	p_version			varchar2(50) 		:= '0.0.1';

	-- Helper types
	type num_arr is table of varchar2(4000) index by pls_integer;

	-- BL Settings
	bl_type_set			number				:= 3;
	bl_linesize			pls_integer			:= 80;
	bl_seperator		varchar2(50)		:= ' ';

	-- BL Logging levels
	bl_log				number				:= 3;
	bl_trace			number				:= 2;
	bl_debug			number				:= 1;
	bl_default_level	number				:= bl.bl_log;
	bl_level_names		num_arr;

	-- BL DBMS_OUTPUT settings
	bl_dbms_output		number 				:= 1;

	-- BL Table output settings
	bl_table			number 				:= 2;
	bl_table_name		varchar2(30) 		:= 'BL_LOG';

	-- BL File output settings
	bl_file				number 				:= 3;
	bl_directory_name	varchar2(30)		:= 'BL_LOG_OUTPUT';

	-- BL Queue output settings
	bl_queue			number 				:= 4;
	bl_queue_name		varchar2(30)		:= 'BL_LOG_Q';

	-- BL Module output settings
	bl_module			number 				:= 5;
	bl_module_name		varchar2(250)		:= 'DEFAULT';

	/** Log anydata
	* @author Morten Egan
	* @param logstring The string to output to screen
	*/
	procedure o (
		logstring						in				sys.anydata
		, loglevel						in				number default bl.bl_default_level
	);

	/** Log a char type
	* @author Morten Egan
	* @param logstring The char type to log
	*/
	procedure o (
		logstring						in				varchar2
		, loglevel						in				number default bl.bl_default_level
	);

	/** Log a clob type
	* @author Morten Egan
	* @param logstring The clob type to log
	*/
	procedure o (
		logstring						in				clob
		, loglevel						in				number default bl.bl_default_level
	);

	/** Log a number type
	* @author Morten Egan
	* @param logstring The number type to log
	*/
	procedure o (
		logstring						in				number
		, loglevel						in				number default bl.bl_default_level
	);

	/** Log a date type
	* @author Morten Egan
	* @param logstring The date type to log
	*/
	procedure o (
		logstring						in				date
		, loglevel						in				number default bl.bl_default_level
	);

	/** Log a timestamp type
	* @author Morten Egan
	* @param logstring The timestamp type to log
	*/
	procedure o (
		logstring						in				timestamp
		, loglevel						in				number default bl.bl_default_level
	);

	/** Log a boolean type
	* @author Morten Egan
	* @param parm_name A description of the parameter
	*/
	procedure o (
		logstring						in				boolean
		, loglevel						in				number default bl.bl_default_level
	);

end bl;
/