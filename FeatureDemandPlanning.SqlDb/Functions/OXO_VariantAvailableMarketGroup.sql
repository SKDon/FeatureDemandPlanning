CREATE FUNCTION [OXO_VariantAvailableMarketGroup] 
(
  @p_model_id int,
  @p_market_group_id int,
  @p_oxo_doc_id int,
  @p_prog_id int
)
RETURNS INT
AS
BEGIN
   
    DECLARE @retVal INT
	
	SELECT @retVal = COUNT(*) 
	FROM OXO_Item_Data_MBM ODM WITH (NOLOCK)
	WHERE ODM.OXO_DOC_ID = @p_oxo_doc_id 
	AND ODM.Market_Group_Id = @p_market_group_id
	AND ODM.OXO_Code = 'Y'
	AND Model_Id = @p_model_id;
	
	RETURN @retVal;
	
END
