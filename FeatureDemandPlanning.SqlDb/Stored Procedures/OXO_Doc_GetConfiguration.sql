CREATE PROCEDURE [dbo].[OXO_Doc_GetConfiguration] 
  @p_doc_id int
AS	
	SET NOCOUNT ON;
		
	DECLARE @_programme_Id INT
	
	SELECT Top 1 @_programme_Id = Programme_Id 
	FROM dbo.OXO_Doc 
	WHERE Id = @p_doc_id;
		
	-- This should return 4 resultsets	
	-- set 1 all bodies - multiple records	   	
	SELECT DISTINCT 
    Body_Id  AS Id,
    Programme_Id  AS ProgrammeId,  
    Shape  AS Shape,  
    Doors  AS Doors,  
    Wheelbase  AS Wheelbase,  
    1  AS Active,  
    'system'  AS Created_By,  
    GetDate()  AS Created_On,  
    'system'  AS Updated_By,  
    GetDate()  AS LastUpdated  
    FROM dbo.FN_Programme_Models_Get(@_programme_Id, @p_doc_id);
		
	-- set 2 all engines - multiple records	  
	SELECT DISTINCT
    Engine_Id AS Id,
    Programme_Id  AS ProgrammeId,  
    Size  AS Size,  
    Cylinder  AS Cylinder,  
    Turbo  AS Turbo,  
    Fuel_Type  AS FuelType,  
    [Power]  AS [Power],  
	Electrification AS Electrification,
    1  AS Active,  
   'system'  AS Created_By,  
    GetDate()  AS Created_On,  
    'system'  AS Updated_By,  
    GetDate()  AS LastUpdated  
    FROM dbo.FN_Programme_Models_Get(@_programme_Id, @p_doc_id)
    ORDER BY Size, Cylinder, Fuel_Type Desc, [Power] ; 	
	
	-- set 3 all transmissions - multiple records	  
	SELECT DISTINCT 
    Transmission_Id AS Id,
    Programme_Id  AS ProgrammeId,  
    Type  AS Type,  
    Drivetrain  AS Drivetrain,  
    1  AS Active,  
     'system'  AS Created_By,  
    GetDate()  AS Created_On,  
    'system'  AS Updated_By,  
    GetDate()  AS LastUpdated  
    FROM dbo.FN_Programme_Models_Get(@_programme_Id, @p_doc_id)
    ORDER BY Drivetrain, Type; 
			
    -- set 4 all trims - multiple records
	SELECT DISTINCT
    Trim_Id AS Id,
    Programme_Id  AS ProgrammeId,  
    Abbreviation AS Abbreviation,
    TrimName AS Name,  
    Level  AS Level,
    DPCK AS DPCK,  
    1  AS Active,  
     'system'  AS Created_By,  
    GetDate()  AS Created_On,  
    'system'  AS Updated_By,  
    GetDate()  AS LastUpdated  
    FROM dbo.FN_Programme_Models_Get(@_programme_Id, @p_doc_id)
    ORDER By Level;

