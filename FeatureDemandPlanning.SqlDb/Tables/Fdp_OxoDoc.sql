CREATE TABLE [dbo].[Fdp_OxoDoc] (
    [FdpOxoDocId]       INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]         DATETIME      CONSTRAINT [DF_FDP_OXODoc_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16) CONSTRAINT [DF_FDP_OXODoc_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId] INT           NOT NULL,
    [OXODocId]          INT           NOT NULL,
    CONSTRAINT [PK_FDP_OXODoc] PRIMARY KEY CLUSTERED ([FdpOxoDocId] ASC),
    CONSTRAINT [FK_FDP_OXODoc_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_FDP_OXODoc_OXO_Doc] FOREIGN KEY ([OXODocId]) REFERENCES [dbo].[OXO_Doc] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_OxoDoc_OXODocId]
    ON [dbo].[Fdp_OxoDoc]([OXODocId] ASC);

