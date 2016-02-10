CREATE TABLE [dbo].[Fdp_EmailTemplate] (
    [FdpEmailTemplateId] INT            NOT NULL,
    [Event]              NVARCHAR (50)  NOT NULL,
    [Subject]            NVARCHAR (MAX) NOT NULL,
    [Body]               NVARCHAR (MAX) NOT NULL,
    [IsActive]           BIT            CONSTRAINT [DF_Fdp_EmailTemplate_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_EmailTemplate] PRIMARY KEY CLUSTERED ([FdpEmailTemplateId] ASC)
);

