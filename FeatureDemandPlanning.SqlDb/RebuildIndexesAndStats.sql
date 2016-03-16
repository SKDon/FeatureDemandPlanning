-- Rebuild indexes and refresh statistics for all user-defined tables in the database

DECLARE @TableName varchar(255); 
DECLARE @Sql NVARCHAR(MAX);
 
DECLARE TableCursor CURSOR FOR 
	SELECT table_name FROM information_schema.tables 
	WHERE table_type = 'base table'; 
 
OPEN TableCursor;
 
FETCH NEXT FROM TableCursor INTO @TableName; 
WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT 'Re-indexing table: ' + @TableName;
	
	DBCC DBREINDEX(@TableName, ' ', 90);
	
	PRINT 'Updating statistics: ' + @TableName;
	
	SET @Sql = 'UPDATE STATISTICS ' + @TableName + ' WITH FULLSCAN';
	EXEC sp_executesql @Sql;
	
	FETCH NEXT FROM TableCursor INTO @TableName;
 
END 
 
CLOSE TableCursor;
DEALLOCATE TableCursor;