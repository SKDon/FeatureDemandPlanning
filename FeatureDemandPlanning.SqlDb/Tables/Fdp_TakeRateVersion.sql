﻿CREATE TABLE [dbo].[Fdp_TakeRateVersion] (
    [FdpTakeRateVersionId] INT IDENTITY (1, 1) NOT NULL,
    [FdpTakeRateHeaderId]  INT NOT NULL,
    [MajorVersion]         INT NOT NULL,
    [MinorVersion]         INT NOT NULL,
    [Revision]             INT NOT NULL,
    CONSTRAINT [PK_FdpTakeRateVersion] PRIMARY KEY CLUSTERED ([FdpTakeRateVersionId] ASC),
    CONSTRAINT [FK_FdpTakeRateVersion_Fdp_VolumeHeader] FOREIGN KEY ([FdpTakeRateHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId])
);




GO
CREATE NONCLUSTERED INDEX [IX_NC_FdpTakeRateVersion_FdpTakeRateHeaderId]
    ON [dbo].[Fdp_TakeRateVersion]([FdpTakeRateHeaderId] ASC);

