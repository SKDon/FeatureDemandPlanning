/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
			   SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/* Fdp_Configuration */
PRINT 'Fdp_Configuration'

MERGE INTO Fdp_Configuration AS TARGET
USING (VALUES
	  (N'DefaultPageSize', N'5', N'The default size to use for any paged data tables', N'System.Int32')
	, (N'DTSPath', 'C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\DTExec.exe', N'The file system path to the 32 bit version of DTExec.exe (required for Excel processing)', N'System.String')
	, (N'FdpImportSSIS', N'C:\Source\SSIS\FeatureDemandPlanning.SSIS\FeatureDemandPlanning.SSIS\bin\FeatureDemandPlanning.ExcelImport.dtsx', N'The file system path to the SSIS package used to import volume data into FDP', N'System.String')
	, (N'FdpImportSSISConfig', N'C:\Source\SSIS\FeatureDemandPlanning.SSIS\FeatureDemandPlanning.SSIS\bin\FeatureDemandPlanning.ExcelImport.dtsConfig', N'The file system path to the SSIS config file used to import volume data into FDP','System.String')
	, (N'FdpUploadFilePath', N'C:\Users\bweston2\Documents\FDPUpload', N'The location where uploaded files are placed', N'System.String')
	, (N'NumberOfComparisonVehicles', N'5', N'The number of vehicles to use for comparison data', N'System.Int32')
	, (N'NumberOfTopMarkets', N'28', N'The number of markets to use for comparison data', N'System.Int32')
	, (N'ShowAllOXODocuments', N'0', N'Determines whether or not to show all OXO documents, regardless as to published state', N'System.Boolean')
	, (N'SkipFirstXRowsInImportFile', N'3', N'Specifies the number of rows to skip for FDP import files. Eliminates header information', N'System.Int32')
)
AS SOURCE (ConfigurationKey, Value, [Description], DataType) ON TARGET.ConfigurationKey = SOURCE.ConfigurationKey
WHEN MATCHED THEN

	-- Don't update the config value, as this may have been changed by the user
	UPDATE SET [Description] = SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new configuration rows
	INSERT (ConfigurationKey, Value, [Description], DataType)
	VALUES (ConfigurationKey, Value, [Description], DataType)

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete configuration rows that are no longer required
	DELETE;

/* Fdp_ImportErrorType */
PRINT 'Fdp_ImportErrorType'

MERGE INTO Fdp_ImportErrorType AS TARGET
USING (VALUES
	  (1, N'Missing Market', N'The import data does not correspond to a market within FDP', 1)
	, (2, N'Missing Feature', N'The import feature code does not exist within FDP', 4)
	, (3, N'Missing Derivative', N'The import data contains information for a vehicle derivative not found within FDP', 2)
	, (4, N'Missing Trim', N'The import data contains information for a trim level not found within FDP', 3)
)
AS SOURCE (FdpImportErrorTypeId, [Type], [Description], WorkflowOrder) ON TARGET.FdpImportErrorTypeId = SOURCE.FdpImportErrorTypeId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Type] = SOURCE.[Type]
		, [Description] = SOURCE.[Description]
		, WorkflowOrder = SOURCE.WorkflowOrder

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpImportErrorTypeId, [Type], [Description], WorkflowOrder)
	VALUES (FdpImportErrorTypeId, [Type], [Description], WorkflowOrder)

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_ImportStatus */
PRINT 'Fdp_ImportStatus'

