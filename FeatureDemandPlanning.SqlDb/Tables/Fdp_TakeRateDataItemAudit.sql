CREATE TABLE [dbo].[Fdp_TakeRateDataItemAudit] (
    [FdpVolumeDataItemAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [AuditOn]                  DATETIME       NOT NULL,
    [AuditBy]                  NVARCHAR (16)  NOT NULL,
    [FdpVolumeDataItemId]      INT            NOT NULL,
    [Volume]                   INT            NOT NULL,
    [PercentageTakeRate]       DECIMAL (5, 2) NOT NULL,
    CONSTRAINT [PK_Fdp_VolumeDataItemAudit] PRIMARY KEY CLUSTERED ([FdpVolumeDataItemAuditId] ASC),
    CONSTRAINT [FK_Fdp_VolumeDataItemAudit_Fdp_VolumeDataItem] FOREIGN KEY ([FdpVolumeDataItemId]) REFERENCES [dbo].[Fdp_VolumeDataItem] ([FdpVolumeDataItemId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_VolumeDataItemAudit]
    ON [dbo].[Fdp_TakeRateDataItemAudit]([FdpVolumeDataItemId] ASC);

