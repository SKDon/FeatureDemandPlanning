CREATE TABLE [dbo].[Fdp_TakeRateHeaderNote] (
    [FdpTakeRateHeaderNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpTakeRateHeaderId]     INT            NOT NULL,
    [EnteredOn]               DATETIME       CONSTRAINT [DF_Fdp_TakeRateHeaderNote_EnteredOn] DEFAULT (getdate()) NOT NULL,
    [EnteredBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_TakeRateHeaderNote_EnteredBy] DEFAULT (suser_sname()) NOT NULL,
    [Note]                    NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_TakeRateHeaderNote] PRIMARY KEY CLUSTERED ([FdpTakeRateHeaderNoteId] ASC),
    CONSTRAINT [FK_Fdp_TakeRateHeaderNote_Fdp_VolumeHeader] FOREIGN KEY ([FdpTakeRateHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_TakeRateHeaderNote_FdpTakeRateHeaderId]
    ON [dbo].[Fdp_TakeRateHeaderNote]([FdpTakeRateHeaderId] ASC);

