CREATE TABLE [dbo].[OXO_Event_Log] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [Event_Type]           NVARCHAR (500) NULL,
    [Event_Parent_Id]      INT            NULL,
    [Event_Parent_Object]  NVARCHAR (500) NULL,
    [Event_Parent2_Id]     INT            NULL,
    [Event_Parent2_Object] NVARCHAR (500) NULL,
    [Event_Parent3_Id]     INT            NULL,
    [Event_Parent3_Object] NVARCHAR (500) NULL,
    [Event_CDSID]          NVARCHAR (10)  NULL,
    [Event_DateTime]       DATETIME       NULL,
    [ChangeSet_Id]         INT            NULL,
    CONSTRAINT [PK_OXO_Event_Log] PRIMARY KEY CLUSTERED ([Id] ASC)
);

