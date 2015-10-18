
CREATE PROCEDURE [dbo].[OXO_Programme_Rule_Result_Edit] 
   @p_Id INT
  ,@p_OXODocId  int 
  ,@p_ProgrammeId  int 
  ,@p_RuleId  int 
  ,@p_ModelId  int 
  ,@p_RuleResult  bit 
  ,@p_CreatedBy  nvarchar(8) 
  ,@p_CreatedOn  datetime 
      
AS
	
  UPDATE dbo.OXO_Programme_Rule_Result 
    SET 
  OXO_Doc_Id=@p_OXODocId,  
  Programme_Id=@p_ProgrammeId,  
  Rule_Id=@p_RuleId,  
  Model_Id=@p_ModelId,  
  Rule_Result=@p_RuleResult,  
  Created_By=@p_CreatedBy,  
  Created_On=@p_CreatedOn  
  	     
   WHERE Id = @p_Id;

