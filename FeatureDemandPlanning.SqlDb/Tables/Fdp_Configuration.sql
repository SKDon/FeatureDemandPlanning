CREATE TABLE [dbo].[Fdp_Configuration] (
    [ConfigurationKey] NVARCHAR (50)  NOT NULL,
    [Value]            NVARCHAR (MAX) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
    [DataType]         NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_Fdp_Configuration] PRIMARY KEY CLUSTERED ([ConfigurationKey] ASC)
);

