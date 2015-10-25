﻿CREATE TABLE [dbo].[Fdp_VolumeHeader] (
    [FdpVolumeHeaderId] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]         DATETIME      CONSTRAINT [DF_Fdp_VolumeHeader_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16) CONSTRAINT [DF_Fdp_VolumeHeader_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpImportId]       INT           NULL,
    [ProgrammeId]       INT           NOT NULL,
    [Gateway]           NVARCHAR (50) NOT NULL,
    [IsManuallyEntered] BIT           CONSTRAINT [DF_Fdp_VolumeHeader_IsManuallyEntered] DEFAULT ((1)) NOT NULL,
    [TotalVolume]       INT           CONSTRAINT [DF_Fdp_VolumeHeader_TotalVolume] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Fdp_VolumeHeader] PRIMARY KEY CLUSTERED ([FdpVolumeHeaderId] ASC),
    CONSTRAINT [FK_Fdp_VolumeHeader_Fdp_Import] FOREIGN KEY ([FdpImportId]) REFERENCES [dbo].[Fdp_Import] ([FdpImportId])
);
