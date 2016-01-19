CREATE TABLE [dbo].[Fdp_Validation] (
    [FdpValidationId]        INT            IDENTITY (1, 1) NOT NULL,
    [ValidationOn]           DATETIME       CONSTRAINT [DF_Fdp_Validation_ValidationOn] DEFAULT (getdate()) NOT NULL,
    [FdpVolumeHeaderId]      INT            NOT NULL,
    [MarketId]               INT            NOT NULL,
    [FdpChangesetDataItemId] INT            NULL,
    [FdpValidationRuleId]    INT            NOT NULL,
    [Message]                NVARCHAR (MAX) NOT NULL,
    [IsActive]               BIT            CONSTRAINT [DF_Fdp_Validation_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_Validation] PRIMARY KEY CLUSTERED ([FdpValidationId] ASC),
    CONSTRAINT [FK_Fdp_Validation_Fdp_ChangesetDataItem] FOREIGN KEY ([FdpChangesetDataItemId]) REFERENCES [dbo].[Fdp_ChangesetDataItem] ([FdpChangesetDataItemId]),
    CONSTRAINT [FK_Fdp_Validation_Fdp_ValidationRule] FOREIGN KEY ([FdpValidationRuleId]) REFERENCES [dbo].[Fdp_ValidationRule] ([FdpValidationRuleId]),
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

