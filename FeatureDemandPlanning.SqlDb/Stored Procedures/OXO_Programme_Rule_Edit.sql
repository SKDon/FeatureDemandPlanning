CREATE PROCEDURE [OXO_Programme_Rule_Edit] 
   @p_Id INT
  ,@p_ProgrammeId  int 
  ,@p_RuleCategory  nvarchar(50)
  ,@p_RuleGroup  nvarchar(50) 
  ,@p_RuleAssertLogic  nvarchar(max) 
  ,@p_RuleReportLogic  nvarchar(max) 
  ,@p_RuleResponse  nvarchar(max) 
  ,@p_RuleReason   nvarchar(max) 
  ,@p_Owner  nvarchar(50)   
  ,@p_Active  bit 
  ,@p_CreatedBy  varchar(8) 
  ,@p_CreatedOn  datetime 
  ,@p_UpdatedBy  varchar(8) 
  ,@p_LastUpdated  datetime 
      
AS
	
  UPDATE dbo.OXO_Programme_Rule 
    SET 
  Programme_Id=@p_ProgrammeId,  
  Rule_Category=@p_RuleCategory, 
  Rule_Group=@p_RuleGroup, 
  Rule_Assert=@p_RuleAssertLogic,  
  Rule_Report=@p_RuleReportLogic,  
  Rule_Response=@p_RuleResponse,
  Rule_Reason = @p_RuleReason,  
  Owner=@p_Owner,  
  Active=@p_Active,  
  Updated_By=@p_UpdatedBy,  
  Last_Updated=@p_LastUpdated  
  	     
   WHERE Id = @p_Id;

