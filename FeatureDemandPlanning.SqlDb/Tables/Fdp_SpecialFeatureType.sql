CREATE TABLE [dbo].[Fdp_SpecialFeatureType] (
    [FdpSpecialFeatureTypeId] INT            NOT NULL,
    [SpecialFeatureType]      NVARCHAR (50)  NOT NULL,
    [Description]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_SpecialFeatureType] PRIMARY KEY CLUSTERED ([FdpSpecialFeatureTypeId] ASC)
);

