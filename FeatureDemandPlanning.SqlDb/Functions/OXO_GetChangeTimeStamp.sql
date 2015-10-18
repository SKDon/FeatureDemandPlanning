CREATE FUNCTION [OXO_GetChangeTimeStamp] 
(
  @p_doc_id INT,
  @p_section nvarchar(50),
  @p_option bit = 0
)
RETURNS nvarchar(100)
AS
BEGIN
	
	-- Declare the return variable here
	DECLARE @retVal nvarchar(100); 
	
	IF @p_option = 0
	BEGIN
		SELECT Top 1 @retVal = Updated_By + '|' + CONVERT(NVARCHAR(16), Last_Updated, 120)
		FROM OXO_Change_Set 
		WHERE OXO_Doc_Id = @p_doc_id
		AND Section = @p_section
		ORDER BY Set_Id ASC;
	END
	ELSE
	BEGIN
		SELECT Top 1 @retVal = Updated_By + '|' + CONVERT(NVARCHAR(16), Last_Updated, 120)
		FROM OXO_Change_Set 
		WHERE OXO_Doc_Id = @p_doc_id
		AND Section = @p_section
		ORDER BY Set_Id DESC;
	END
	
	RETURN (@retVal);

END
