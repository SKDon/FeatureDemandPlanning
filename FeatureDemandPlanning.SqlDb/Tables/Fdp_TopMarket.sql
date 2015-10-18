CREATE TABLE [dbo].[Fdp_TopMarket] (
    [FdpTopMarketId] INT           IDENTITY (1, 1) NOT NULL,
    [MarketId]       INT           NOT NULL,
    [CreatedOn]      DATETIME      CONSTRAINT [DF_Fdp_TopMarket_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      NVARCHAR (16) NOT NULL,
    [IsActive]       BIT           CONSTRAINT [DF_Fdp_TopMarket_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_FdpTopMarket] PRIMARY KEY CLUSTERED ([FdpTopMarketId] ASC)
);

