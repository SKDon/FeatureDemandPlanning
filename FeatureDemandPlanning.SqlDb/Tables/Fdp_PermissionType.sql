CREATE TABLE [dbo].[Fdp_PermissionType] (
    [FdpPermissionTypeId] INT            NOT NULL,
    [Permission]          NVARCHAR (25)  NOT NULL,
    [Description]         NVARCHAR (255) NULL,
    CONSTRAINT [PK_FdpPermissionType] PRIMARY KEY CLUSTERED ([FdpPermissionTypeId] ASC)
);

