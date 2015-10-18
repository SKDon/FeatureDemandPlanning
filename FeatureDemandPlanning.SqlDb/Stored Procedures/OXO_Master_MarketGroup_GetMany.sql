CREATE PROCEDURE [dbo].[OXO_Master_MarketGroup_GetMany]
  @p_deep_get BIT = 0
AS
	
   SELECT 
    'Master' AS Type, 
    Id  AS Id,
    Group_Name  AS GroupName,  
    Extra_Info  AS ExtraInfo,  
    Make  AS Make,  
    Active  AS Active,  
    Display_Order AS DisplayOrder,
    Created_By  AS CreatedBy,  
    Created_On  AS CreatedOn,  
    Updated_By  AS UpdatedBy,  
    Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Master_MarketGroup;
    
	IF @p_deep_get = 1
	  SELECT 
		  C.Id  AS Id,
		  C.Name  AS Name,  
		  C.WHD AS WHD,
		  ISNULL(C.PAR_X, '')  AS PAR_X,  
		  ISNULL(C.PAR_L, '')  AS PAR_L,  
		  C.Territory  AS Territory,  
		  C.Active  AS Active,  
		  C.Created_By  AS CreatedBy,  
		  C.Created_On  AS CreatedOn,  
		  C.Updated_By  AS UpdatedBy,  
		  C.Last_Updated  AS LastUpdated,
		  L.Market_Group_Id AS ParentId,
		  ISNULL(L.Sub_Region, '')  AS SubRegion,  
		  CASE WHEN L.Sub_Region = 'NSC' THEN 1
          ELSE 10 END AS SubRegionOrder
           	     
		FROM dbo.OXO_Master_MarketGroup M
		INNER JOIN dbo.OXO_Master_MarketGroup_Market_Link L
		ON M.Id = L.Market_Group_Id
		INNER JOIN dbo.OXO_Master_Market C
		ON L.Country_Id = C.Id;
            

