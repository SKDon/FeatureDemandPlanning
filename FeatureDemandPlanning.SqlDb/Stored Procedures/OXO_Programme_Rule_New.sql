CREATE PROCEDURE [dbo].[OXO_Programme_Rule_New] 
   @p_ProgrammeId  int, 
   @p_RuleCategory  nvarchar(50), 
   @p_RuleGroup  nvarchar(50),
   @p_RuleAssertLogic  nvarchar(MAX), 
   @p_RuleReportLogic  nvarchar(MAX), 
   @p_RuleResponse  nvarchar(MAX), 
   @p_RuleReason  nvarchar(MAX),    
   @p_Owner  nvarchar(50), 
   @p_Active  bit, 
   @p_CreatedBy  varchar(8), 
   @p_CreatedOn  datetime, 
   @p_UpdatedBy  varchar(8), 
   @p_LastUpdated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Programme_Rule
  (
    Programme_Id,  
    Rule_Category,  
    Rule_Group,
    Rule_Assert,  
    Rule_Report,  
    Rule_Response,  
    Rule_Reason,  
    Owner,  
    Active,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_ProgrammeId,  
    @p_RuleCategory,  
    @p_RuleGroup,
    @p_RuleAssertLogic,  
    @p_RuleReportLogic,  
    @p_RuleResponse,  
    @p_RuleReason,
    @p_Owner,  
    @p_Active,  
    @p_CreatedBy,  
    @p_CreatedOn,  
    @p_UpdatedBy,  
    @p_LastUpdated  
      );

  SET @p_Id = SCOPE_IDENTITY();

