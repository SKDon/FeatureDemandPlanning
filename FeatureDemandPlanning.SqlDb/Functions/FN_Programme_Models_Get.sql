CREATE FUNCTION [dbo].[FN_Programme_Models_Get]( 
	@p_prog_id INT,
    @p_doc_id INT
) 
RETURNS @result TABLE (
	DisplayOrder INT,
	VehicleName nvarchar(500),
	VehicleAKA nvarchar(500),
	ModelYear nvarchar(500),
	DisplayFormat nvarchar(500),
	Name nvarchar(500),
	NameWithBR nvarchar(500),
    Shape nvarchar(50),
    Doors nvarchar(50),
    Wheelbase nvarchar(50),
	Size nvarchar(50),
	Cylinder nvarchar(50),
	Turbo nvarchar(50),
	Fuel_Type nvarchar(50),
	Power nvarchar(50),
	Electrification nvarchar(50),
	Type nvarchar(50),
	Drivetrain nvarchar(50),
	TrimName nvarchar(500),
	Abbreviation nvarchar(50),
	Level nvarchar(500),    
	Id int,
	Programme_Id int,
	Body_Id int,
	Engine_Id int,
	Transmission_Id int ,
	Trim_Id int,
	Active bit,
	Created_By nvarchar(8) ,
	Created_On datetime ,
	Updated_By nvarchar(8) ,
	Last_Updated datetime ,
	BMC nvarchar(10) ,
	CoA nvarchar(10),
	DPCK nvarchar(10),
	Make nvarchar(100),
	KD bit
)  
AS
BEGIN

  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;

  IF (ISNULL(@p_archived,0) = 0) 
  
  	INSERT INTO @result
	    SELECT DisplayOrder,
				VehicleName,
				VehicleAKA,
				ModelYear,
				DisplayFormat,
				Name,
				NameWithBR,
				Shape,
				Doors,
				Wheelbase,
				Size,
				Cylinder,
				Turbo,
				Fuel_Type,
				Power,
				Electrification,
				Type,
				Drivetrain,
				TrimName,
				Abbreviation,
				Level,				
	           Id, Programme_Id, Body_Id, Engine_Id, 
	           Transmission_Id, Trim_Id, Active, 
	           Created_By, Created_On, Updated_By, 
	           Last_Updated, BMC, CoA, DPCK,
	           Make, KD
	FROM OXO_Models_VW
	WHERE Programme_Id = @p_prog_id
	AND  Active = 1;
  
  ELSE
  
	INSERT INTO @result
	SELECT DisplayOrder,
			VehicleName,
			VehicleAKA,
			ModelYear,
			DisplayFormat,
			Name,
			NameWithBR,
			Shape,
			Doors,
			Wheelbase,
			Size,
			Cylinder,
			Turbo,
			Fuel_Type,
			Power,
			Electrification,
			Type,
			Drivetrain,
			TrimName,
			Abbreviation,
			Level,	
			 Id, Programme_Id, Body_Id, Engine_Id, 
	           Transmission_Id, Trim_Id, Active, 
	           Created_By, Created_On, Updated_By, 
	           Last_Updated, BMC, CoA, DPCK, Make, KD
	FROM OXO_Archived_Models_VW
	WHERE Programme_Id = @p_prog_id
	AND doc_id = @p_doc_id;
	
	
   RETURN;
	
END
