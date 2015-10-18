CREATE PROCEDURE [dbo].[OXO_Model_Get] 
  @p_Id int
AS

SELECT     
    VehicleName,
    VehicleAKA,
    ModelYear,        
    Name,
    Id,
    Programme_Id  AS ProgrammeId,  
    Body_Id  AS BodyId,  
    Engine_Id  AS EngineId,
    Transmission_Id  AS TransmissionId,  
    Trim_Id  AS TrimId,
    BMC AS BMC,
    CoA AS CoA,  
    KD AS KD,
    Active  AS Active,  
    Created_By  AS CreatedBy,  
    Created_On  AS CreatedOn,  
    Updated_By  AS UpdatedBy,  
    Last_Updated  AS LastUpdated  
    FROM OXO_Models_VW
	WHERE Id = @p_Id;

