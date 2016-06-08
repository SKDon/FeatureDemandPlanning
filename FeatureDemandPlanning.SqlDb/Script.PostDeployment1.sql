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
	, (N'FdpUploadFilePath', N'K:\Data\wwwroot\Upload\FDP', N'The location where uploaded files are placed', N'System.String')
	, (N'NumberOfComparisonVehicles', N'5', N'The number of vehicles to use for comparison data', N'System.Int32')
	, (N'NumberOfTopMarkets', N'28', N'The number of markets to use for comparison data', N'System.Int32')
	, (N'ShowAllOXODocuments', N'1', N'Determines whether or not to show all OXO documents, regardless as to published state', N'System.Boolean')
	, (N'SkipFirstXRowsInImportFile', N'3', N'Specifies the number of rows to skip for FDP import files. Eliminates header information', N'System.Int32')
	, (N'ReprocessImportAfterHandleError', N'1', N'Whether to reprocess the entire dataset each time an error is handled in the worktray', N'System.Boolean')
	, (N'FlagOrphanedImportDataAsError', N'0', N'Whether to flag import data that cannot be mapped to an OXO derivative / trim level or feature as an error', N'System.Boolean')
	, (N'TakeRateDataPageSize', N'-1', N'The page size to use for models when showing take rate files', N'System.Int32')
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
	  (1, N'Market', N'The import data does not correspond to a market within FDP', 1)
	, (2, N'Feature', N'The import feature code does not exist within FDP', 4)
	, (3, N'Brochure Model Code', N'The import data contains information for a vehicle Brochure Model Code not found within FDP', 2)
	, (4, N'Trim', N'The import data contains information for a trim level not found within FDP', 3)
	, (201, N'No Feature Code', N'No feature code is defined for OXO feature', 1)
	, (202, N'No Historic Feature', N'No historic feature maps to OXO feature', 2)
	, (203, N'No OXO Feature', N'No OXO feature maps to historic feature', 3)
	, (204, N'No Special Feature', N'No special feature mapping for Brochure Model Code', 0)
	, (301, N'No Brochure Model Code', N'No Brochure Model Code is defined for OXO Brochure Model Code', 1)
	, (302, N'No Historic Brochure Model Code', N'No historic Brochure Model Code maps to OXO Brochure Model Code', 2)
	, (303, N'No OXO Brochure Model Code', N'No OXO Brochure Model Code maps to historic Brochure Model Code', 3)
	, (401, N'No DPCK', N'No DPCK code is defined for OXO trim level', 1)
	, (402, N'No Historic Trim', N'No historic trim level maps to OXO trim level', 2)
	, (403, N'No OXO Trim', N'No OXO trim level maps to historic trim level', 3)
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
	, (2, N'Market Review',             N'Take rate file has been sent to markets for further review and feedback',				0,	2)
	, (3, N'Published',                 N'Take rate file has been published and is locked for further modification',			1,	6)
	, (4, N'Challenge Market Inputs',   N'Based on feedback from markets, the supplied take rate data is being challenged',		0,	3)
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

/* Fdp_ValidationRule */
PRINT 'Fdp_ValidationRule'

MERGE INTO Fdp_ValidationRule AS TARGET
USING (VALUES
	  (1, N'TakeRateOutOfRange', N'Take rate above 100% and below 0% is not allowed', 1, 1, N'dbo.Fdp_Validation_TakeRateOutOfRange')
	, (2, N'VolumeForFeatureGreaterThanModel', N'Volume for a feature cannot exceed the volume for a model', 1, 2, N'dbo.Fdp_Validation_VolumeForFeatureGreaterThanModel')
	, (3, N'VolumeForModelsGreaterThanMarket', N'Total volumes for models at a market level cannot exceed the total volume for the market',	1, 3, N'dbo.Fdp_Validation_VolumeForModelGreaterThanMarket')
	, (4, N'TotalTakeRateForModelsOutOfRange', N'% Take for each model at a market level cannot exceed 100%', 1, 4, N'dbo.Fdp_Validation_TotalTakeRateForModelsOutOfRange')
	, (5, N'StandardFeaturesShouldBy100Percent', N'Take rate for standard features should be 100%', 1, 6, N'dbo.Fdp_Validation_StandardFeatures100Percent')
	, (6, N'TakeRateForPackFeaturesShouldBeEquivalent', N'Take rate for all features as part of packs should be equivalent', 1, 8, N'dbo.Fdp_Validation_TakeRateForPackFeaturesShouldBeEquivalent')
	, (7, N'TakeRateForEFGShouldEqual100Percent', N'EFG (Exclusive feature group). All features in a group must add up to 100% (or less if information is incomplete)', 1, 5, N'dbo.Fdp_Validation_TakeRateForEFGShouldEqual100Percent')
	, (8, N'NonApplicableFeaturesShouldBe0Percent', N'Take rate for non-applicable features should be 0%', 1, 7, N'dbo.Fdp_Validation_NonApplicableFeatures0Percent')
	, (9, N'TakeRateForEfgShouldbeLessThanOrEqualTo100Percent', N'For exclusive feature groups not containing a standard feature, the take rate for features should be 100 % or less', 1, 9, N'')
	, (10, N'OnlyOneFeatureInEfg', N'Only one feature in an exclusive feature group can have a take rate', 1, 10, N'')
	, (11, N'NonCodedFeatureShouldNotHaveTakeRate', N'An uncoded feature should not have take rate data', 1, 11, N'')
	, (12, N'OptionalPackFeaturesShouldBeGreaterThanOrEqualToPack', N'Take rate for optional pack features should be greater than or equal to pack take rate', 1, 12, N'')
)
AS SOURCE (FdpValidationRuleId, [Rule], [Description], IsActive, ValidationOrder, StoredProcedureName) ON TARGET.FdpValidationRuleId = SOURCE.FdpValidationRuleId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Rule]			= SOURCE.[Rule]
		, [Description]		= SOURCE.[Description]
		, IsActive			= SOURCE.IsActive
		, ValidationOrder	= SOURCE.ValidationOrder
		, StoredProcedureName = SOURCE.StoredProcedureName

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpValidationRuleId, [Rule], [Description], IsActive, ValidationOrder, StoredProcedureName)
	VALUES (FdpValidationRuleId, [Rule], [Description], IsActive, ValidationOrder, StoredProcedureName)

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_UserRole */
PRINT 'Fdp_UserRole'

