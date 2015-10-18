CREATE TABLE [dbo].[OXO_Programme_Feature_Link] (
    [Programme_Id] INT             NOT NULL,
    [Feature_Id]   INT             NOT NULL,
    [CDSID]        NVARCHAR (50)   NULL,
    [Comment]      NVARCHAR (2000) NULL,
    [ChangeSet_Id] INT             NULL,
    [Rule_Text]    NVARCHAR (2000) NULL,
    CONSTRAINT [PK_OXO_Programme_Feature_Link] PRIMARY KEY CLUSTERED ([Programme_Id] ASC, [Feature_Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Feature_Link_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_OXO_Programme_Feature_Link_ProgrammeId]
    ON [dbo].[OXO_Programme_Feature_Link]([Programme_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Feature]
ON [dbo].[OXO_Programme_Feature_Link]
FOR INSERT, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Add Programme Feature', Programme_Id, 'Programme', Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Programme Feature', Programme_Id, 'Programme', Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END
