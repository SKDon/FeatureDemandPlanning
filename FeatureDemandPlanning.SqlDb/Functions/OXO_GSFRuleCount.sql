
CREATE FUNCTION [OXO_GSFRuleCount] 
(
  @p_prog_id int,
  @p_doc_id int,
  @p_feature_id int
)
RETURNS INT
AS
BEGIN
   
    DECLARE @retVal INT
	DECLARE @p_archived BIT;
	  
	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;
	
	IF @p_archived = 1 
	  BEGIN
		SELECT @retVal = CASE WHEN ISNULL(Rule_Text, '') = '' THEN 0
		       ELSE 1 END 
		FROM OXO_Archived_Programme_GSF_Link
		WHERE Programme_Id = @p_prog_id
		AND Feature_Id = @p_feature_id
		AND Doc_Id = @p_doc_id
	  END
	ELSE
	  BEGIN
	    SELECT @retVal = CASE WHEN ISNULL(Rule_Text, '') = '' THEN 0
	           ELSE 1 END 
	    FROM OXO_Programme_GSF_Link
	    WHERE Programme_Id = @p_prog_id
	    AND Feature_Id = @p_feature_id
	  END
	
	
	
	--SELECT @retVal = COUNT(*) 
	--FROM OXO_Rule_Feature_Link  
	--WHERE Programme_Id = @p_prog_id
	--AND Feature_Id = @p_feature_id;
	
	
	
	RETURN @retVal;
	
END
