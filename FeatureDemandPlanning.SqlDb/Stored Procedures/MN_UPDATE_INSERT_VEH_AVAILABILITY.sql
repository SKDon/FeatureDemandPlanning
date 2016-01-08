CREATE PROC [dbo].[MN_UPDATE_INSERT_VEH_AVAILABILITY]
@p_Veh     NVARCHAR(50),
@p_feat_Id INT
AS
BEGIN

  DECLARE @_count INT;
  DECLARE @_veh_id INT;
  
  SELECT @_veh_id = Id 
  FROM OXO_Vehicle 
  WHERE Name = @p_Veh;
  
  SELECT @_count = COUNT(*) 
  FROM OXO_Vehicle_Feature_Applicability 
  WHERE Vehicle_Id = @_Veh_Id
  AND Feature_id = @p_feat_Id;
  
  IF @_count = 0
  BEGIN
    INSERT INTO OXO_Vehicle_Feature_Applicability  (Vehicle_Id, Feature_id, Created_By, Created_On)
	VALUES (@_Veh_Id, @p_feat_Id, 'SYSTEM', GETDATE());   
  END	

  
END