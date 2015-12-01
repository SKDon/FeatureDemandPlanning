CREATE TABLE [dbo].[Fdp_OxoVolumeDataItemAudit] (
    [FdpOxoVolumeDataItemAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [AuditBy]                     NVARCHAR (16)  NULL,
    [AuditOn]                     DATETIME       NULL,
    [AuditAction]                 NVARCHAR (10)  NULL,
    [FdpOxoVolumeDataItemId]      INT            NULL,
    [Section]                     NVARCHAR (100) NULL,
    [ModelId]                     INT            NULL,
    [FdpModelId]                  INT            NULL,
    [FeatureId]                   INT            NULL,
    [FdpFeatureId]                INT            NULL,
    [MarketGroupId]               INT            NULL,
    [MarketId]                    INT            NULL,
    [FdpOxoDocId]                 INT            NULL,
    [Volume]                      INT            NULL,
    [PercentageTakeRate]          DECIMAL (5, 4) NULL,
    [CreatedBy]                   NVARCHAR (16)  NULL,
    [CreatedOn]                   DATETIME       NULL,
    [UpdatedBy]                   NVARCHAR (16)  NULL,
    [LastUpdated]                 DATETIME       NULL,
    [PackId]                      INT            NULL,
    [IsActive]                    BIT            NULL,
    CONSTRAINT [PK_Fdp_OxoVolumeDataItemAudit] PRIMARY KEY CLUSTERED ([FdpOxoVolumeDataItemAuditId] ASC),
    CONSTRAINT [FK_Fdp_OxoVolumeDataItemAudit_Fdp_OxoVolumeDataItem] FOREIGN KEY ([FdpOxoVolumeDataItemId]) REFERENCES [dbo].[Fdp_OxoVolumeDataItem] ([FdpOxoVolumeDataItemId])
);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_OxoVolumeDataItemAudit_FdpOxoVolumeDataItemId]
    ON [dbo].[Fdp_OxoVolumeDataItemAudit]([FdpOxoVolumeDataItemId] ASC, [AuditOn] DESC);

