CREATE PROCEDURE [dbo].[OXO_AvailableModel_MarketGroup]   
   @p_prog_id int,
   @p_doc_id int,
   @p_group_id int
AS
	
	
	WITH Set_A AS
	(
		SELECT OD.Model_Id 
		FROM OXO_ITEM_DATA_MBM OD WITH(NOLOCK)
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_Group_Id = @p_group_id
		AND OD.OXO_Code = 'Y'	
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
    Id,
    Programme_Id AS ProgrammeId,  
    Body_Id AS BodyId,  
    Engine_Id AS EngineId,
    Transmission_Id AS TransmissionId,  
    Trim_Id AS TrimId,
    CoA, 
    Shape, 
    Active,  
    Created_By AS CreatedBy,  
    Created_On AS CreatedOn,  
    Updated_By AS UpdatedBy,  
    Last_Updated AS LastUpdated,
    CASE WHEN A.Model_Id IS NULL THEN 0
    ELSE 1
    END AS Available                 
    FROM dbo.FN_Programme_Models_Get(@p_prog_id, @p_doc_id)  M        
	LEFT OUTER JOIN SET_A A
	ON M.ID = A.Model_Id  
    ORDER BY Shape, 1;

