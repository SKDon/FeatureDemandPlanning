CREATE FUNCTION [OXO_Version_Label_Get] 
(
  @p_version_id DECIMAL(10,2),
  @p_status NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
   
	RETURN  'v' + convert(nvarchar, cast(@p_version_id as decimal(10,1))) 
	        + CASE WHEN @p_status = 'WIP' THEN ' WIP' ELSE '' END;
	
END