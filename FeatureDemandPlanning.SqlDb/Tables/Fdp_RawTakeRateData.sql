CREATE TABLE [dbo].[Fdp_RawTakeRateData] (
    [ProcessId]          UNIQUEIDENTIFIER NOT NULL,
    [FeatureId]          INT              NULL,
    [FeaturePackId]      INT              NULL,
    [ModelId]            INT              NULL,
    [Volume]             INT              NULL,
    [PercentageTakeRate] DECIMAL (5, 4)   NULL,
    [IsOrphanedData]     BIT              NOT NULL,
    [FdpVolumeHeaderId]  INT              NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_RawTakeRateData_ProcessId]
    ON [dbo].[Fdp_RawTakeRateData]([ProcessId] ASC)
    INCLUDE([FeatureId], [FeaturePackId], [ModelId], [Volume], [PercentageTakeRate], [IsOrphanedData], [FdpVolumeHeaderId]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_RawTakeRateData]
    ON [dbo].[Fdp_RawTakeRateData]([ProcessId] ASC, [FeatureId] ASC, [FeaturePackId] ASC, [ModelId] ASC, [FdpVolumeHeaderId] ASC);

