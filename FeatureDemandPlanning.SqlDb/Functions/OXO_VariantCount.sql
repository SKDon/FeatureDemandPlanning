CREATE FUNCTION [OXO_VariantCount] 
(
  @p_market_id int,
  @p_oxo_doc_id int,
  @p_model_ids NVARCHAR(MAX) = NULL
)
RETURNS INT
AS
BEGIN
   
    DECLARE @retVal INT;
    
    IF @p_model_ids IS NULL
		SELECT @retVal = COUNT(*) 
		FROM OXO_Item_Data_MBM OD WITH(NOLOCK)
		WHERE OXO_Doc_Id = @p_oxo_doc_id
		AND Market_ID = @p_market_id
		AND OXO_Code = 'Y'
		AND OD.Active = 1;
    ELSE
		WITH Models AS
		(
			SELECT Model_Id FROM dbo.FN_SPLIT_MODEL_IDS(@p_model_ids)
		)
		SELECT @retVal = COUNT(*) 
		FROM OXO_Item_Data_MBM OD WITH(NOLOCK)
		INNER JOIN Models M
		ON M.Model_Id = OD.Model_Id
		WHERE OXO_Doc_Id = @p_oxo_doc_id
		AND Market_ID = @p_market_id
		AND OXO_Code = 'Y'
		AND OD.Active = 1;
	
	RETURN @retVal;
	
END
