CREATE TABLE [dbo].[Fdp_TakeRateFeatureMixAudit] (
    [FdpTakeRateFeatureMixAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [AuditOn]                      DATETIME       NOT NULL,
    [AuditBy]                      NVARCHAR (50)  CONSTRAINT [DF_Fdp_TakeRateFeatureMixAudit_AuditBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpTakeRateFeatureMixId]      INT            NOT NULL,
    [Volume]                       INT            NOT NULL,
    [PercentageTakeRate]           DECIMAL (5, 4) NOT NULL,
    CONSTRAINT [PK_Fdp_TakeRateFeatureMixAudit] PRIMARY KEY CLUSTERED ([FdpTakeRateFeatureMixAuditId] ASC),
    CONSTRAINT [FK_Fdp_TakeRateFeatureMixAudit_Fdp_TakeRateFeatureMix] FOREIGN KEY ([FdpTakeRateFeatureMixId]) REFERENCES [dbo].[Fdp_TakeRateFeatureMix] ([FdpTakeRateFeatureMixId])
);

