CREATE PROCEDURE [dbo].[OXO_ModelTrim_GetMany]
   @p_prog_id  int
AS
	SET NOCOUNT ON;
	
   SELECT 
    Id  AS Id,
    Programme_Id  AS ProgrammeId,  
    Abbreviation AS Abbreviation,
    Name  AS Name,  
    Level  AS Level,
    DPCK AS DPCK,  
    Active  AS Active,  
    Created_By  AS Created_By,  
    Created_On  AS Created_On,  
    Updated_By  AS Updated_By,  
    Last_Updated  AS Last_Updated  
    FROM dbo.OXO_Programme_Trim
    WHERE (@p_prog_id = 0 OR Programme_Id = @p_prog_id)
    AND ISNULL(Active, 0) = 1
    ORDER By ISNULL(Display_Order, 1);