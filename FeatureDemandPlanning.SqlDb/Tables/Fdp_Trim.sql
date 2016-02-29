CREATE TABLE [dbo].[Fdp_Trim] (
    [FdpTrimId]         INT             IDENTITY (1, 1) NOT NULL,
    [CreatedOn]         DATETIME        CONSTRAINT [DF_FdpTrim_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16)   CONSTRAINT [DF_FdpTrim_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ProgrammeId]       INT             NOT NULL,
    [Gateway]           NVARCHAR (100)  NOT NULL,
    [TrimName]          NVARCHAR (1000) NOT NULL,
    [TrimAbbreviation]  NVARCHAR (100)  NOT NULL,
    [TrimLevel]         NVARCHAR (1000) NOT NULL,
    [BMC]               NVARCHAR (20)   NULL,
    [DPCK]              NVARCHAR (20)   NULL,
    [IsActive]          BIT             CONSTRAINT [DF_Fdp_Trim_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]         DATETIME        NULL,
    [UpdatedBy]         NVARCHAR (16)   NULL,
    [OriginalFdpTrimId] INT             NULL,
    CONSTRAINT [PK_FdpTrim] PRIMARY KEY CLUSTERED ([FdpTrimId] ASC),
    CONSTRAINT [FK_FdpTrim_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);








GO
CREATE NONCLUSTERED INDEX [IX_NC_FdpTrim_ProgrammeId]
    ON [dbo].[Fdp_Trim]([ProgrammeId] ASC, [Gateway] ASC);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Trim_OriginalFdpTrimId]
    ON [dbo].[Fdp_Trim]([OriginalFdpTrimId] ASC);

