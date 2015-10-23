CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Save]
	  @ImportTrim	NVARCHAR(200)
	, @ProgrammeId	INT
	, @TrimId		INT
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_TrimMapping 
				  WHERE 
				  ImportTrim = @ImportTrim
				  AND
				  ProgrammeId = @ProgrammeId
				  AND
				  TrimId = @TrimId)
				  
		INSERT INTO Fdp_TrimMapping
		(
			  ImportTrim
			, ProgrammeId
			, TrimId
		)
		VALUES
		(
			  @ImportTrim
			, @ProgrammeId
			, @TrimId
		);
		
	SELECT 
		  FdpTrimMappingId
		, ImportTrim
		, ProgrammeId
		, TrimId
		
	  FROM Fdp_TrimMapping 
	  WHERE 
	  ImportTrim = @ImportTrim
	  AND
	  ProgrammeId = @ProgrammeId
	  AND
	  TrimId = @TrimId;