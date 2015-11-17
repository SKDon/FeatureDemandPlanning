CREATE PROCEDURE dbo.Fdp_News_Save
	  @FdpNewsId	INT = NULL
	, @CDSId		NVARCHAR(16)
	, @Headline		NVARCHAR(200)
	, @Body			NVARCHAR(MAX)
	, @IsActive		BIT = 1
AS
	IF @FdpNewsId IS NULL
	BEGIN
		INSERT INTO Fdp_News
		(
			  CreatedBy
			, Headline
			, Body
		)
		VALUES
		(
			  @CDSId
			, @Headline
			, @Body
		);
	END
	ELSE
	BEGIN
		UPDATE Fdp_News SET 
			  Headline	= @Headline
			, Body		= @Body
			, IsActive	= @IsActive
		WHERE
		FdpNewsId = @FdpNewsId;
	END;