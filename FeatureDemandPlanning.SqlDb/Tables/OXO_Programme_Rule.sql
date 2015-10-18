CREATE TABLE [dbo].[OXO_Programme_Rule] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Programme_Id]  INT            NULL,
    [Rule_Category] NVARCHAR (50)  NOT NULL,
    [Rule_Group]    NVARCHAR (50)  NOT NULL,
    [Rule_Assert]   NVARCHAR (500) NULL,
    [Rule_Report]   NVARCHAR (500) NULL,
    [Rule_Response] NVARCHAR (500) NOT NULL,
    [Owner]         NVARCHAR (50)  NOT NULL,
    [Approved]      BIT            NULL,
    [Active]        BIT            NULL,
    [Created_By]    VARCHAR (8)    NOT NULL,
    [Created_On]    DATETIME       NOT NULL,
    [Updated_By]    VARCHAR (8)    NULL,
    [Last_Updated]  DATETIME       NULL,
    [Rule_Reason]   NVARCHAR (MAX) NULL,
    [Clone_Id]      INT            NULL,
    [ChangeSet_Id]  INT            NULL,
    CONSTRAINT [PK_OXO_Programme_Rule] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Rule_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Rule]
    ON [dbo].[OXO_Programme_Rule]([Programme_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Programme_Rule_Prog_Id_Rule_Cat_Rule_Grp]
    ON [dbo].[OXO_Programme_Rule]([Programme_Id] ASC, [Rule_Category] ASC, [Rule_Group] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Rule]
ON [dbo].[OXO_Programme_Rule]
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
		SELECT 'Add Programme Rule', Programme_Id, 'Programme', 
		       Id, 'Rule',	  
		       null, null, Created_By, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END

   IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Remove Programme Rule', Programme_Id, 'Programme', 
		       Id, 'Rule',	
		       null, null, Updated_By, GETDATE(), Changeset_Id
		FROM DELETED;							
	END

END
