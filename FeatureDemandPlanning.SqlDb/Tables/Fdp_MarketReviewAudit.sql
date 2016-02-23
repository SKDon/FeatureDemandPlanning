CREATE TABLE [dbo].[Fdp_MarketReviewAudit] (
    [AuditOn]                 DATETIME       NULL,
    [AuditBy]                 NVARCHAR (16)  NULL,
    [FdpMarketReviewId]       INT            NULL,
    [FdpMarketReviewStatusId] INT            NULL,
    [Comment]                 NVARCHAR (MAX) NULL
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_MarketReviewAudit]
    ON [dbo].[Fdp_MarketReviewAudit]([AuditOn] ASC, [FdpMarketReviewId] ASC);

