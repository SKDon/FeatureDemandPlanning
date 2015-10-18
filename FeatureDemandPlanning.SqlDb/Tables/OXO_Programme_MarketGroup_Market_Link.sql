CREATE TABLE [dbo].[OXO_Programme_MarketGroup_Market_Link] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Programme_Id]    INT            NOT NULL,
    [Market_Group_Id] INT            NOT NULL,
    [Country_Id]      INT            NOT NULL,
    [Sub_Region]      NVARCHAR (500) NULL,
    [CDSID]           NVARCHAR (50)  NULL,
    [Changeset_Id]    INT            NULL,
    CONSTRAINT [PK_OXO_Programme_MarketGroup_Market_Link] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Market_Country_Link_OXO_Master_Country] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Market_Country_Link_OXO_Programme_Market] FOREIGN KEY ([Market_Group_Id]) REFERENCES [dbo].[OXO_Programme_MarketGroup] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Group_Market]
    ON [dbo].[OXO_Programme_MarketGroup_Market_Link]([Programme_Id] ASC, [Market_Group_Id] ASC, [Country_Id] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Market]
ON dbo.OXO_Programme_MarketGroup_Market_Link
FOR INSERT, UPDATE, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
    
    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Update Programme MarketGroup/Market', Programme_Id, 'Programme',
	           Market_Group_Id, 'MarketGroup',	
		       Country_Id, 'Market', CDSID, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END
    	
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Add Programme MarketGroup/Market', Programme_Id, 'Programme', 
		       Market_Group_Id, 'MarketGroup',	  
		       Country_Id, 'Market', CDSID, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END

	IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Remove Programme MarketGroup/Market', Programme_Id, 'Programme', 
		       Market_Group_Id, 'MarketGroup',	
		       Country_Id, 'Market', CDSID, GETDATE(), Changeset_Id
		FROM DELETED;							
	END

END
