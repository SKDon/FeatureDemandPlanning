CREATE TABLE [dbo].[Fdp_Changeset] (
    [FdpChangesetId]    INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]         DATETIME      CONSTRAINT [DF_Fdp_Changeset_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16) CONSTRAINT [DF_Fdp_Changeset_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId] INT           NOT NULL,
    [IsDeleted]         BIT           CONSTRAINT [DF_Fdp_Changeset_IsDeleted] DEFAULT ((0)) NOT NULL,
    [IsSaved]           BIT           CONSTRAINT [DF_Fdp_Changeset_IsSaved] DEFAULT ((0)) NOT NULL,
    [MarketId]          INT           NOT NULL,
	[Comment]           NVARCHAR (MAX) NULL,
    [UpdatedOn]         DATETIME       NULL,
    [UpdatedBy]         NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_Changeset] PRIMARY KEY CLUSTERED ([FdpChangesetId] ASC),
    CONSTRAINT [FK_Fdp_Changeset_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_Changeset_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Changeset_Cover]
    ON [dbo].[Fdp_Changeset]([FdpVolumeHeaderId] ASC, [CreatedBy] ASC, [IsDeleted] ASC, [IsSaved] ASC, [MarketId] ASC);



