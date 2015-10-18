CREATE PROCEDURE [OXO_Programme_Rule_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      Programme_Id  AS ProgrammeId,  
      Rule_Category  AS RuleCategory,
      Rule_Group AS RuleGroup,
      Rule_Assert  AS RuleAssertLogic,  
      Rule_Report  AS RuleReportLogic,  
      Rule_Response  AS RuleResponse,
      Rule_Reason AS RuleReason,  
      Owner  AS Owner,  
      Active  AS Active,  
      Created_By  AS CreatedBy,  
      Created_On  AS CreatedOn,  
      Updated_By  AS UpdatedBy,  
      Last_Updated  AS LastUpdated  
      	     
    FROM dbo.OXO_Programme_Rule
	WHERE Id = @p_Id;

