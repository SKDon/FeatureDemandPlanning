CREATE TABLE [dbo].[Fdp_TakeRateSummaryAudit] (
    [FdpTakeRateSummaryAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [AuditOn]                   DATETIME       NOT NULL,
    [AuditBy]                   NVARCHAR (25)  NOT NULL,
    [FdpTakeRateSummaryId]      INT            NOT NULL,
    [Volume]                    INT            NOT NULL,
    [PercentageTakeRate]        DECIMAL (5, 2) NOT NULL,
    CONSTRAINT [PK_Fdp_TakeRateSummaryAudit] PRIMARY KEY CLUSTERED ([FdpTakeRateSummaryAuditId] ASC),
    CONSTRAINT [FK_Fdp_TakeRateSummaryAudit_Fdp_TakeRateSummary] FOREIGN KEY ([FdpTakeRateSummaryId]) REFERENCES [dbo].[Fdp_TakeRateSummary] ([FdpTakeRateSummaryId])
);

