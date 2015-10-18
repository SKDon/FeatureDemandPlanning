CREATE TABLE [dbo].[Fdp_OxoVolumeDataItemNote] (
    [FdpOxoVolumeDataItemNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpOxoVolumeDataItemId]     INT            NULL,
    [EnteredOn]                  DATETIME       NULL,
    [EnteredBy]                  NVARCHAR (16)  NULL,
    [Note]                       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_OxoVolumeDataItemNote] PRIMARY KEY CLUSTERED ([FdpOxoVolumeDataItemNoteId] ASC),
    CONSTRAINT [FK_Fdp_OxoVolumeDataItemNote_Fdp_OxoVolumeDataItem] FOREIGN KEY ([FdpOxoVolumeDataItemId]) REFERENCES [dbo].[Fdp_OxoVolumeDataItem] ([FdpOxoVolumeDataItemId])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoVolumeDataItemNote_FdpOxoVolumeDataItemId]
    ON [dbo].[Fdp_OxoVolumeDataItemNote]([FdpOxoVolumeDataItemNoteId] ASC, [EnteredOn] DESC);

