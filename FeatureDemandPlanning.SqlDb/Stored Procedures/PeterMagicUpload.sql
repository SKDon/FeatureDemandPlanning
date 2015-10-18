/* SQL script file to import features and exclusive feature groups from James Markham's MFD spreadsheet. */
/* The spreadsheet must first be saved in comma delimited text format - a seperate file for each sheet. */
/* The 'Core MFD' sheet should be saved as 'Features.txt' and the 'EFG Detail' sheet saved as 'EFG.txt. */
/* The two files should then be copied to the server and the path adjusted accordingly */

/* Empty the temp feature table */
CREATE PROCEDURE [dbo].[PeterMagicUpload]
AS

TRUNCATE TABLE TMP_Feature_Import

/* Import tab delimited file into temp table */
BULK INSERT TMP_Feature_Import
FROM 'C:\Users\$sbant.JLRIEU1\Documents\OXO_Feature_Upload\Features.txt'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n',
	ERRORFILE = 'C:\Users\$sbant.JLRIEU1\Documents\OXO_Feature_Upload\import_errors\TMP_Feature_Import_Errors.txt'
)

BEGIN TRANSACTION

/* Cleanup temp table */	
	
	DELETE FROM TMP_Feature_Import
	WHERE Feat_Code IS NULL

