CREATE TABLE [dbo].[OXO_Gateway] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Gateway]       NVARCHAR (50) NULL,
    [Display_Order] INT           NULL,
    CONSTRAINT [PK_OXO_Gateway] PRIMARY KEY CLUSTERED ([Id] ASC)
);