MERGE INTO Fdp_ImportStatus AS TARGET
USING (VALUES
	  (0, N'NotSet',		N'No status has been set')
	, (1, N'Queued',		N'The import file has been queued for processing')
	, (2, N'Processing',	N'The import file is being processed')
	, (3, N'Processed',		N'The import file has been successfully processed')
	, (4, N'Error',			N'The import file has not been processed successfully')
	, (5, N'Cancelled',		N'The import has been cancelled and removed from the queue')
)
AS SOURCE (FdpImportStatusId, [Status], [Description]) ON TARGET.FdpImportStatusId = SOURCE.FdpImportStatusId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Status] = SOURCE.[Status]
		, [Description] = SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpImportStatusId, [Status], [Description])
	VALUES (FdpImportStatusId, [Status], [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_ImportType */
PRINT 'Fdp_ImportType'

MERGE INTO Fdp_ImportType AS TARGET
USING (VALUES
	  (0, N'NotSet', N'No type has been set')
	, (1, N'PPO', N'Pre-populated OXO containing take rate data for a specific programme and gateway')
)
AS SOURCE (FdpImportTypeId, [Type], [Description]) ON TARGET.FdpImportTypeId = SOURCE.FdpImportTypeId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Type] = SOURCE.[Type]
		, [Description] = SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpImportTypeId, [Type], [Description])
	VALUES (FdpImportTypeId, [Type], [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_PermissionObjectType */
PRINT 'Fdp_PermissionObjectType'

MERGE INTO Fdp_PermissionObjectType AS TARGET
USING (VALUES
	  (N'Adm-EngineCode', N'Engine code mapping administration')
	, (N'Adm-Market', N'Top market administration')
	, (N'Adm-Model', N'Model mapping administration')
	, (N'Adm-Users', N'User administration')
	, (N'Programme', N'The primary FDP programme information. Individual areas of the programme will be controlled by permissions on FdpPermissionOperation')
	, (N'Reports', N'Any available FDP reports')
)
AS SOURCE (FdpPermissionObjectType, [Description]) ON TARGET.FdpPermissionObjectType = SOURCE.FdpPermissionObjectType
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET [Description] = SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpPermissionObjectType, [Description])
	VALUES (FdpPermissionObjectType, [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_PermissionOperation */
PRINT 'Fdp_PermissionOperation'

MERGE INTO Fdp_PermissionOperation AS TARGET
USING (VALUES
	  (1,	N'Programme',		N'CanImport',				N'The user can import data from published OXOs')
	, (2,	N'Programme',		N'CanEdit',					N'The user can edit take rate data for the chosen derivatives')
	, (3,	N'Programme',		N'CanAccessMarketInput',	N'The user can access and update market feedback information')
	, (4,	N'Programme',		N'CanPublish',				N'The user can publish take rate information once complete')
	, (5,	N'Reports',			N'CanView',					N'The user can view FDP reports')
	, (6,	N'Adm-Market',		N'CanAccess',				N'The user has access to the market administration area')
	, (7,	N'Adm-Users',		N'CanAccess',				N'The user has access to the user administration area')
	, (8,	N'Adm-EngineCode',	N'CanAccess',				N'The user has access to the engine code administration area')
	, (9,	N'Adm-Model',		N'CanAccess',				N'The user has access to the model mapping administration area')
	, (10,	N'Programme',		N'CanAdd',					N'The user can add forecasts for selected carlines')
	, (11,	N'Programme',		N'CanView',					N'The user can view information for the specified programme')
)
AS SOURCE (FdpPermissionOperationId, FdpPermissionObjectType, Operation, [Description]) ON TARGET.FdpPermissionOperationId = SOURCE.FdpPermissionOperationId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  FdpPermissionObjectType	= SOURCE.FdpPermissionObjectType
		, Operation					= SOURCE.Operation
		, [Description]				= SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new rows
	INSERT (FdpPermissionOperationId, FdpPermissionObjectType, Operation, [Description])
	VALUES (FdpPermissionOperationId, FdpPermissionObjectType, Operation, [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete rows that are no longer required
	DELETE;

/* Fdp_PermissionType */
PRINT 'Fdp_PermissionType'

MERGE INTO Fdp_PermissionType AS TARGET
USING (VALUES
	  (1, N'VIEW', N'The user can view take rate information for the specified programme')
	, (2, N'EDIT', N'The user can edit take rate information for the specified programme')
)
AS SOURCE (FdpPermissionTypeId, Permission, [Description]) ON TARGET.FdpPermissionTypeId = SOURCE.FdpPermissionTypeId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  Permission	= SOURCE.Permission
		, [Description] = SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpPermissionTypeId, Permission, [Description])
	VALUES (FdpPermissionTypeId, Permission, [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_SpecialFeatureType */
PRINT 'Fdp_SpecialFeatureType'

MERGE INTO Fdp_SpecialFeatureType AS TARGET
USING (VALUES
	  (1, N'VolumeByDerivative',         N'Volume for Derivative (Full Year)')
	, (2, N'VolumeByMarket',             N'Volume for Market (Full Year)')
	, (3, N'VolumeByDerivativeHalfYear', N'Volume for Derivative (Half Year)')
	, (4, N'VolumeByMarketHalfYear',     N'Volume for Market (Half Year)')
)
AS SOURCE (FdpSpecialFeatureTypeId, SpecialFeatureType, [Description]) ON TARGET.FdpSpecialFeatureTypeId = SOURCE.FdpSpecialFeatureTypeId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  SpecialFeatureType	= SOURCE.SpecialFeatureType
		, [Description]			= SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpSpecialFeatureTypeId, SpecialFeatureType, [Description])
	VALUES (FdpSpecialFeatureTypeId, SpecialFeatureType, [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_TakeRateStatus */
PRINT 'Fdp_TakeRateStatus'

MERGE INTO Fdp_TakeRateStatus AS TARGET
USING (VALUES
	  (1, N'Work in Progress',			N'Work in Progress',																	1,	1)
	, (2, N'Market Review',             N'Take rate file has been sent to markets for further review and feedback',				1,	2)
	, (3, N'Published',                 N'Take rate file has been published and is locked for further modification',			1,	6)
	, (4, N'Challenge Market Inputs',   N'Based on feedback from markets, the supplied take rate data is being challenged',		1,	3)
	, (5, N'Pending PMC Approval',      N'The take rate file is pending PMC approval prior to being published',					1,	4)
	, (6, N'Approved',                  N'The take rate file has been approved for publishing',									1,	5)
)
AS SOURCE (FdpTakeRateStatusId, [Status], [Description], IsActive, WorkflowStepId) ON TARGET.FdpTakeRateStatusId = SOURCE.FdpTakeRateStatusId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Status]			= SOURCE.[Status]
		, [Description]		= SOURCE.[Description]
		, IsActive			= SOURCE.IsActive
		, WorkflowStepId	= SOURCE.WorkflowStepId

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpTakeRateStatusId, [Status], [Description], IsActive, WorkflowStepId)
	VALUES (FdpTakeRateStatusId, [Status], [Description], IsActive, WorkflowStepId)

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;