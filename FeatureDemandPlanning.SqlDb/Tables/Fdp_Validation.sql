CREATE TABLE [dbo].[Fdp_Validation] (
    [FdpValidationId]         INT            IDENTITY (1, 1) NOT NULL,
    [ValidationOn]            DATETIME       CONSTRAINT [DF_Fdp_Validation_ValidationOn] DEFAULT (getdate()) NOT NULL,
    [FdpVolumeHeaderId]       INT            NOT NULL,
    [MarketId]                INT            NOT NULL,
    [FdpValidationRuleId]     INT            NOT NULL,
    [Message]                 NVARCHAR (MAX) NOT NULL,
    [FdpVolumeDataItemId]     INT            NULL,
    [FdpTakeRateSummaryId]    INT            NULL,
    [FdpTakeRateFeatureMixId] INT            NULL,
    [FdpChangesetDataItemId]  INT            NULL,
    [IsActive]                BIT            CONSTRAINT [DF_Fdp_Validation_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_Validation] PRIMARY KEY CLUSTERED ([FdpValidationId] ASC),
    CONSTRAINT [FK_Fdp_Validation_Fdp_ChangesetDataItem] FOREIGN KEY ([FdpChangesetDataItemId]) REFERENCES [dbo].[Fdp_ChangesetDataItem] ([FdpChangesetDataItemId]),
    CONSTRAINT [FK_Fdp_Validation_Fdp_TakeRateFeatureMix] FOREIGN KEY ([FdpTakeRateFeatureMixId]) REFERENCES [dbo].[Fdp_TakeRateFeatureMix] ([FdpTakeRateFeatureMixId]),
    CONSTRAINT [FK_Fdp_Validation_Fdp_TakeRateSummary] FOREIGN KEY ([FdpTakeRateSummaryId]) REFERENCES [dbo].[Fdp_TakeRateSummary] ([FdpTakeRateSummaryId]),
    CONSTRAINT [FK_Fdp_Validation_Fdp_ValidationRule] FOREIGN KEY ([FdpValidationRuleId]) REFERENCES [dbo].[Fdp_ValidationRule] ([FdpValidationRuleId]),
    CONSTRAINT [FK_Fdp_Validation_Fdp_VolumeDataItem] FOREIGN KEY ([FdpVolumeDataItemId]) REFERENCES [dbo].[Fdp_VolumeDataItem] ([FdpVolumeDataItemId]),
    CONSTRAINT [FK_Fdp_Validation_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_Validation_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Validation_FdpValidationRuleId]
    ON [dbo].[Fdp_Validation]([FdpValidationRuleId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Validation_FdpChangesetDataItemId]
    ON [dbo].[Fdp_Validation]([FdpChangesetDataItemId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Validation_FdpVolumeHeader]
    ON [dbo].[Fdp_Validation]([FdpVolumeHeaderId] ASC, [MarketId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Validation_FdpVolumeDataItemId]
    ON [dbo].[Fdp_Validation]([FdpVolumeDataItemId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Validation_FdpTakeRateSummaryId]
    ON [dbo].[Fdp_Validation]([FdpTakeRateSummaryId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Validation_FdpTakeRateFeatureMixId]
    ON [dbo].[Fdp_Validation]([FdpTakeRateFeatureMixId] ASC);

