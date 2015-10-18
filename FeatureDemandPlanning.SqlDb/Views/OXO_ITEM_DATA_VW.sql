CREATE VIEW [dbo].[OXO_ITEM_DATA_VW]
AS

	SELECT Id, Section, OXO_Doc_Id, Model_Id, 
	       null AS Pack_Id, null AS Feature_Id,
	       null AS Market_Group_Id, Market_Id,
	       OXO_Code , Reminder, Active  
	FROM OXO_ITEM_DATA_MBM
	UNION ALL
	SELECT Id, Section, OXO_Doc_Id, Model_Id,  
	       null AS Pack_Id, Feature_Id,
		   Market_Group_Id, Market_Id,
		   OXO_Code , Reminder, Active  
	FROM OXO_ITEM_DATA_FBM
	UNION ALL
	SELECT Id, Section, OXO_Doc_Id, Model_Id,  
	       null AS Pack_Id, Feature_Id,
		   null AS Market_Group_Id, -1 AS Market_Id,
		   OXO_Code , Reminder, Active  
	FROM OXO_ITEM_DATA_GSF
	UNION ALL
	SELECT Id, Section, OXO_Doc_Id, Model_Id,  
	       Pack_Id, null AS Feature_Id,
		   Market_Group_Id, Market_Id,
		   OXO_Code , Reminder, Active  
	FROM OXO_ITEM_DATA_PCK
	UNION ALL
	SELECT Id, Section, OXO_Doc_Id, Model_Id,  
	       Pack_Id, Feature_Id,
		   Market_Group_Id, Market_Id,
		   OXO_Code , Reminder, Active   
	FROM OXO_ITEM_DATA_FPS

