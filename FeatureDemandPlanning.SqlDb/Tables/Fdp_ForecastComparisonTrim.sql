CREATE TABLE [dbo].[Fdp_ForecastComparisonTrim] (
    [ForecastComparisonTrimId] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]                DATETIME      CONSTRAINT [DF_Fdp_ForecastComparisonTrim_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                NVARCHAR (16) NOT NULL,
    [ForecastComparisonId]     INT           NOT NULL,
    [ForecastVehicleTrimId]    INT           NOT NULL,
    [ComparisonVehicleTrimId]  INT           NOT NULL,
    [IsActive]                 BIT           CONSTRAINT [DF_Fdp_ForecastComparisonTrim_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_ForecastComparisonTrim] PRIMARY KEY CLUSTERED ([ForecastComparisonTrimId] ASC),
    CONSTRAINT [FK_Fdp_ForecastComparisonTrim_Fdp_ForecastComparison] FOREIGN KEY ([ForecastComparisonId]) REFERENCES [dbo].[Fdp_ForecastComparison] ([ForecastComparisonId]),
    CONSTRAINT [FK_Fdp_ForecastComparisonTrim_OXO_Programme_Trim] FOREIGN KEY ([ForecastVehicleTrimId]) REFERENCES [dbo].[OXO_Programme_Trim] ([Id]),
    CONSTRAINT [FK_Fdp_ForecastComparisonTrim_OXO_Programme_Trim1] FOREIGN KEY ([ComparisonVehicleTrimId]) REFERENCES [dbo].[OXO_Programme_Trim] ([Id])
);

