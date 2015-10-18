CREATE PROCEDURE [dbo].[OXO_ModelTrim_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      Programme_Id  AS ProgrammeId,  
      Name  AS Name,  
      Abbreviation AS Abbreviation,
      Level  AS Level,
      DPCK AS DPCK,  
      Display_Order AS DisplayOrder,
      Active  AS Active,        
      Created_By  AS Created_By,  
      Created_On  AS Created_On,  
      Updated_By  AS Updated_By,  
      Last_Updated  AS Last_Updated  
      	     
    FROM dbo.OXO_Programme_Trim
	WHERE Id = @p_Id
	AND ISNULL(Active, 0) = 1;

