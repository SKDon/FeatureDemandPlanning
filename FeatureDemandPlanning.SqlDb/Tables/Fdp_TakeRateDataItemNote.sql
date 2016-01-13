CREATE TABLE [dbo].[Fdp_TakeRateDataItemNote] (
    [FdpTakeRateDataItemNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpTakeRateDataItemId]     INT            NULL,
    [FdpTakeRateSummaryId]      INT            NULL,
    [EnteredOn]                 DATETIME       CONSTRAINT [DF_Fdp_TakeRateDataItemNote_EnteredOn] DEFAULT (getdate()) NULL,
    [EnteredBy]                 NVARCHAR (16)  NULL,
    [Note]                      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_OxoVolumeDataItemNote] PRIMARY KEY CLUSTERED ([FdpTakeRateDataItemNoteId] ASC),
    CONSTRAINT [FK_Fdp_TakeRateDataItemNote_Fdp_TakeRateSummary] FOREIGN KEY ([FdpTakeRateSummaryId]) REFERENCES [dbo].[Fdp_TakeRateSummary] ([FdpTakeRateSummaryId]),
    CONSTRAINT [FK_Fdp_VolumeDataItemNote_Fdp_VolumeDataItem] FOREIGN KEY ([FdpTakeRateDataItemId]) REFERENCES [dbo].[Fdp_VolumeDataItem] ([FdpVolumeDataItemId])
);






GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoVolumeDataItemNote_FdpOxoVolumeDataItemId]
    ON [dbo].[Fdp_TakeRateDataItemNote]([FdpTakeRateDataItemNoteId] ASC, [EnteredOn] DESC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_TakeRateDataItemNote_FdpTakeRateSummaryId]
    ON [dbo].[Fdp_TakeRateDataItemNote]([FdpTakeRateSummaryId] ASC);

