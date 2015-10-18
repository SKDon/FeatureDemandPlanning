CREATE PROCEDURE [Fdp_OxoDoc_Save]
	  @FdpVolumeHeaderId INT
	, @OxoDocId INT
	, @CDSID NVARCHAR(16)
AS

	SET NOCOUNT ON;

	IF NOT EXISTS(  SELECT TOP 1 1 FROM FDP_OXODoc 
					WHERE 
					OXODocId = @OxoDocId 
					AND 
					FdpVolumeHeaderId = @FdpVolumeHeaderId)
	BEGIN
		INSERT INTO Fdp_OXODoc
		(
			  OXODocId
			, FdpVolumeHeaderId
			, CreatedBy
		)
		VALUES
		(
			  @OxoDocId
			, @FdpVolumeHeaderId
			, @CDSID
		)
	END;

	SELECT 
		  FdpOxoDocId
		, CreatedOn
		, CreatedBy
		, FdpVolumeHeaderId
		, OXODocId
	FROM
	FDP_OXODoc
	WHERE 
	OXODocId = @OxoDocId 
	AND 
	FdpVolumeHeaderId = @FdpVolumeHeaderId;
