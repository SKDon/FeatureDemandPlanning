CREATE TABLE [dbo].[Fdp_ImportFeatureDescription] (
    [FdpImportFeatureDescriptionId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId]             INT            NOT NULL,
    [MappedFeatureCode]             NVARCHAR (10)  NOT NULL,
    [ImportFeatureCode]             NVARCHAR (10)  NOT NULL,
    [FeatureDescription]            NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_ImportFeatureDescription] PRIMARY KEY CLUSTERED ([FdpImportFeatureDescriptionId] ASC),
    CONSTRAINT [FK_Fdp_ImportFeatureDescription_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportFeatureDescription_FdpVolumeHeaderId]
    ON [dbo].[Fdp_ImportFeatureDescription]([FdpVolumeHeaderId] ASC);

