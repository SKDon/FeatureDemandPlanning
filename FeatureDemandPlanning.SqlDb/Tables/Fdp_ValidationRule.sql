CREATE TABLE [dbo].[Fdp_ValidationRule] (
    [FdpValidationRuleId] INT            NOT NULL,
    [Rule]                NVARCHAR (50)  NOT NULL,
    [Description]         NVARCHAR (MAX) NULL,
    [IsActive]            BIT            CONSTRAINT [DF_Fdp_ValidationRule_IsActive] DEFAULT ((1)) NOT NULL,
    [ValidationOrder]     INT            CONSTRAINT [DF__Fdp_Valid__Valid__04859529] DEFAULT ((0)) NOT NULL,
    [StoredProcedureName] NVARCHAR (100) NULL,
    CONSTRAINT [PK_Fdp_ValidationRule] PRIMARY KEY CLUSTERED ([FdpValidationRuleId] ASC)
);





