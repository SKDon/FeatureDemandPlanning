

CREATE VIEW [dbo].[JMFD]
AS

SELECT 
	F.Id,
    F.Feat_Code,
    F.OA_Code,
	F.Description,
	F.Long_Desc,
	F.VISTA_Visibility,	
	F.EFG_Code,
	ISNULL(E.EFG_Desc, 'UNKNOWN') AS EFG_Desc,
	ISNULL(O.Group_Name, 'UNKNOWN') AS Feature_Group,
	O.Sub_Group_Name AS Feature_Sub_Group,
	ISNULL(C.Group_Name, 'UNKNOWN') AS Config_Group,
	ISNULL(C.Sub_Group_Name, 'UNKNOWN') AS Config_Sub_Group,
	ISNULL(J.Brand_Desc, F.Description) AS Jaguar_Desc,
	ISNULL(L.Brand_Desc, F.Description) AS LandRover_Desc,	
	dbo.FN_OXO_FEAT_APPLICABILITY(F.Id) AS Applicability
	      
FROM OXO_IMP_Feature F
LEFT OUTER JOIN OXO_IMP_EFG E
ON F.EFG_Code = E.EFG_Code
LEFT OUTER JOIN OXO_IMP_OXO_Group O
ON F.OXO_Grp = O.Id
LEFT OUTER JOIN OXO_IMP_Config_Group C
ON F.Config_Grp = C.Id
LEFT OUTER JOIN OXO_IMP_Brand_Desc J
ON F.Feat_Code = J.Feat_Code
AND J.Brand = 'J'
LEFT OUTER JOIN OXO_IMP_Brand_Desc L
ON F.Feat_Code = L.Feat_Code
AND L.Brand = 'LR'