MERGE INTO Fdp_UserRole AS TARGET
USING (VALUES
	  (0, N'None', N'No role defined')
	, (1, N'User', N'Standard user with no additional permissions')
	, (2, N'Viewer', N'User can view take rate files')
	, (3, N'Editor', N'User can edit take rate files')
	, (4, N'MarketReviewer', N'User can edit data for a take rate file when at the market review stage')
	, (5, N'Administrator', N'User can perform all system operations, although still needs to be granted appropriate access to markets / programmes')
	, (6, N'Importer', N'User can import take rate data from PPO files')
	, (7, N'AllMarkets', N'User has access to all markets without having to explicitly grant access on a per market basis')
	, (8, N'AllProgrammes', N'User has access to all programmes without having to explicitly grant access on a per programme basis')
	, (9, N'Approver', N'User can approve market review changes')
	, (10, N'Cloner', N'User can clone take rate data into other take rate documents')
	, (11, N'CanDelete', N'User can delete imported take rate files')
	, (12, N'Publisher', N'User can publish take rate files')
)
AS SOURCE (FdpUserRoleId, [Role], [Description]) ON TARGET.FdpUserRoleId = SOURCE.FdpUserRoleId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Role]			= SOURCE.[Role]
		, [Description]		= SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpUserRoleId, [Role], [Description])
	VALUES (FdpUserRoleId, [Role], [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_UserAction */
PRINT 'Fdp_UserAction'

MERGE INTO Fdp_UserAction AS TARGET
USING (VALUES
	  (0, N'None', N'No action defined')
	, (1, N'View', N'User can view the specified programme / market')
	, (2, N'Edit', N'User can edit the specified programme / market')
)
AS SOURCE (FdpUserActionId, [Action], [Description]) ON TARGET.FdpUserActionId = SOURCE.FdpUserActionId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Action]			= SOURCE.[Action]
		, [Description]		= SOURCE.[Description]

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpUserActionId, [Action], [Description])
	VALUES (FdpUserActionId, [Action], [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_MarketReviewStatus */
PRINT 'Fdp_MarketReviewStatus'

MERGE INTO Fdp_MarketReviewStatus AS TARGET
USING (VALUES
	  (0, N'None', N'No status defined', 1)
	, (1, N'Awaiting Review', N'The take rate data for the market is awaiting review', 1)
	, (2, N'Awaiting Approval', N'The take rate data for the market has been examined by the markets, any changes made and submitted for approval', 1)
	, (3, N'Rejected', N'The modifications from the market have been rejected', 1)
	, (4, N'Approved', N'The modifications from the market have been approved', 1)
	, (5, N'Recalled', N'The review has been recalled by the planning team', 1)
)
AS SOURCE (FdpMarketReviewStatusId, [Status], [Description], IsActive) ON TARGET.FdpMarketReviewStatusId = SOURCE.FdpMarketReviewStatusId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Status]			= SOURCE.[Status]
		, [Description]		= SOURCE.[Description]
		, IsActive			= SOURCE.IsActive

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpMarketReviewStatusId, [Status], [Description])
	VALUES (FdpMarketReviewStatusId, [Status], [Description])

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;

/* Fdp_MarketReviewStatus */
PRINT 'Fdp_EmailTemplate'

MERGE INTO Fdp_EmailTemplate AS TARGET
USING (VALUES
	  (0, N'None', N'', N'', 1)
	, (1, N'Sent For Market Review', N'', N'', 1)
	, (2, N'Market Review Received', N'', N'', 1)
	, (3, N'Market Review Rejected', N'', N'', 1)
	, (4, N'Market Review Approved', N'', N'', 1)
)
AS SOURCE (FdpEmailTemplateId, [Event], [Subject], [Body], IsActive) ON TARGET.FdpEmailTemplateId = SOURCE.FdpEmailTemplateId
WHEN MATCHED THEN

	-- Update existing rows
	UPDATE SET 
		  [Event]	= SOURCE.[Event]
		, [Subject]	= SOURCE.[Subject]
		, Body		= SOURCE.Body
		, IsActive	= SOURCE.IsActive

WHEN NOT MATCHED BY TARGET THEN

	-- Insert new type rows
	INSERT (FdpEmailTemplateId, [Event], [Subject], Body)
	VALUES (FdpEmailTemplateId, [Event], [Subject], Body)

WHEN NOT MATCHED BY SOURCE THEN

	-- Delete type rows that are no longer required
	DELETE;