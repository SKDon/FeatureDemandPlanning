CREATE TABLE [dbo].[Fdp_TrimMapping] (
    [FdpTrimMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [ImportTrim]       NVARCHAR (200) NULL,
    [ProgrammeId]      INT            NULL,
    [TrimId]           INT            NULL,
    CONSTRAINT [PK__Fdp_Trim__1A7A83F3526F16A8] PRIMARY KEY CLUSTERED ([FdpTrimMappingId] ASC)
);




GO


