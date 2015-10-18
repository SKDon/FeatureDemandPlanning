


CREATE PROCEDURE [OXO_Pack_Get] 
  @p_ID int,
  @p_doc_Id int,
  @p_deep bit = 0
AS
	
  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id;	
  	
  IF (ISNULL(@p_archived, 0) = 0)	
    SELECT 
	  Id AS Id,
	  Programme_Id AS ProgrammeId,
	  Pack_Name AS Name,
	  Extra_Info AS ExtraInfo,
	  Feature_Code AS FeatureCode,
	  Created_By AS CreatedBy,
	  Created_On AS CreatedOn, 	
	  Updated_By AS UpdatedBy,
	  Last_Updated AS LastUpdated
	FROM OXO_Programme_Pack
	WHERE id = @p_ID;
  
  ELSE
    SELECT 
	  Id AS Id,
	  Programme_Id AS ProgrammeId,
	  Pack_Name AS Name,
	  Extra_Info AS ExtraInfo,
	  Feature_Code AS FeatureCode,
	  Created_By AS CreatedBy,
	  Created_On AS CreatedOn, 	
	  Updated_By AS UpdatedBy,
	  Last_Updated AS LastUpdated
	FROM OXO_Archived_Programme_Pack
	WHERE id = @p_ID;

