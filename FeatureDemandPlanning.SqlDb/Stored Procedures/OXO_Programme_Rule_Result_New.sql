
CREATE  PROCEDURE [dbo].[OXO_Programme_Rule_Result_New] 
   @p_OXODocId  int, 
   @p_ProgrammeId  int,
   @p_Level  nvarchar(3), 
   @p_ObjectId  int,  
   @p_RuleId  int, 
   @p_ModelId  int, 
   @p_RuleResult  bit, 
   @p_CreatedBy  nvarchar(8), 
   @p_CreatedOn  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Programme_Rule_Result
  (
    OXO_Doc_Id,  
    Programme_Id,
    Object_Level,
    Object_Id,
    Rule_Id,  
    Model_Id,  
    Rule_Result,  
    Created_By,  
    Created_On  
          
  )
  VALUES 
  (
    @p_OXODocId,  
    @p_ProgrammeId,  
    @p_Level,
    @p_ObjectId,
    @p_RuleId,  
    @p_ModelId,  
    @p_RuleResult,  
    @p_CreatedBy,  
    @p_CreatedOn  
      );

  SET @p_Id = SCOPE_IDENTITY();


