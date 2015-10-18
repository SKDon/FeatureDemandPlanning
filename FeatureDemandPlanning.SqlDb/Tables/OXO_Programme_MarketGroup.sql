CREATE TABLE [dbo].[OXO_Programme_MarketGroup] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Programme_Id]  INT            NULL,
    [Group_Name]    NVARCHAR (500) NULL,
    [Extra_Info]    NVARCHAR (500) NULL,
    [Active]        BIT            NULL,
    [Display_Order] INT            NULL,
    [Created_By]    NVARCHAR (8)   NULL,
    [Created_On]    DATETIME       NULL,
    [Updated_By]    NVARCHAR (8)   NULL,
    [Last_Updated]  DATETIME       NULL,
    [Clone_Id]      INT            NULL,
    [ChangeSet_Id]  INT            NULL,
    CONSTRAINT [PK_OXO_Programme_Market] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Market_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Prog_MarketGroup]
    ON [dbo].[OXO_Programme_MarketGroup]([Programme_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Programme_Market_Group_Display_Order]
    ON [dbo].[OXO_Programme_MarketGroup]([Display_Order] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_MarketGroup]
ON [dbo].[OXO_Programme_MarketGroup]
FOR INSERT, UPDATE, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    
    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Update Programme MarketGroup', Programme_Id, 'Programme',
	           Id, 'MarketGroup', Created_By, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Add Programme MarketGroup', Programme_Id, 'Programme', 
		       Id, 'MarketGroup', Updated_By, GETDATE(), ChangeSet_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_CDSID, Event_DateTime, ChangeSet_Id) 
		SELECT 'Remove Programme MarketGroup', Programme_Id, 'Programme', 
		       Id, 'MarketGroup', Updated_By, GETDATE(), ChangeSet_Id
		FROM DELETED;							
	END

END
