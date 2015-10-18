
CREATE PROCEDURE [dbo].[OXO_Market_GetMany]
 
AS
	
	SELECT 
      Id  AS Id,
      Name  AS Name,  
      WHD AS WHD,
      ISNULL(PAR_X, '')  AS PAR_X,  
      ISNULL(PAR_L, '')  AS PAR_L,  
      ISNULL(Territory, '')  AS Territory,  
      ISNULL(WERSCode, '')  AS WERSCode,  
      ISNULL(Brand, '')  AS Brand,  
      Active  AS Active,  
      Created_By  AS Created_By,  
      Created_On  AS Created_On,  
      Updated_By  AS Updated_By,  
      Last_Updated  AS Last_Updated        
    FROM dbo.OXO_Master_Market
    WHERE Id > 0      	     
	ORDER By Name;
