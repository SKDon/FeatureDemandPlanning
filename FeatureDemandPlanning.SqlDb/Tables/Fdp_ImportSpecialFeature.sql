CREATE TABLE [dbo].[Fdp_ImportSpecialFeature] (
    [FdpImportSpecialFeatureId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpImportId]               INT            NOT NULL,
    [FeatureCode]               NVARCHAR (20)  NOT NULL,
    [FeatureDescription]        NVARCHAR (MAX) NOT NULL,
    [FdpSpecialFeatureTypeId]   INT            NOT NULL,
    CONSTRAINT [PK_Fdp_Import_SpecialFeature] PRIMARY KEY CLUSTERED ([FdpImportSpecialFeatureId] ASC),
    CONSTRAINT [FK_Fdp_Import_SpecialFeature_Fdp_Import] FOREIGN KEY ([FdpImportId]) REFERENCES [dbo].[Fdp_Import] ([FdpImportId]),
    CONSTRAINT [FK_Fdp_Import_SpecialFeature_Fdp_SpecialFeatureType] FOREIGN KEY ([FdpSpecialFeatureTypeId]) REFERENCES [dbo].[Fdp_SpecialFeatureType] ([FdpSpecialFeatureTypeId])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Import_SpecialFeature_FdpImportId]
    ON [dbo].[Fdp_ImportSpecialFeature]([FdpImportId] ASC);

