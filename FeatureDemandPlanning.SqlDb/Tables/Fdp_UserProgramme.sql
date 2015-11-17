CREATE TABLE [dbo].[Fdp_UserProgramme] (
    [FdpUserProgrammeId]  INT IDENTITY (1, 1) NOT NULL,
    [FdpUserId]           INT NOT NULL,
    [ProgrammeId]         INT NOT NULL,
    [FdpPermissionTypeId] INT NOT NULL,
    CONSTRAINT [PK_Fdp_UserProgramme] PRIMARY KEY CLUSTERED ([FdpUserProgrammeId] ASC),
    CONSTRAINT [FK_Fdp_UserProgramme_Fdp_PermissionType] FOREIGN KEY ([FdpPermissionTypeId]) REFERENCES [dbo].[Fdp_PermissionType] ([FdpPermissionTypeId]),
    CONSTRAINT [FK_Fdp_UserProgramme_Fdp_User] FOREIGN KEY ([FdpUserId]) REFERENCES [dbo].[Fdp_User] ([FdpUserId]),
    CONSTRAINT [FK_Fdp_UserProgramme_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_UserProgramme_ProgrammeId]
    ON [dbo].[Fdp_UserProgramme]([ProgrammeId] ASC, [FdpUserId] ASC);

