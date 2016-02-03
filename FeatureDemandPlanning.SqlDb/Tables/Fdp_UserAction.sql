CREATE TABLE [dbo].[Fdp_UserAction] (
    [FdpUserActionId] INT            NOT NULL,
    [Action]          NVARCHAR (25)  NOT NULL,
    [Description]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_UserAction] PRIMARY KEY CLUSTERED ([FdpUserActionId] ASC)
);

