
CREATE  PROCEDURE [dbo].[OXO_Rule_Feature_New] 
   @p_RuleId  int, 
   @p_ProgrammeId  int, 
   @p_FeatureId  int,
   @p_CreatedBy  varchar(8), 
   @p_CreatedOn  datetime, 
   @p_UpdatedBy  varchar(8), 
   @p_LastUpdated  datetime
AS
	
  INSERT INTO dbo.OXO_Rule_Feature_Link
  (
    Rule_Id,
    Programme_Id,  
    Feature_Id,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated         
  )
  VALUES 
  (
    @p_RuleId, 
    @p_ProgrammeId, 
    @p_FeatureId,
    @p_CreatedBy,  
    @p_CreatedOn,  
    @p_UpdatedBy,  
    @p_LastUpdated  
   );



