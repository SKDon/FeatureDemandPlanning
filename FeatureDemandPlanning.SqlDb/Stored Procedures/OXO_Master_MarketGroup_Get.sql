
CREATE PROCEDURE [dbo].[OXO_Master_MarketGroup_Get] 
  @p_Id int,
  @p_deep_get BIT = 0  
AS
	
	SELECT 
	  'Master' AS Type, 
      Id  AS Id,
      Group_Name  AS GroupName,  
     -- Sub_Group_Name  AS SubGroupName,  
      Extra_Info  AS ExtraInfo,  
      Make  AS Make,  
      Active  AS Active,  
      Display_Order AS DisplayOrder,
      Created_By  AS CreatedBy,  
      Created_On  AS CreatedOn,  
      Updated_By  AS UpdatedBy,  
      Last_Updated  AS LastUpdated        	     
    FROM dbo.OXO_Master_MarketGroup
	WHERE Id = @p_Id;
	
	IF @p_deep_get = 1
	  SELECT 
		  C.Id  AS Id,
		  C.Name  AS Name,  
		  C.WHD AS WHD,
		  C.PAR_X  AS PARX,  
		  C.PAR_L  AS PARL,  
		  C.Territory  AS Territory,  
		  C.Active  AS Active,  
		  C.Created_By  AS CreatedBy,  
		  C.Created_On  AS CreatedOn,  
		  C.Updated_By  AS UpdatedBy,  
		  C.Last_Updated  AS LastUpdated        	     
		FROM dbo.OXO_Master_Country C
		INNER JOIN dbo.OXO_Master_Market_Country_Link L
		ON C.Id = L.Country_Id
		AND L.Market_Group_Id = @p_Id;



