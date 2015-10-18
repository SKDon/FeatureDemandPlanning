CREATE VIEW [JMFD_Feature_VW]
AS
SELECT   F.Id
       , F.Feat_Code
       , F.OA_Code
       , F.EFG_Code
       , F.OXO_Grp
       , G.Group_Name
       , G.Sub_Group_Name
       , F.[Description]
       , F.Long_Desc
       , BJ.Brand_Desc AS Jaguar_Desc
       , LR.Brand_Desc AS LR_Desc
       , ISNULL(G.Display_Order, 10000) AS Display_Order
FROM OXO_IMP_Feature F
LEFT JOIN OXO_IMP_OXO_Group		G	ON	F.OXO_Grp		= G.Id 
LEFT JOIN OXO_IMP_Brand_Desc	BJ	ON	F.Feat_Code		= BJ.Feat_Code
									AND BJ.Brand		= 'J'
LEFT JOIN OXO_IMP_Brand_Desc	LR	ON F.Feat_Code		= LR.Feat_Code
									AND LR.Brand		= 'LR'

