CREATE PROCEDURE [dbo].[Fdp_MarketGroup_Get] 
	  @MarketGroupId		INT
	, @FdpVolumeHeaderId	INT
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId	INT;
	DECLARE @Gateway		NVARCHAR(100);
	DECLARE @DocumentId		INT;
	DECLARE @IsArchived		BIT;
	
	SELECT TOP 1 
		  @ProgrammeId	= D.Programme_Id
		, @Gateway		= D.Gateway
		, @DocumentId	= D.Id
		, @IsArchived	= D.Archived
	FROM
	Fdp_VolumeHeader	AS H
	JOIN OXO_Doc		AS D	ON	H.DocumentId = D.Id
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId;
		
	IF ISNULL(@IsArchived, 0) = 0	
	BEGIN
	
		SELECT 
		    'Programme'			AS Type
		  , Market_Group_Id		AS Id
		  , Programme_Id		AS ProgrammeId
		  , Market_Group_Name	AS GroupName  
		  , NULL  AS ExtraInfo   
		  , CAST(1 AS BIT)		AS Active     
		FROM 
		OXO_Programme_MarketGroupMarket_VW AS M
		WHERE 
		M.Programme_Id = @ProgrammeId
		AND   
		M.Market_Group_Id = @MarketGroupId
		ORDER BY 
		Display_Order;
		
	END
	ELSE
	BEGIN
	
		SELECT
		    'Programme'			AS Type
		  , Market_Group_Id		AS Id
		  , Programme_Id		AS ProgrammeId
		  , Market_Group_Name	AS GroupName  
		  , NULL  AS ExtraInfo   
		  , CAST(1 AS BIT)		AS Active     
		FROM 
		OXO_Archived_Programme_MarketGroupMarket_VW AS M
		WHERE 
		M.Programme_Id = @ProgrammeId
		AND   
		M.Market_Group_Id = @MarketGroupId
		ORDER BY 
		Display_Order;
		
	END

	SELECT 
	    M.Market_Id		AS Id
	  , M.Market_Name	AS Name 
	  , ''				AS WHD
	  , ''				AS PARX  
	  , ''				AS PARL 
	  , ''				AS Territory 
	  , CAST(1 AS BIT)  AS Active
	FROM 
	OXO_Programme_MarketGroupMarket_VW AS M		
	WHERE 
	Programme_Id = @ProgrammeId
	AND   
	Market_Group_Id = @MarketGroupId;