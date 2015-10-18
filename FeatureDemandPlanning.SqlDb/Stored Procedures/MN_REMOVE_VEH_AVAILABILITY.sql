CREATE PROC [dbo].[MN_REMOVE_VEH_AVAILABILITY]
@p_Veh     NVARCHAR(50),
@p_feat_Id INT
AS
BEGIN

  DECLARE @_count INT;
  DECLARE @_veh_id INT;
  
  SELECT @_veh_id = Id 
  FROM OXO_Vehicle 
  WHERE Name = @p_Veh;
 
  DELETE 
  FROM OXO_Vehicle_Feature_Applicability  
  WHERE Vehicle_Id = @_veh_id
  AND Feature_Id = @p_feat_Id;

END