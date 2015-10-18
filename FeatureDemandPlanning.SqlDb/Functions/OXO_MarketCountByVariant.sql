CREATE FUNCTION [OXO_MarketCountByVariant] 
(
  @p_model_id int,
  @p_oxo_doc_id int
)
RETURNS INT
AS
BEGIN
   
    DECLARE @retVal INT
	
	SELECT @retVal = COUNT(*) 
	FROM OXO_Item_Data OD 
	WHERE SECTION = 'MBM'
	AND OXO_Doc_Id = @p_oxo_doc_id
	AND Model_ID = @p_model_id
	AND OXO_Code = 'Y'
	AND Active = 1;
	
	RETURN @retVal;
	
END
