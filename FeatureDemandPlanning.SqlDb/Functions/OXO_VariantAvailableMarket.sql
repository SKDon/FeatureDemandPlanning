CREATE FUNCTION [OXO_VariantAvailableMarket] 
(
  @p_model_id int,
  @p_market_id int,
  @p_oxo_doc_id int
)
RETURNS INT
AS
BEGIN
   
    DECLARE @retVal INT
	
	SELECT @retVal = COUNT(*) 
	FROM OXO_Item_Data_MBM ODM WITH(NOLOCK)
	WHERE ODM.OXO_DOC_ID = @p_oxo_doc_id  
	AND ODM.OXO_Code = 'Y'
	AND Model_Id = @p_model_id
	AND Market_Id = @p_market_id;
	
	RETURN @retVal;
	
END
