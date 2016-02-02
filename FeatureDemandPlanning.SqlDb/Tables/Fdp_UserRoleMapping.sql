CREATE TABLE [dbo].[Fdp_UserRoleMapping] (
    [FdpUserRoleMappingId] INT IDENTITY (1, 1) NOT NULL,
    [FdpUserId]            INT NOT NULL,
    [FdpUserRoleId]        INT NOT NULL,
    [IsActive]             BIT CONSTRAINT [DF_Fdp_UserRoleMapping_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_UserRoleMapping] PRIMARY KEY CLUSTERED ([FdpUserRoleMappingId] ASC),
    CONSTRAINT [FK_Fdp_UserRoleMapping_Fdp_User] FOREIGN KEY ([FdpUserId]) REFERENCES [dbo].[Fdp_User] ([FdpUserId]),
    CONSTRAINT [FK_Fdp_UserRoleMapping_Fdp_UserRole] FOREIGN KEY ([FdpUserRoleId]) REFERENCES [dbo].[Fdp_UserRole] ([FdpUserRoleId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_UserRoleMapping_FdpUserId]
    ON [dbo].[Fdp_UserRoleMapping]([FdpUserId] ASC);

