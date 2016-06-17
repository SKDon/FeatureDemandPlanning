CREATE TABLE [dbo].[Fdp_TakeRateDataItemNote] (
    [FdpTakeRateDataItemNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpTakeRateDataItemId]     INT            NULL,
    [FdpTakeRateSummaryId]      INT            NULL,
    [FdpTakeRateFeatureMixId]   INT            NULL,
    [EnteredOn]                 DATETIME       CONSTRAINT [DF_Fdp_TakeRateDataItemNote_EnteredOn] DEFAULT (getdate()) NULL,
    [EnteredBy]                 NVARCHAR (16)  NULL,
    [Note]                      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_OxoVolumeDataItemNote] PRIMARY KEY CLUSTERED ([FdpTakeRateDataItemNoteId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Fdp_TakeRateDataItemNote_Fdp_TakeRateFeatureMix] FOREIGN KEY ([FdpTakeRateFeatureMixId]) REFERENCES [dbo].[Fdp_TakeRateFeatureMix] ([FdpTakeRateFeatureMixId]),
    CONSTRAINT [FK_Fdp_TakeRateDataItemNote_Fdp_TakeRateSummary] FOREIGN KEY ([FdpTakeRateSummaryId]) REFERENCES [dbo].[Fdp_TakeRateSummary] ([FdpTakeRateSummaryId]),
    CONSTRAINT [FK_Fdp_VolumeDataItemNote_Fdp_VolumeDataItem] FOREIGN KEY ([FdpTakeRateDataItemId]) REFERENCES [dbo].[Fdp_VolumeDataItem] ([FdpVolumeDataItemId])
);








GO



GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_TakeRateDataItemNote_Cover]
    ON [dbo].[Fdp_TakeRateDataItemNote]([FdpTakeRateDataItemId] ASC, [FdpTakeRateSummaryId] ASC, [FdpTakeRateFeatureMixId] ASC)
    INCLUDE([EnteredOn], [EnteredBy], [Note]);

