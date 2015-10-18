CREATE PROCEDURE [dbo].[OXO_Data_Change_History]
	@p_doc_id int,
	@p_section nvarchar(50),
	@p_model_id int,
	@p_market_id int,
	@p_market_group_Id int,
	@p_feature_id int
AS
	
   SELECT  Set_Id AS SetId,
		   VersionId AS VersionId,
           Last_Updated AS LastUpdated, 
		   Updated_By AS UpdatedBy, 
		   Item_Code AS ItemCode, 
		   Reminder AS Reminder 
	FROM [dbo].[OXO_Item_Data_Hist_VW] V
	WHERE Section = @p_section
	AND Model_Id = @p_model_id
	AND ISNULL(Market_Id,0) = @p_market_id
	AND ISNULL(Market_Group_Id,0) = @p_market_group_Id
	AND (
	      Feature_Id = @p_feature_id 
	      OR 
	      (ISNULL(Feature_ID,0) = 0 AND @p_section = 'mbm')
	)
	AND OXO_DOC_Id = @p_doc_id	
	ORDER BY V.Last_Updated DESC
    
    
    
SELECT * FROM [dbo].[OXO_Item_Data_Hist_VW]

