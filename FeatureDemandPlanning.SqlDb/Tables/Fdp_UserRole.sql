CREATE TABLE [dbo].[Fdp_UserRole] (
    [FdpUserRoleId] INT            NOT NULL,
    [Role]          NVARCHAR (25)  NOT NULL,
    [Description]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_UserRole] PRIMARY KEY CLUSTERED ([FdpUserRoleId] ASC)
);

