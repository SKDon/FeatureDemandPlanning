CREATE TABLE [dbo].[Fdp_PowertrainDataItemAudit] (
    [FdpPowertrainDataItemAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [AuditOn]                      DATETIME       NOT NULL,
    [AuditBy]                      NVARCHAR (50)  CONSTRAINT [DF_Fdp_PowertrainDataItemAudit_AuditBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpPowertrainDataItemId]      INT            NOT NULL,
    [Volume]                       INT            NOT NULL,
    [PercentageTakeRate]           DECIMAL (5, 4) NOT NULL,
    CONSTRAINT [PK_Fdp_PowertrainDataItemAudit_1] PRIMARY KEY CLUSTERED ([FdpPowertrainDataItemAuditId] ASC),
    CONSTRAINT [FK_Fdp_PowertrainDataItemAudit_Fdp_PowertrainDataItem] FOREIGN KEY ([FdpPowertrainDataItemId]) REFERENCES [dbo].[Fdp_PowertrainDataItem] ([FdpPowertrainDataItemId])
);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_PowertrainDataItemAudit_FdpPowertrainDataItemId]
    ON [dbo].[Fdp_PowertrainDataItemAudit]([FdpPowertrainDataItemId] ASC);

