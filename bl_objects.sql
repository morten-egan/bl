create or replace type BL_QUEUE_TYP as object (
	log_time			timestamp
	, log_user			varchar2(60)
	, log_level			varchar2(100)
	, log_module		varchar2(4000)
	, log_action		varchar2(4000)
	, log_line			varchar2(4000)
)
/