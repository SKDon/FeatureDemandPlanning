CREATE PROCEDURE [dbo].[OXO_AvailableModel_Market]   
   @p_prog_id int,
   @p_doc_id int,
   @p_Market_id int
AS
	
	
	WITH Set_A AS
	(
		SELECT OD.Model_Id 
		FROM OXO_ITEM_DATA_MBM OD WITH(NOLOCK)
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.OXO_Code = 'Y'	
		AND OD.Market_Id = @p_Market_id
		AND Active = 1
	)	
   SELECT 
    DISTINCT 
   	DisplayOrder,	
    VehicleName,
    VehicleAKA,
    ModelYear,    
    DisplayFormat,        
    Name,       
	NameWithBR,   
    M.Id  AS Id,
    M.Programme_Id  AS ProgrammeId,  
    M.Body_Id  AS BodyId,  
    M.Engine_Id  AS EngineId,
    M.Transmission_Id  AS TransmissionId,  
    M.Trim_Id  AS TrimId, 
    M.CoA AS CoA, 
    M.Active  AS Active,  
    M.Created_By  AS CreatedBy,  
    M.Created_On  AS CreatedOn,  
    M.Updated_By  AS UpdatedBy,  
    M.Last_Updated  AS LastUpdated,
    Shape,
    M.KD,
    CASE WHEN A.Model_Id IS NULL THEN 0
    ELSE 1
    END AS Available
                 
    FROM dbo.FN_Programme_Models_Get(@p_prog_id, @p_doc_id)  M
    LEFT OUTER JOIN SET_A A
	ON M.ID = A.Model_Id
    ORDER BY Shape, 1;

