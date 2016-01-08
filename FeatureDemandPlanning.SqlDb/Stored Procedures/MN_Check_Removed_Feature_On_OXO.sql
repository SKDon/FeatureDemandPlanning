CREATE Procedure [dbo].[MN_Check_Removed_Feature_On_OXO]
AS 
SELECT P.VehicleName, P.ModelYear, F.Feat_Code, F.OA_Code, F.Description
FROM OXO_Programme_Feature_Link PL
INNER JOIN OXO_Programme_VW P
ON PL.Programme_Id = P.Id 
INNER JOIN OXO_Feature_Ext F
ON PL.Feature_Id = F.Id
WHERE 
NOT EXISTS
(SELECT 1 
 FROM OXO_Vehicle_Feature_Applicability V
 WHERE V.Vehicle_Id = P.VehicleId
 AND V.Feature_id = PL.Feature_Id)