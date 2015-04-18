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

	-- BL Logging levels
	bl_log				number				:= 3;
	bl_trace			number				:= 2;
	bl_debug			number				:= 1;
	bl_level_names		num_arr;

	-- BL output types
	bl_dbms_output		number 				:= 1;
	bl_table			number 				:= 2;
	bl_file				number 				:= 3;
	bl_queue			number 				:= 4;
	bl_module			number 				:= 5;

	-- BL Settings
	bl_seperator		varchar2(50)		:= ' ';
	bl_default_level	number				:= bl.bl_log;
	bl_default_output	number				:= bl.bl_file;

	/** Initialize the logger with own settings instead of default compiled settings
	* @author Morten Egan
	* @param bl_output_set Set the output type for BetterLogging
	*/
	procedure bl_init (
		bl_output_set					in				number	default bl.bl_file
		, bl_output_obj_name			in				varchar2 default 'DEFAULT'
		, bl_linesize					in				number default 80
		, bl_level						in				number default bl.bl_log
	);

	/** Log anydata
	* @author Morten Egan
	* @param logstring The string to output to screen
	*/
	procedure o (
		logstring						in				sys.anydata
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

	/** Log a char type
	* @author Morten Egan
	* @param logstring The char type to log
	*/
	procedure o (
		logstring						in				varchar2
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

	/** Log a clob type
	* @author Morten Egan
	* @param logstring The clob type to log
	*/
	procedure o (
		logstring						in				clob
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

	/** Log a number type
	* @author Morten Egan
	* @param logstring The number type to log
	*/
	procedure o (
		logstring						in				number
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

	/** Log a date type
	* @author Morten Egan
	* @param logstring The date type to log
	*/
	procedure o (
		logstring						in				date
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

	/** Log a timestamp type
	* @author Morten Egan
	* @param logstring The timestamp type to log
	*/
	procedure o (
		logstring						in				timestamp
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

	/** Log a boolean type
	* @author Morten Egan
	* @param parm_name A description of the parameter
	*/
	procedure o (
		logstring						in				boolean
		, loglevel						in				number default nvl(to_number(sys_context('BL_SETTINGS', 'BL_LEVEL')), bl.bl_default_level)
	);

end bl;
/