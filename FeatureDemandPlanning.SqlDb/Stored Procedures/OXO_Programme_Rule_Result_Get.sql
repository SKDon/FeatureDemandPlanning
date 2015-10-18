
CREATE PROCEDURE [dbo].[OXO_Programme_Rule_Result_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      OXO_Doc_Id  AS OXODocId,  
      Programme_Id  AS ProgrammeId,  
      Rule_Id  AS RuleId,  
      Model_Id  AS ModelId,  
      Rule_Result  AS RuleResult,  
      Created_By  AS CreatedBy,  
      Created_On  AS CreatedOn  
      	     
    FROM dbo.OXO_Programme_Rule_Result
	WHERE Id = @p_Id;



