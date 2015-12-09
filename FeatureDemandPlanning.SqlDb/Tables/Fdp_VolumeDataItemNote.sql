CREATE TABLE [dbo].[Fdp_VolumeDataItemNote] (
    [FdpVolumeDataItemNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpVolumeDataItemId]     INT            NULL,
    [EnteredOn]               DATETIME       NULL,
    [EnteredBy]               NVARCHAR (16)  NULL,
    [Note]                    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_OxoVolumeDataItemNote] PRIMARY KEY CLUSTERED ([FdpVolumeDataItemNoteId] ASC),
    CONSTRAINT [FK_Fdp_VolumeDataItemNote_Fdp_VolumeDataItem] FOREIGN KEY ([FdpVolumeDataItemId]) REFERENCES [dbo].[Fdp_VolumeDataItem] ([FdpVolumeDataItemId])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoVolumeDataItemNote_FdpOxoVolumeDataItemId]
    ON [dbo].[Fdp_VolumeDataItemNote]([FdpVolumeDataItemNoteId] ASC, [EnteredOn] DESC);

