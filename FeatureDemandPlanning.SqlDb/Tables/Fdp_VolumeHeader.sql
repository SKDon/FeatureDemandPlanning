CREATE TABLE [dbo].[Fdp_VolumeHeader] (
    [FdpVolumeHeaderId]   INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]           DATETIME      CONSTRAINT [DF_Fdp_VolumeHeader_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           NVARCHAR (16) CONSTRAINT [DF_Fdp_VolumeHeader_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [DocumentId]          INT           NOT NULL,
    [IsManuallyEntered]   BIT           CONSTRAINT [DF_Fdp_VolumeHeader_IsManuallyEntered] DEFAULT ((1)) NOT NULL,
    [TotalVolume]         INT           CONSTRAINT [DF_Fdp_VolumeHeader_TotalVolume] DEFAULT ((0)) NOT NULL,
    [FdpTakeRateStatusId] INT           NOT NULL,
    [UpdatedOn]           DATETIME      NULL,
    [UpdatedBy]           NVARCHAR (16) NULL,
    CONSTRAINT [PK_Fdp_VolumeHeader] PRIMARY KEY CLUSTERED ([FdpVolumeHeaderId] ASC),
    CONSTRAINT [FK_Fdp_VolumeHeader_Fdp_TakeRateStatus] FOREIGN KEY ([FdpTakeRateStatusId]) REFERENCES [dbo].[Fdp_TakeRateStatus] ([FdpTakeRateStatusId]),
    CONSTRAINT [FK_Fdp_VolumeHeader_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_VolumeHeader_FdpTakeRateStatusId]
    ON [dbo].[Fdp_VolumeHeader]([FdpTakeRateStatusId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_VolumeHeader_DocumentId]
    ON [dbo].[Fdp_VolumeHeader]([DocumentId] ASC);

