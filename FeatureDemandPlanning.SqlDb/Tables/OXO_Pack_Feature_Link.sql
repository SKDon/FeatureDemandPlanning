CREATE TABLE [dbo].[OXO_Pack_Feature_Link] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Programme_Id] INT             NOT NULL,
    [Pack_Id]      INT             NOT NULL,
    [Feature_Id]   INT             NOT NULL,
    [Comment]      NVARCHAR (2000) NULL,
    [Rule_Text]    NVARCHAR (2000) NULL,
    [CDSID]        NVARCHAR (10)   NULL,
    [ChangeSet_Id] INT             NULL,
    CONSTRAINT [PK_OXO_Pack_Feature_Link] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Pack_Feature_Link_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_OXO_Pack_Feature_Link_OXO_Programme_Pack] FOREIGN KEY ([Pack_Id]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Pack_Feature_Link]
    ON [dbo].[OXO_Pack_Feature_Link]([Programme_Id] ASC, [Pack_Id] ASC, [Feature_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Pack_Feature]
ON dbo.OXO_Pack_Feature_Link
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
		SELECT 'Add Pack Feature', Programme_Id, 'Programme', Pack_Id, 'Pack',  
		        Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Pack Feature', Programme_Id, 'Programme', Pack_Id, 'Pack', 
		        Feature_Id, 'Feature', CDSID, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END
