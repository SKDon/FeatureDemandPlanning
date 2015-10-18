CREATE FUNCTION [dbo].[OXO_GetFeatureXML](@doc_Id int, @model_Id int, @level nvarchar(50), @object_id int)
RETURNS XML
WITH RETURNS NULL ON NULL INPUT 
BEGIN RETURN 
	(SELECT F.PROFET_JAG AS '@profet',
	        F.Feature_Group AS '@featGroup', 
		    ISNULL(OXO_Code, '') as '@oxoCode'    
	FROM OXO_Feature F
	LEFT OUTER JOIN OXO_Item_Data D
	ON F.Id = D.Feature_Id
	AND D.OXO_Doc_Id = @doc_Id
	AND D.Model_Id = @model_Id
	AND D.Section = 'FBM'  		
	AND 
	(	
	    (@level = 'g' AND D.Market_Id = -1)
	 OR (@level = 'mg' AND D.Market_Group_Id = @object_id)
	 OR (@level = 'm' AND D.Market_Id = @object_id)
	)
	FOR XML PATH('feat'), ROOT('feats'))
END