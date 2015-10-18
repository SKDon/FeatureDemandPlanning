CREATE TABLE [dbo].[OXO_Programme_Trim] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Programme_Id]  INT            NOT NULL,
    [Name]          NVARCHAR (500) NULL,
    [Abbreviation]  NVARCHAR (50)  NULL,
    [Level]         NVARCHAR (500) NULL,
    [Active]        BIT            CONSTRAINT [DF_OXO_Programme_Trim_Active] DEFAULT ((1)) NULL,
    [Created_By]    NVARCHAR (8)   NULL,
    [Created_On]    DATETIME       NULL,
    [Updated_By]    NVARCHAR (8)   NULL,
    [Last_Updated]  DATETIME       NULL,
    [DPCK]          NVARCHAR (10)  NULL,
    [Clone_Id]      INT            NULL,
    [ChangeSet_Id]  INT            NULL,
    [Display_Order] INT            NULL,
    CONSTRAINT [PK_OXO_Programme_Trim] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Trim_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Trim]
    ON [dbo].[OXO_Programme_Trim]([Programme_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Trim]
ON [dbo].[OXO_Programme_Trim]
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
		SELECT 'Add Programme Trim', Programme_Id, 'Programme', 
		       Id, 'Trim',	  
		       null, null, Created_By, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END

   IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Remove Programme Trim', Programme_Id, 'Programme', 
		       Id, 'Trim',	
		       null, null, Updated_By, GETDATE(), Changeset_Id
		FROM DELETED;							
	END

END
