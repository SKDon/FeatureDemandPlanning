CREATE TABLE [dbo].[Fdp_MarketReviewStatus] (
    [FdpMarketReviewStatusId] INT            NOT NULL,
    [Status]                  NVARCHAR (100) NOT NULL,
    [Description]             NVARCHAR (MAX) NOT NULL,
    [IsActive]                BIT            CONSTRAINT [DF_Fdp_MarketReviewStatus_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_MarketReviewStatus] PRIMARY KEY CLUSTERED ([FdpMarketReviewStatusId] ASC)
);

