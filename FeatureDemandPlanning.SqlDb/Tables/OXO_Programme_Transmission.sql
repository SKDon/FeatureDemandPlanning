CREATE TABLE [dbo].[OXO_Programme_Transmission] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Programme_Id] INT           NOT NULL,
    [Type]         NVARCHAR (50) NULL,
    [Drivetrain]   NVARCHAR (50) NULL,
    [Active]       BIT           NULL,
    [Created_By]   NVARCHAR (8)  NULL,
    [Created_On]   DATETIME      NULL,
    [Updated_By]   NVARCHAR (8)  NULL,
    [Last_Updated] DATETIME      NULL,
    [Clone_Id]     INT           NULL,
    [ChangeSet_Id] INT           NULL,
    CONSTRAINT [PK_OXO_Programme_Transmission] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Transmission_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Trans]
    ON [dbo].[OXO_Programme_Transmission]([Programme_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Transmission]
ON [dbo].[OXO_Programme_Transmission]
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
		SELECT 'Add Programme Transmission', Programme_Id, 'Programme', 
		       Id, 'Transmission',	  
		       null, null, Created_By, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END

   IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Remove Programme Trsnsmission', Programme_Id, 'Programme', 
		       Id, 'Transmission',	
		       null, null, Updated_By, GETDATE(), Changeset_Id
		FROM DELETED;							
	END

END
