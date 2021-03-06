DECLARE @DocumentId AS INT = 89;
DECLARE @DestinationDocumentId AS INT = 108;

INSERT INTO OXO_Doc 
(
  Programme_Id
, Version_Id
, [Owner]
, Created_By
, Created_On
, Updated_By
, Last_Updated
, Gateway
, [Status]
, Archived
)
SELECT
  Programme_Id
, Version_Id
, [Owner]
, Created_By
, Created_On
, Updated_By
, Last_Updated
, 'PP'
, [Status]
, Archived
FROM
OXO_Doc
WHERE
ID = @DocumentId

SET @DestinationDocumentId = SCOPE_IDENTITY();

INSERT INTO OXO_Item_Data_FBM
(
	Section
, OXO_Doc_Id
, Model_Id
, Feature_Id
, Market_Group_Id
, Market_Id
, OXO_Code
, Reminder
, Active
, Created_By
, Created_On
, Updated_By
, Last_Updated
)
SELECT
 Section
, @DestinationDocumentId
, Model_Id
, Feature_Id
, Market_Group_Id
, Market_Id
, OXO_Code
, Reminder
, Active
, Created_By
, Created_On
, Updated_By
, Last_Updated
FROM
OXO_Item_Data_FBM
WHERE
OXO_Doc_Id = @DocumentId;

INSERT INTO OXO_Item_Data_MBM
(
	  Section
	, OXO_Doc_Id
	, Model_Id
	, Market_Group_Id
	, Market_Id
	, OXO_Code
	, Reminder
	, Active
	, Created_By
	, Created_On
	, Updated_By
	, Last_Updated
)
SELECT
	  Section
	, @DestinationDocumentId
	, Model_Id
	, Market_Group_Id
	, Market_Id
	, OXO_Code
	, Reminder
	, Active
	, Created_By
	, Created_On
	, Updated_By
	, Last_Updated
FROM
OXO_Item_Data_MBM
WHERE
OXO_Doc_Id = @DocumentId

INSERT INTO OXO_Item_Data_DPK
(
OXO_Doc_Id
, Model_Id
, Market_Id
, DPACK
, Created_By
, Created_On
, Updated_By
, Last_Updated
)
SELECT
	@DestinationDocumentId
, Model_Id
, Market_Id
, DPACK
, Created_By
, Created_On
, Updated_By
, Last_Updated
FROM 
OXO_Item_Data_DPK
WHERE
OXO_Doc_Id = @DocumentId

INSERT INTO OXO_Item_Data_FPS
(
	Section
, OXO_Doc_Id
, Model_Id
, Pack_Id
, Feature_Id
, Market_Group_Id
, Market_Id
, OXO_Code
, Reminder
, Active
, Created_By
, Created_On
, Updated_By
, Last_Updated
)
SELECT
Section
, @DestinationDocumentId
, Model_Id
, Pack_Id
, Feature_Id
, Market_Group_Id
, Market_Id
, OXO_Code
, Reminder
, Active
, Created_By
, Created_On
, Updated_By
, Last_Updated
FROM
OXO_Item_Data_FPS
WHERE
OXO_Doc_Id = @DocumentId

INSERT INTO OXO_Item_Data_GSF
(
Section
, OXO_Doc_Id
, Model_Id
, Feature_Id
, OXO_Code
, Reminder
, Active
, Created_By
, Created_On
, Updated_By
, Last_Updated
)
SELECT 
Section
, @DestinationDocumentId
, Model_Id
, Feature_Id
, OXO_Code
, Reminder
, Active
, Created_By
, Created_On
, Updated_By
, Last_Updated
FROM OXO_Item_Data_GSF
WHERE
OXO_Doc_Id = @DocumentId

