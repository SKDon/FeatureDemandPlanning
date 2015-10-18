
CREATE PROCEDURE [dbo].[OXO_Programme_Rule_Result_DeleteProg] 
  @p_OXODocId int,
  @p_ProgrammeId int,
  @p_Level  nvarchar(3), 
  @p_ObjectId  int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_Rule_Result
  WHERE OXO_Doc_Id = @p_OXODocId
  AND Programme_Id = @p_ProgrammeId
  AND Object_Level = @p_Level
  AND Object_Id = @p_ObjectId;


