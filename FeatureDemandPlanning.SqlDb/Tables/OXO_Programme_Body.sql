CREATE TABLE [dbo].[OXO_Programme_Body] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Programme_Id] INT           NOT NULL,
    [Shape]        NVARCHAR (50) NULL,
    [Doors]        NVARCHAR (50) NULL,
    [Wheelbase]    NVARCHAR (50) NULL,
    [Active]       BIT           CONSTRAINT [DF_OXO_Programme_Body_Active] DEFAULT ((1)) NULL,
    [Created_By]   NVARCHAR (8)  NULL,
    [Created_On]   DATETIME      NULL,
    [Updated_By]   NVARCHAR (8)  NULL,
    [Last_Updated] DATETIME      NULL,
    [Clone_Id]     INT           NULL,
    [ChangeSet_Id] INT           NULL,
    CONSTRAINT [PK_OXO_Programme_Body] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Body_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Body]
    ON [dbo].[OXO_Programme_Body]([Programme_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_Programme_Body_Shape]
    ON [dbo].[OXO_Programme_Body]([Shape] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Body]
ON [dbo].[OXO_Programme_Body]
FOR INSERT, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Add Programme Body', Programme_Id, 'Programme', Id, 'Body', Created_By, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Programme Body', Programme_Id, 'Programme', Id, 'Body', Updated_By, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END


GO
CREATE NONCLUSTERED INDEX [Ix_NC_OXO_Programme_Body_Active]
    ON [dbo].[OXO_Programme_Body]([Active] ASC);

