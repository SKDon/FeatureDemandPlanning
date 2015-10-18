CREATE PROCEDURE [dbo].[OXO_DELETE_PROG_CASCADE]
 
  @p_prog_id INT = 0

AS

  --DELETE FROM OXO_Programme_Model WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_Body WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_Engine WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_Transmission WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_Trim WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_Pack WHERE Programme_Id = @p_prog_id;
  DELETE FROM OXO_Rule_Feature_Link WHERE Programme_Id = @p_prog_id;
  DELETE FROM OXO_Programme_Rule WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_MarketGroup_Market_Link WHERE Programme_Id = @p_prog_id;
  --DELETE FROM OXO_Programme_MarketGroup WHERE Programme_Id = @p_prog_id;
  DELETE FROM OXO_Programme_Feature_Link WHERE Programme_Id = @p_prog_id;
  DELETE FROM OXO_Programme_GSF_Link WHERE Programme_Id = @p_prog_id;

