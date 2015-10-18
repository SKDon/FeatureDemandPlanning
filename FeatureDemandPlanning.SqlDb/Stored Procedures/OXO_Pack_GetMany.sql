
CREATE PROCEDURE [dbo].[OXO_Pack_GetMany]
   @p_programme_id  INT
AS
	
   SELECT 
	  Id AS Id,
	  Programme_Id AS ProgrammeId,
	  Pack_Name AS Name,
	  Extra_Info AS ExtraInfo,
	  Feature_Code AS FeatureCode,
	  OA_Code AS OACode,
	  Created_By AS CreatedBy,
	  Created_On AS CreatedOn, 	
	  Updated_By AS UpdatedBy,
	  Last_Updated AS LastUpdated
	FROM OXO_Programme_Pack
	WHERE (@p_programme_id = 0 OR Programme_Id = @p_programme_id)
	ORDER BY Pack_Name; 
    

