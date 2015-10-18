CREATE Function [dbo].[FN_CsvIN] (@Array varchar(max)) 
returns @Table table 
	(code varchar(100))
AS
begin
-- SELECT * FROM FN_CsvIN(@picks)
	declare @separator char(1)
	set @separator = ','
	declare @separator_position int 
	declare @array_value varchar(max) 
	set @array = replace(@array, ' ','')
	
	set @array = @array + ','
	
	while patindex('%,%' , @array) <> 0 
	begin
	
	  select @separator_position =  patindex('%,%' , @array)
	  select @array_value = left(@array, @separator_position - 1)
	
		Insert @Table
		Values (@array_value)
	  select @array = stuff(@array, 1, @separator_position, '')
	end
	return
end