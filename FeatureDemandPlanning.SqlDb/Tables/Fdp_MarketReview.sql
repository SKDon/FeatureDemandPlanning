CREATE TABLE [dbo].[Fdp_MarketReview] (
    [FdpMarketReviewId] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]         DATETIME      CONSTRAINT [DF_Table_1_CreatedBy] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16) CONSTRAINT [DF_Fdp_MarketReview_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId] INT           NOT NULL,
    [MarketId]          INT           NOT NULL,
    [IsActive]          BIT           CONSTRAINT [DF_Fdp_MarketReview_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_MarketReview] PRIMARY KEY CLUSTERED ([FdpMarketReviewId] ASC),
    CONSTRAINT [FK_Fdp_MarketReview_Fdp_VolumeHeader] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_MarketReview_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);

