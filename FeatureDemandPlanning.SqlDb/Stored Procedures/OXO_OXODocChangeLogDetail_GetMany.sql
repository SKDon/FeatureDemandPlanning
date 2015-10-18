CREATE PROCEDURE [OXO_OXODocChangeLogDetail_GetMany]
  @p_process_UID INT
AS
	SELECT DISTINCT @p_process_UID AS ProcessUID, 
		   ISNULL(C.Name, MG.Group_Name) AS MarketName,
	       M.Name AS ModelName,  
		   CASE WHEN D.SECTION = 'MBM' THEN 'Availability'
		   ELSE ISNULL(F.Description, PP.Pack_Name) END AS FeatureName, 
	       ISNULL(H.Prev_Code, '') AS PrevFitment,
	       ISNULL(H.Item_Code, '') AS CurrFitment
	FROM OXO_ITEM_DATA_Hist H
	INNER JOIN OXO_ITEM_DATA D
	ON H.Item_Id = D.ID
	INNER JOIN OXO_Models_VW M
	ON D.Model_Id = M.Id
	INNER JOIN OXO_DOC OD
	ON D.OXO_Doc_Id = OD.ID
	LEFT OUTER JOIN OXO_Master_Market C
	ON D.Market_Id = C.Id
	LEFT OUTER JOIN OXO_Programme_MarketGroup MG
	ON D.Market_Group_Id = MG.ID
	AND OD.Programme_Id = MG.Programme_Id
	LEFT OUTER JOIN OXO_Feature F
	ON D.Feature_Id = F.ID
	LEFT OUTER JOIN OXO_Programme_Pack PP
	ON D.Feature_Id = (PP.ID * -1)
	AND OD.Programme_Id = PP.Programme_Id
	WHERE PROCESS_UID = @p_process_UID
	AND ISNULL(H.Prev_Code, '') != ISNULL(H.Item_Code, '');

