CREATE TABLE [dbo].[Fdp_ForecastComparison] (
    [ForecastComparisonId] INT           IDENTITY (1, 1) NOT NULL,
    [ForecastId]           INT           NOT NULL,
    [ForecastVehicleId]    INT           NOT NULL,
    [CreatedOn]            DATETIME      CONSTRAINT [DF_Fdp_ForecastComparison_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            NVARCHAR (16) CONSTRAINT [DF_Fdp_ForecastComparison_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [SortOrder]            INT           CONSTRAINT [DF_Fdp_ForecastComparison_SortOrder] DEFAULT ((1)) NOT NULL,
    [IsActive]             BIT           CONSTRAINT [DF_Fdp_ForecastComparison_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_ForecastComparison] PRIMARY KEY CLUSTERED ([ForecastComparisonId] ASC),
    CONSTRAINT [FK_Fdp_ForecastComparison_Fdp_Forecast] FOREIGN KEY ([ForecastId]) REFERENCES [dbo].[Fdp_Forecast] ([Id]),
    CONSTRAINT [FK_Fdp_ForecastComparison_Fdp_ForecastVehicle] FOREIGN KEY ([ForecastVehicleId]) REFERENCES [dbo].[Fdp_ForecastVehicle] ([ForecastVehicleId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ux_Fdp_ForecastComparison_ForecastComparisonVehicle]
    ON [dbo].[Fdp_ForecastComparison]([ForecastId] ASC, [ForecastVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ux_Fdp_ForecastComparison_SortOrder]
    ON [dbo].[Fdp_ForecastComparison]([ForecastId] ASC, [SortOrder] ASC);

