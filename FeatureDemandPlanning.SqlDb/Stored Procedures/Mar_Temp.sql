
CREATE PROCEDURE [dbo].[Mar_Temp] 
  @p_Market_Id int,
  @p_Country varchar(50)
AS
	
  DECLARE @_country_id  int
  
  SELECT @_country_id = id FROM OXO_Master_Country WHERE Name = @p_Country;
  
  INSERT INTO OXO_Master_Market_Country_Link (Market_Id, Country_Id)
      VALUES (@p_Market_Id, @_country_id);	


