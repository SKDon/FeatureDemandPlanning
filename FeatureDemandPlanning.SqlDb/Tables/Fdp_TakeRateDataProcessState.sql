CREATE TABLE [dbo].[Fdp_TakeRateDataProcessState] (
    [FdpTakeRateDataProcessStateId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpImportId]                   INT            NULL,
    [FdpVolumeHeaderId]             INT            NULL,
    [State]                         NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_TakeRateDataProcessState] PRIMARY KEY CLUSTERED ([FdpTakeRateDataProcessStateId] ASC)
);

