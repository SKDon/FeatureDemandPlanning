CREATE PROCEDURE [dbo].[OXO_Feature_GetManyBlank]
 
AS
	
   SELECT 
    0  AS Id,
    'No Feature Found'  AS Description,  
    null  AS Notes,  
    null  AS PROFEAT,  
    null  AS Active,  
    R.Description  AS FeatureGroup,  
    null  AS FeatureSubGroup,  
    null  AS Car_Lines,
    null AS Make,
    R.Display_Order AS GroupOrder
  	FROM OXO_Reference_List R
	WHERE R.List_Name = 'Feature Group'
	AND NOT EXISTS
	( SELECT 1 FROM dbo.OXO_Feature F WHERE F.Feature_Group = R.Description )
	ORDER BY R.Display_Order;

