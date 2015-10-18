
CREATE PROCEDURE [dbo].[OXO_Rule_Feature_Delete] 
  @p_RuleId int,
  @p_ProgrammeId int
AS
	
  DELETE 
  FROM dbo.OXO_Rule_Feature_Link
  WHERE Rule_Id = @p_RuleId
  AND Programme_Id = @p_ProgrammeId



