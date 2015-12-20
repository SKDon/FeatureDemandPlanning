CREATE TABLE [dbo].[Fdp_ChangesetDataItem] (
    [FdpChangesetDataItemId]     INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]                  DATETIME       CONSTRAINT [DF_Fdp_ChangesetDataItem_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [FdpChangesetId]             INT            NOT NULL,
    [MarketId]                   INT            NOT NULL,
    [ModelId]                    INT            NULL,
    [FdpModelId]                 INT            NULL,
    [FeatureId]                  INT            NULL,
    [FdpFeatureId]               INT            NULL,
    [TotalVolume]                INT            NULL,
    [PercentageTakeRate]         DECIMAL (5, 4) CONSTRAINT [DF_FdpChangesetDataItem_PercentageTakeRate] DEFAULT ((0)) NULL,
    [IsDeleted]                  BIT            CONSTRAINT [DF_Fdp_ChangesetDataItem_IsDeleted] DEFAULT ((0)) NOT NULL,
    [IsVolumeUpdate]             BIT            CONSTRAINT [DF_Fdp_ChangesetDataItem_IsVolumeUpdate] DEFAULT ((0)) NOT NULL,
    [IsPercentageUpdate]         BIT            CONSTRAINT [DF_Fdp_ChangesetDataItem_IsPercentageUpdate] DEFAULT ((0)) NOT NULL,
    [OriginalVolume]             INT            NULL,
    [OriginalPercentageTakeRate] DECIMAL (5, 4) NULL,
    [FdpVolumeDataItemId]        INT            NULL,
    CONSTRAINT [PK_Fdp_ChangesetDataItem] PRIMARY KEY CLUSTERED ([FdpChangesetDataItemId] ASC),
    CONSTRAINT [FK_Fdp_ChangesetDataItem_Fdp_Feature] FOREIGN KEY ([FdpFeatureId]) REFERENCES [dbo].[Fdp_Feature] ([FdpFeatureId]),
    CONSTRAINT [FK_Fdp_ChangesetDataItem_Fdp_Model] FOREIGN KEY ([FdpModelId]) REFERENCES [dbo].[Fdp_Model] ([FdpModelId]),
    CONSTRAINT [FK_Fdp_ChangesetDataItem_Fdp_VolumeDataItem] FOREIGN KEY ([FdpVolumeDataItemId]) REFERENCES [dbo].[Fdp_VolumeDataItem] ([FdpVolumeDataItemId]),
    CONSTRAINT [FK_Fdp_ChangesetDataItem_OXO_Feature_Ext] FOREIGN KEY ([FeatureId]) REFERENCES [dbo].[OXO_Feature_Ext] ([Id]),
    CONSTRAINT [FK_Fdp_ChangesetDataItem_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_ChangesetDataItem_OXO_Programme_Model] FOREIGN KEY ([ModelId]) REFERENCES [dbo].[OXO_Programme_Model] ([Id]),
    CONSTRAINT [FK_FdpChangesetDataItem_Fdp_Changeset] FOREIGN KEY ([FdpChangesetId]) REFERENCES [dbo].[Fdp_Changeset] ([FdpChangesetId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ChangesetDataItem_Cover]
    ON [dbo].[Fdp_ChangesetDataItem]([FdpChangesetId] ASC, [MarketId] ASC, [ModelId] ASC, [FeatureId] ASC, [FdpModelId] ASC, [FdpFeatureId] ASC, [FdpVolumeDataItemId] ASC);

