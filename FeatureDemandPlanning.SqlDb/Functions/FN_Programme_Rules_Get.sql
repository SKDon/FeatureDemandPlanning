CREATE FUNCTION [FN_Programme_Rules_Get]( 
	@p_prog_id INT,
    @p_doc_id INT
) 
RETURNS @result TABLE (
	Programme_Id INT,
	Rule_Category NVARCHAR(50),
	Rule_Group NVARCHAR(50),
	Rule_Assert NVARCHAR(500),
	Rule_Report NVARCHAR(500),
	Rule_Response NVARCHAR(500),
	Owner NVARCHAR(50),
	Approved BIT,
	Rule_Reason NVARCHAR(MAX),	
	Active BIT,
	Id INT,
	CreatedBy NVARCHAR(8),
	CreatedOn DATETIME,
	UpdatedBy NVARCHAR(8),
	LastUpdated DATETIME
)  
AS
BEGIN

  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;

  IF (ISNULL(@p_archived,0) = 0) 
  
  	INSERT INTO @result
    SELECT 	Programme_Id, Rule_Category, Rule_Group, Rule_Assert, Rule_Report, Rule_Response,
	        Owner, Approved, Rule_Reason, Active, Id, Created_By, Created_On, Updated_By, Last_Updated    
	FROM OXO_Programme_Rule
	WHERE Programme_Id = @p_prog_id;
  
  ELSE
  
	INSERT INTO @result
     SELECT 	Programme_Id, Rule_Category, Rule_Group, Rule_Assert, Rule_Report, Rule_Response,
	            Owner, Approved, Rule_Reason,	Active, Id, Created_By, Created_On, Updated_By, Last_Updated    
	FROM OXO_Archived_Programme_Rule
	WHERE Programme_Id = @p_prog_id
	AND   Doc_Id = @p_doc_id;
		
   RETURN;
	
END
