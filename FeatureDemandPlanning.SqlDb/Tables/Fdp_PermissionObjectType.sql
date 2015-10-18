CREATE TABLE [dbo].[Fdp_PermissionObjectType] (
    [FdpPermissionObjectType] NVARCHAR (50)  NOT NULL,
    [Description]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_FdpPermissionObjectType] PRIMARY KEY CLUSTERED ([FdpPermissionObjectType] ASC)
);

