CREATE FUNCTION [OXO_ModelIdString_Get] 
(
  @p_doc_id INT,  
  @p_mode NVARCHAR(50),  
  @p_objectid INT
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   
    DECLARE @retVal NVARCHAR(4000);
   
	IF (@p_mode = 'g')
	BEGIN
		SELECT @retVal = COALESCE(@retVal + ',', '') + CAST(M.Id AS NVARCHAR)
		FROM OXO_Programme_Model M
		INNER JOIN OXO_Doc D
		ON M.Programme_Id = D.Programme_Id
		WHERE D.Id = @p_doc_id
		AND M.Active = 1;	
	END
   
    IF (@p_mode = 'mg')
	BEGIN
		WITH SET_A AS
		( SELECT DISTINCT Model_Id
		  FROM OXO_Item_Data_MBM
			WHERE OXO_Doc_Id = @p_doc_id
			AND Market_Group_ID = @p_objectid
			AND OXO_Code = 'Y'
			AND Active = 1
		)		
		SELECT @retVal = COALESCE(@retVal + ',', '') + CAST(Model_Id AS NVARCHAR)
		FROM SET_A;	
	END
        
    IF (@p_mode = 'm')
	BEGIN
		SELECT @retVal = COALESCE(@retVal + ',', '') + CAST(Model_Id AS NVARCHAR)
		FROM OXO_Item_Data_MBM
		WHERE OXO_Doc_Id = @p_doc_id
		AND Market_ID = @p_objectid
		AND OXO_Code = 'Y'
		AND Active = 1;	
	END

	RETURN  @retVal;   
    	
END