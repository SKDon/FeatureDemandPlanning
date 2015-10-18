CREATE TABLE [dbo].[OXO_Archived_Programme_GSF_Link] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Doc_Id]       INT             NOT NULL,
    [Programme_Id] INT             NOT NULL,
    [Feature_Id]   INT             NOT NULL,
    [CDSID]        NVARCHAR (50)   NULL,
    [Comment]      NVARCHAR (2000) NULL,
    [Rule_Text]    NVARCHAR (2000) NULL,
    [ChangeSet_Id] INT             NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_GSF_Link] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_GSF_Link]
    ON [dbo].[OXO_Archived_Programme_GSF_Link]([Doc_Id] ASC, [Programme_Id] ASC, [Feature_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Archived_Programme_GSF]
ON dbo.OXO_Archived_Programme_GSF_Link
FOR INSERT, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Add Archived Global Standard Feature', Doc_Id, 'Document', Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Archived Global Standard Feature', Doc_Id, 'Document', Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END
