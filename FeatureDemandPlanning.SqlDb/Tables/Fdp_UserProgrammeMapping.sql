CREATE TABLE [dbo].[Fdp_UserProgrammeMapping] (
    [FdpUserProgrammeMappingId] INT IDENTITY (1, 1) NOT NULL,
    [FdpUserId]                 INT NOT NULL,
    [ProgrammeId]               INT NOT NULL,
    [FdpUserActionId]           INT NOT NULL,
    [IsActive]                  BIT CONSTRAINT [DF_Fdp_UserProgrammeMapping_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_UserProgrammeMapping] PRIMARY KEY CLUSTERED ([FdpUserProgrammeMappingId] ASC),
    CONSTRAINT [FK_Fdp_UserProgrammeMapping_Fdp_User] FOREIGN KEY ([FdpUserId]) REFERENCES [dbo].[Fdp_User] ([FdpUserId]),
    CONSTRAINT [FK_Fdp_UserProgrammeMapping_Fdp_UserAction] FOREIGN KEY ([FdpUserActionId]) REFERENCES [dbo].[Fdp_UserAction] ([FdpUserActionId]),
    CONSTRAINT [FK_Fdp_UserProgrammeMapping_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_UserProgrammeMapping_FdpUserId]
    ON [dbo].[Fdp_UserProgrammeMapping]([FdpUserId] ASC, [ProgrammeId] ASC, [IsActive] ASC);

