CREATE TABLE [dbo].[OXO_Archived_Pack_Feature_Link] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Doc_Id]       INT             NOT NULL,
    [Programme_Id] INT             NOT NULL,
    [Pack_Id]      INT             NOT NULL,
    [Feature_Id]   INT             NOT NULL,
    [CDSID]        NVARCHAR (10)   NULL,
    [ChangeSet_Id] INT             NULL,
    [Comment]      NVARCHAR (2000) NULL,
    [Rule_Text]    NVARCHAR (2000) NULL,
    CONSTRAINT [PK_OXO_Archived_Pack_Feature_Link] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [Idx_Archive_Pack_Feat]
    ON [dbo].[OXO_Archived_Pack_Feature_Link]([Doc_Id] ASC, [Programme_Id] ASC, [Pack_Id] ASC, [Feature_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Archived_Pack_Feature]
ON dbo.OXO_Archived_Pack_Feature_Link
FOR INSERT, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Add Archived Pack Feature', Doc_Id, 'Document', Pack_Id, 'Pack',  
		        Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Archived Pack Feature', Doc_Id, 'Document', Pack_Id, 'Pack', 
		        Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END
