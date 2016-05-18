CREATE TABLE [dbo].[Fdp_FeatureApplicability] (
    [FeatureApplicabilityId] INT            IDENTITY (1, 1) NOT NULL,
    [DocumentId]             INT            NOT NULL,
    [MarketId]               INT            NULL,
    [ModelId]                INT            NOT NULL,
    [FeatureId]              INT            NULL,
    [Applicability]          NVARCHAR (100) NOT NULL,
    [ModelIdentifier]        NVARCHAR (10)  NOT NULL,
    [FeaturePackId]          INT            NULL,
    CONSTRAINT [PK_Fdp_FeatureApplicability] PRIMARY KEY CLUSTERED ([FeatureApplicabilityId] ASC),
    CONSTRAINT [FK_Fdp_FeatureApplicability_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_FeatureApplicability_OXO_Feature_Ext] FOREIGN KEY ([FeatureId]) REFERENCES [dbo].[OXO_Feature_Ext] ([Id]),
    CONSTRAINT [FK_Fdp_FeatureApplicability_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_FeatureApplicability_OXO_Programme_Pack] FOREIGN KEY ([FeaturePackId]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_FeatureApplicability_Cover]
    ON [dbo].[Fdp_FeatureApplicability]([DocumentId] ASC, [ModelId] ASC, [FeatureId] ASC, [ModelIdentifier] ASC, [MarketId] ASC, [FeaturePackId] ASC)
    INCLUDE([Applicability]);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_FeatureApplicability_Cover2]
    ON [dbo].[Fdp_FeatureApplicability]([MarketId] ASC)
    INCLUDE([DocumentId], [ModelId], [FeatureId], [Applicability], [FeaturePackId]);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_FeatureApplicability_Cover3]
    ON [dbo].[Fdp_FeatureApplicability]([DocumentId] ASC, [FeatureId] ASC, [MarketId] ASC)
    INCLUDE([ModelId], [Applicability]);

