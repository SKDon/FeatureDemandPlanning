CREATE  PROCEDURE [dbo].[OXO_OXODoc_New] 
   @p_Programme_Id int,  
   @p_Gateway    nvarchar(50),
   @p_Version_Id  numeric(10,1),
   @p_Status   nvarchar(50),
   @p_Created_By  nvarchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  nvarchar(8), 
   @p_Last_Updated  datetime, 
   @p_Id INT OUTPUT
AS
	
  DECLARE @_make NVARCHAR(500);
  DECLARE @_veh_id int;
  
  SELECT @_make = VehicleMake,
         @_veh_id = VehicleId 
  FROM OXO_Programme_VW WHERE Id = @p_Programme_Id;
  		
  INSERT INTO dbo.OXO_Doc
  (
    Programme_Id,
    Gateway,
    Version_Id,
    Status,
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Programme_Id,  
    @p_Gateway,
    @p_Version_Id,
    @p_Status,
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
  );

  SET @p_Id = SCOPE_IDENTITY();

  -- need to do a whole load of copying here
  -- first copy from Master_MarketGroup to Programme_MarketGroup
  IF NOT EXISTS(SELECT * FROM OXO_Programme_MarketGroup WHERE Programme_Id = @p_Programme_Id)
  BEGIN
	  INSERT INTO OXO_Programme_MarketGroup (Programme_Id, Group_Name,
											 Extra_Info, Display_Order)
	  SELECT DISTINCT @p_Programme_Id, Group_Name, Extra_Info, Display_Order 
	  FROM OXO_Master_MarketGroup ORDER BY Display_Order;
  END
  
  -- next copy from Master_MarketGroup_Market_Link to Programme_MarketGroup_Market_Link
  IF NOT EXISTS(SELECT * FROM OXO_Programme_MarketGroup_Market_Link WHERE Programme_Id = @p_Programme_Id)
  BEGIN
	  INSERT INTO OXO_Programme_MarketGroup_Market_Link 
				  (Programme_Id, Market_Group_Id, Country_Id, 
				   Sub_Region, CDSID)  
	  SELECT DISTINCT @p_Programme_Id , P.Id, M.Market_Id, M.Sub_Region, @p_Created_By 
	  FROM OXO_Market_Group_Market_VW M
	  INNER JOIN OXO_Programme_MarketGroup P
	  ON P.Group_Name = M.Market_Group_Name  
	  WHERE P.Programme_Id = @p_Programme_Id;
  END
  
  --IF NOT EXISTS(SELECT * FROM OXO_Programme_Feature_Link WHERE Programme_Id = @p_Programme_Id)
  --BEGIN
	  -- next copy from OXO_Vehicle_Feature_Link to OXO_Programme_Fetaure_Link.
--	  INSERT INTO OXO_Programme_Feature_Link  
--	  SELECT @p_Programme_Id, Feature_Id, @p_Created_By, null, 0 FROM OXO_Vehicle_Feature_Applicability WHERE Vehicle_Id = @_veh_id;
 -- END

