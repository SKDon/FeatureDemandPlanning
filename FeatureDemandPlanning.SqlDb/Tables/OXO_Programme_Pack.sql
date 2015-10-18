CREATE TABLE [dbo].[OXO_Programme_Pack] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Programme_Id] INT             NOT NULL,
    [Pack_Name]    NVARCHAR (500)  NOT NULL,
    [Extra_Info]   NVARCHAR (2000) NULL,
    [Feature_Code] NVARCHAR (50)   NULL,
    [OA_Code]      NVARCHAR (50)   NULL,
    [Created_By]   NVARCHAR (10)   NULL,
    [Created_On]   DATETIME        NULL,
    [Updated_By]   NVARCHAR (10)   NULL,
    [Last_Updated] DATETIME        NULL,
    [Clone_Id]     INT             NULL,
    [ChangeSet_Id] INT             NULL,
    [Rule_Text]    NVARCHAR (2000) NULL,
    CONSTRAINT [PK_OXO_Programme_Pack] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Pack_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Pack]
    ON [dbo].[OXO_Programme_Pack]([Programme_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Pack]
ON dbo.OXO_Programme_Pack
FOR INSERT, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
       	
   IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Add Programme Pack', Programme_Id, 'Programme', 
		       Id, 'Pack',	  
		       null, null, Created_By, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END

   IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Remove Programme Pack', Programme_Id, 'Programme', 
		       Id, 'Pack',	
		       null, null, Updated_By, GETDATE(), Changeset_Id
		FROM DELETED;							
	END

END
