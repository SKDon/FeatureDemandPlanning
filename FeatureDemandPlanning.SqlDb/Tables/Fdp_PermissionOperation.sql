CREATE TABLE [dbo].[Fdp_PermissionOperation] (
    [FdpPermissionOperationId] INT            NOT NULL,
    [FdpPermissionObjectType]  NVARCHAR (50)  NOT NULL,
    [Operation]                NVARCHAR (25)  NOT NULL,
    [Description]              NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_FdpPermissionOperation] PRIMARY KEY CLUSTERED ([FdpPermissionOperationId] ASC),
    CONSTRAINT [FK_FdpPermissionOperation_FdpPermissionObjectType] FOREIGN KEY ([FdpPermissionObjectType]) REFERENCES [dbo].[Fdp_PermissionObjectType] ([FdpPermissionObjectType])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [Ux_FdpPermissionOperation]
    ON [dbo].[Fdp_PermissionOperation]([FdpPermissionObjectType] ASC, [Operation] ASC);

