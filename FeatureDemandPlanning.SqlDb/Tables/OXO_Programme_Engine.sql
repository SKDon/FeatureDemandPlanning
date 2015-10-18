CREATE TABLE [dbo].[OXO_Programme_Engine] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [Programme_Id]    INT           NOT NULL,
    [Size]            NVARCHAR (50) NOT NULL,
    [Cylinder]        NVARCHAR (50) NULL,
    [Turbo]           NVARCHAR (50) NULL,
    [Fuel_Type]       NVARCHAR (50) NULL,
    [Power]           NVARCHAR (50) NULL,
    [Electrification] NVARCHAR (50) NULL,
    [Active]          BIT           NULL,
    [Created_By]      NVARCHAR (8)  NULL,
    [Created_On]      DATETIME      NULL,
    [Updated_By]      NVARCHAR (8)  NULL,
    [Last_Updated]    DATETIME      NULL,
    [Clone_Id]        INT           NULL,
    [ChangeSet_Id]    INT           NULL,
    CONSTRAINT [PK_OXO_Programme_Engine] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Engine_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Engine]
    ON [dbo].[OXO_Programme_Engine]([Programme_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Engine]
ON [dbo].[OXO_Programme_Engine]
FOR INSERT, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Add Programme Engine', Programme_Id, 'Programme', Id, 'Engine', Created_By, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Programme Engine', Programme_Id, 'Programme', Id, 'Engine', Updated_By, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END

