CREATE TABLE [dbo].[Fdp_ValidationRule] (
    [FdpValidationRuleId] INT            IDENTITY (1, 1) NOT NULL,
    [Rule]                NVARCHAR (50)  NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [IsActive]            BIT            CONSTRAINT [DF_Fdp_ValidationRule_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_ValidationRule] PRIMARY KEY CLUSTERED ([FdpValidationRuleId] ASC)
);

