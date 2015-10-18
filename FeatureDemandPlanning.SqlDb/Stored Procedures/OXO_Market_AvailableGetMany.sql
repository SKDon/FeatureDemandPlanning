
CREATE PROCEDURE [dbo].[OXO_Market_AvailableGetMany]
	@p_prog_id as int 
AS
	
	SELECT 
      M.Id  AS Id,
      M.Name  AS Name,  
      M.WHD AS WHD,
      ISNULL(PAR_X, '')  AS PAR_X,  
      ISNULL(PAR_L, '')  AS PAR_L,  
      ISNULL(Territory, '')  AS Territory,  
      ISNULL(WERSCode, '')  AS WERSCode,  
      ISNULL(Brand, '')  AS Brand,  
      M.Active  AS Active,  
      M.Created_By  AS Created_By,  
      M.Created_On  AS Created_On,  
      M.Updated_By  AS Updated_By,  
      M.Last_Updated  AS Last_Updated,
      G.Group_Name as GroupName        
    FROM dbo.OXO_Master_Market M
    LEFT JOIN dbo.OXO_Programme_MarketGroup_Market_Link L
    ON M.Id = L.Country_Id
    AND L.Programme_Id = @p_prog_id
    LEFT JOIN dbo.OXO_Programme_MarketGroup G
    ON L.Market_Group_Id = G.ID
    AND G.Programme_Id = @p_prog_id
    WHERE M.Id > 0      	     
	ORDER By M.Name;
