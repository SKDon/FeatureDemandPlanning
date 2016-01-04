CREATE PROCEDURE [dbo].[Fdp_Model_GetMany]   
   @ProgrammeId INT,
   @Gateway		NVARCHAR(100) = NULL,
   @DocumentId	INT
AS
	IF @Gateway IS NULL
		SELECT @Gateway = Gateway FROM OXO_Doc WHERE Id = @DocumentId;

   SELECT 
    DISTINCT 
   	DisplayOrder,	
    VehicleName,
    VehicleAKA,
    ModelYear,    
    DisplayFormat,        
    Name,       
	NameWithBR,
	'O' + CAST(M.Id AS NVARCHAR(10)) AS StringIdentifier,   
    M.Id  AS Id,
    NULL AS FdpModelId,
	M.BMC,
    M.Programme_Id  AS ProgrammeId,  
    M.Body_Id  AS BodyId,  
    M.Engine_Id  AS EngineId,
    M.Transmission_Id  AS TransmissionId,  
    M.Trim_Id  AS TrimId, 
    NULL AS FdpTrimId,
	M.DPCK,
	M.[Level] AS TrimLevel,
    M.CoA, 
    M.Active,  
    M.Created_By  AS CreatedBy,  
    M.Created_On  AS CreatedOn,  
    M.Updated_By  AS UpdatedBy,  
    M.Last_Updated  AS LastUpdated,
    Shape,
    M.KD             
    FROM dbo.FN_Programme_Models_Get(@ProgrammeId, @DocumentId)  M
    
    UNION
    
    SELECT 
		  M.DisplayOrder
		, M.VehicleName
		, M.VehicleAKA
		, M.ModelYear    
		, M.DisplayFormat        
		, M.Name       
		, M.NameWithBR   
		, 'F' + CAST(M.FdpModelId AS NVARCHAR(10)) AS StringIdentifier
		, NULL			AS Id
		, M.FdpModelId
		, M.BMC
		, M.ProgrammeId  
		, M.BodyId
		, M.EngineId
		, M.TransmissionId  
		, NULL			AS TrimId
		, M.FdpTrimId
		, M.DPCK
		, M.[Level]		AS TrimLevel
		, M.CoA
		, M.IsActive	AS Active  
		, M.CreatedBy 
		, M.CreatedOn  
		, M.UpdatedBy 
		, M.UpdatedOn AS LastUpdated
		, Shape
		, M.KD
    FROM
    Fdp_Model_VW AS M
    WHERE
    ProgrammeId = @ProgrammeId
    AND
    Gateway = @Gateway;