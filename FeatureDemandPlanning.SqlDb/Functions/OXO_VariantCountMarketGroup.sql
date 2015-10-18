CREATE FUNCTION [OXO_VariantCountMarketGroup] 
(
  @p_market_group_id int,
  @p_prog_id int,
  @p_oxo_doc_id int,
  @p_archived bit = 0
)
RETURNS INT
AS
BEGIN
   
    DECLARE @retVal INT
	
	IF ISNULL(@p_archived, 0) = 0	
		SELECT @retVal = COUNT(DISTINCT OD.Model_Id) 
		FROM OXO_Item_Data_MBM OD WITH(NOLOCK)
		INNER JOIN OXO_Programme_Model V
		ON V.Id = OD.Model_Id
		AND V.Active = 1 
		AND V.Programme_Id = @p_prog_id
		WHERE OD.OXO_Doc_Id = @p_oxo_doc_id
		AND OD.Market_Group_Id = @p_market_group_id 
		AND OD.OXO_Code = 'Y'
		AND OD.Active = 1;
	ELSE
		SELECT @retVal = COUNT(DISTINCT OD.Model_Id) 
		FROM OXO_Item_Data_MBM OD WITH(NOLOCK)
		INNER JOIN OXO_Archived_Programme_Model V
		ON V.Id = OD.Model_Id
		AND V.Active = 1 
		AND V.Programme_Id = @p_prog_id
		AND V.Doc_Id = @p_oxo_doc_id
		WHERE OD.OXO_Doc_Id = @p_oxo_doc_id
		AND OD.Market_Group_Id = @p_market_group_id 
		AND OD.OXO_Code = 'Y'
		AND OD.Active = 1;
	
	RETURN @retVal;
	
END
