
CREATE PROCEDURE [dbo].[Fdp_Market_AvailableGetMany]
AS
	SET NOCOUNT ON

	SELECT 
		M.Id					AS Id,
		M.Name					AS Name,  
		M.WHD					AS WHD,
		ISNULL(M.PAR_X, '')		AS PAR_X,  
		ISNULL(M.PAR_L, '')		AS PAR_L,  
		ISNULL(M.Territory, '')	AS Territory,  
		ISNULL(M.WERSCode, '')	AS WERSCode,  
		ISNULL(M.Brand, '')		AS Brand,  
		M.Active				AS Active,  
		M.Created_By			AS Created_By,  
		M.Created_On			AS Created_On,  
		M.Updated_By			AS Updated_By,  
		M.Last_Updated			AS Last_Updated,
		ISNULL(G.Group_Name, '')	AS GroupName    
	FROM OXO_Master_Market			AS M
	LEFT JOIN OXO_Master_MarketGroup_Market_Link AS L ON M.Id				= L.Country_Id
	LEFT JOIN OXO_Master_MarketGroup				AS G ON L.Market_Group_Id	= G.Id
	WHERE
	M.Active = 1
	ORDER BY
	M.Name;