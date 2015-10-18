CREATE FUNCTION [FN_Programme_Markets_Get]( 
	@p_prog_id INT,
    @p_doc_id INT
) 
RETURNS @result TABLE (
	Name nvarchar(500),
	AKA nvarchar(500),
	Model_Year nvarchar(500),
	Programme_Id int,
	Market_Group_Id int,
	Market_Group_Name nvarchar(500),
	Make nvarchar(500),
	Display_Order int,
	Market_Id int,
	Market_Name nvarchar(500),
	PAR nvarchar(500),
	WHD nvarchar(500),
	SubRegion nvarchar(500),
	SubRegionOrder int 
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
  	SELECT Name, AKA, Model_Year, Programme_Id,
	       Market_Group_Id, Market_Group_Name,
		   Make, Display_Order, Market_Id, Market_Name, 
		   PAR, WHD, SubRegion, SubRegionOrder  	
	FROM OXO_Programme_MarketGroupMarket_VW    
	WHERE Programme_Id = @p_prog_id;
  
  ELSE
  
	INSERT INTO @result
	SELECT Name, AKA, Model_Year, Programme_Id,
	       Market_Group_Id, Market_Group_Name,
		   Make, Display_Order, Market_Id, Market_Name, 
		   PAR, WHD, SubRegion, SubRegionOrder  	
	FROM OXO_Archived_Programme_MarketGroupMarket_VW    
	WHERE Programme_Id = @p_prog_id
	AND doc_id = @p_doc_id;
	
	
   RETURN;
	
END
