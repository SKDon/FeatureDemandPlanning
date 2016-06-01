CREATE TABLE [dbo].[Fdp_PivotData] (
    [FdpPivotDataId]                   INT             IDENTITY (1, 1) NOT NULL,
    [FdpPivotHeaderId]                 INT             NOT NULL,
    [DisplayOrder]                     INT             NULL,
    [FeatureGroup]                     NVARCHAR (200)  NULL,
    [FeatureSubGroup]                  NVARCHAR (200)  NULL,
    [FeatureCode]                      NVARCHAR (20)   NULL,
    [BrandDescription]                 NVARCHAR (2000) NULL,
    [FeatureId]                        INT             NULL,
    [FeaturePackId]                    INT             NULL,
    [FeatureComment]                   NVARCHAR (MAX)  NULL,
    [FeatureRuleText]                  NVARCHAR (MAX)  NULL,
    [SystemDescription]                NVARCHAR (200)  NULL,
    [HasRule]                          BIT             NOT NULL,
    [LongDescription]                  NVARCHAR (MAX)  NULL,
    [Volume]                           INT             NOT NULL,
    [PercentageTakeRate]               DECIMAL (5, 4)  NOT NULL,
    [OxoCode]                          NVARCHAR (100)  NULL,
    [ModelId]                          INT             NOT NULL,
    [StringIdentifier]                 NVARCHAR (10)   NOT NULL,
    [FeatureIdentifier]                NVARCHAR (10)   NOT NULL,
    [ExclusiveFeatureGroup]            NVARCHAR (100)  NULL,
    [IsOrphanedData]                   BIT             NOT NULL,
    [IsIgnoredData]                    BIT             NOT NULL,
    [IsMappedToMultipleImportFeatures] BIT             NOT NULL,
    CONSTRAINT [PK_Fdp_PivotData] PRIMARY KEY CLUSTERED ([FdpPivotDataId] ASC),
    CONSTRAINT [FK_Fdp_PivotData_Fdp_PivotHeader] FOREIGN KEY ([FdpPivotHeaderId]) REFERENCES [dbo].[Fdp_PivotHeader] ([FdpPivotHeaderId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_PivotData_Cover]
    ON [dbo].[Fdp_PivotData]([FdpPivotHeaderId] ASC, [FeatureCode] ASC, [FeatureId] ASC, [FeaturePackId] ASC, [ModelId] ASC, [StringIdentifier] ASC, [FeatureIdentifier] ASC);


GO
ALTER INDEX [Ix_NC_Fdp_PivotData_Cover]
    ON [dbo].[Fdp_PivotData] DISABLE;

