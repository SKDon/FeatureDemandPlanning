CREATE PROCEDURE [OXO_Programme_MarketGroup_Get] 
  @p_Id int,
  @p_prog_id int,
  @p_doc_id int = 0,
  @p_deep_get BIT = 0  
AS
	
	DECLARE @p_archived BIT;
	  	
	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;
		
	IF ISNULL(@p_archived,0) = 0	
	BEGIN
		SELECT 
		  'Programme' AS Type, 
		  Market_Group_Id  AS Id,
		  Programme_Id AS ProgrammeId,
		  Market_Group_Name  AS GroupName,  
		  null  AS ExtraInfo,   
		  1  AS Active     
		FROM OXO_Programme_MarketGroupMarket_VW
		WHERE Programme_Id = @p_prog_id
		AND   Market_Group_Id = @p_Id
		ORDER BY Display_Order;
		
		IF @p_deep_get = 1
		  SELECT 
			  Market_Id  AS Id,
			  Market_Name  AS Name,  
			  '' AS WHD,
			  ''  AS PARX,  
			  ''  AS PARL,  
			  ''  AS Territory,  
			  1  AS Active
			FROM OXO_Programme_MarketGroupMarket_VW			
			WHERE Programme_Id = @p_prog_id
			AND   Market_Group_Id = @p_Id;
	END
	ELSE
	BEGIN
		SELECT 
		  'Programme' AS Type, 
		  Market_Group_Id  AS Id,
		  Programme_Id AS ProgrammeId,
		  Market_Group_Name  AS GroupName,  
		  null  AS ExtraInfo,   
		  1  AS Active     
		FROM OXO_Archived_Programme_MarketGroupMarket_VW
		WHERE Programme_Id = @p_prog_id
		AND   Doc_Id = @p_doc_id
		AND   Market_Group_Id = @p_Id
		ORDER BY Display_Order;
		
		IF @p_deep_get = 1
		  SELECT 
			  Market_Id  AS Id,
			  Market_Name  AS Name,  
			  '' AS WHD,
			  ''  AS PARX,  
			  ''  AS PARL,  
			  ''  AS Territory,  
			  1  AS Active
			FROM OXO_Archived_Programme_MarketGroupMarket_VW
			WHERE Programme_Id = @p_prog_id
			AND   Doc_Id = @p_doc_id
			AND  Market_Group_Id = @p_Id;
	END

