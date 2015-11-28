CREATE PROCEDURE [dbo].[Fdp_Import_Process_Old]
	@ImportQueueId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SqlQuery AS VARCHAR(1000);
	DECLARE @DTSPath AS VARCHAR(1000);
	DECLARE @PackagePath AS VARCHAR(1000);
	DECLARE @PackageConfig AS VARCHAR(1000);
	
	SELECT @DTSPath = Value FROM Fdp_Configuration WHERE ConfigurationKey = 'DTSPath';
	SELECT @PackagePath = Value FROM Fdp_Configuration WHERE ConfigurationKey = 'FdpImportSSIS';
	SELECT @PackageConfig = Value FROM Fdp_Configuration WHERE ConfigurationKey = 'FdpImportSSISConfig';
	
	SET @SqlQuery = '@"' + @DTSPath + '" /FILE "' + @PackagePath + '" /CONFIGFILE "' + @PackageConfig + '"';
	
	-- If the import queue id is specified, pass it as a parameter.
	-- Otherwise the whole queue is processed
	IF @ImportQueueId IS NOT NULL
	BEGIN
		SET @SQLQuery = @SQLQuery + ' /SET \Package.Variables[ImportQueueId].Value;'+ CAST(@ImportQueueId AS VARCHAR(10));
	END
	
	PRINT @SqlQuery
	
	EXEC xp_cmdshell @SQLQuery;
END

