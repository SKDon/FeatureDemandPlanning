CREATE TABLE [dbo].[Fdp_TakeRateSummary] (
    [FdpTakeRateSummaryId]       INT           IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId]          INT           NOT NULL,
    [FdpSpecialFeatureMappingId] INT           NOT NULL,
    [MarketId]                   INT           NULL,
    [ModelId]                    INT           NULL,
    [FdpModelId]                 INT           NULL,
    [Volume]                     INT           CONSTRAINT [DF_Fdp_TakeRateSummary_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]         INT           CONSTRAINT [DF_Fdp_TakeRateSummary_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]                  DATETIME      NULL,
    [UpdatedBy]                  NVARCHAR (16) NULL,
    CONSTRAINT [PK_Fdp_TakeRateSummary] PRIMARY KEY CLUSTERED ([FdpTakeRateSummaryId] ASC)
);

