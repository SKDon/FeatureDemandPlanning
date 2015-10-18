CREATE TABLE [dbo].[Fdp_OxoVolume] (
    [FdpOxoVolumeId] INT           IDENTITY (1, 1) NOT NULL,
    [FdpOxoDocId]    INT           NULL,
    [CreatedBy]      NVARCHAR (16) CONSTRAINT [DF_Fdp_OxoVolume_CreatedBy] DEFAULT (suser_sname()) NULL,
    [CreatedOn]      DATETIME      CONSTRAINT [DF_Fdp_OxoVolume_CreatedOn] DEFAULT (getdate()) NULL,
    [TotalVolume]    INT           CONSTRAINT [DF_Fdp_OxoVolume_TotalVolume] DEFAULT ((0)) NOT NULL,
    [UpdatedBy]      NVARCHAR (16) NULL,
    [UpdatedOn]      DATETIME      NULL,
    CONSTRAINT [PK_FdpOxoVolume] PRIMARY KEY CLUSTERED ([FdpOxoVolumeId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoVolume_FdpOxoDocId]
    ON [dbo].[Fdp_OxoVolume]([FdpOxoDocId] ASC, [TotalVolume] ASC);

