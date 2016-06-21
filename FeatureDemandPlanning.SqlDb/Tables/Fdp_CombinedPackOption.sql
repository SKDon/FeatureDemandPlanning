CREATE TABLE [dbo].[Fdp_CombinedPackOption] (
    [FdpCombinedPackOptionId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId]       INT            NOT NULL,
    [MarketId]                INT            NOT NULL,
    [ModelId]                 INT            NULL,
    [FeatureId]               INT            NOT NULL,
    [Volume]                  INT            CONSTRAINT [DF_Fdp_CombinedPackOption_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]      DECIMAL (5, 4) CONSTRAINT [DF_Fdp_CombinedPackOption_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Fdp_CombinedPackOption] PRIMARY KEY CLUSTERED ([FdpCombinedPackOptionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_CombinedPackOption_Cover]
    ON [dbo].[Fdp_CombinedPackOption]([FdpVolumeHeaderId] ASC, [MarketId] ASC, [ModelId] ASC, [FeatureId] ASC);

