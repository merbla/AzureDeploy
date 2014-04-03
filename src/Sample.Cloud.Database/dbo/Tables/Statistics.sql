CREATE TABLE [dbo].[Statistics] (
    [Id]                INT              IDENTITY (1, 1) NOT NULL,
    [Value]             INT              NOT NULL,
    [Quarter]           INT              NOT NULL,
    [StatisticDateTime] DATETIME         NOT NULL,
    [ModelId]           UNIQUEIDENTIFIER NOT NULL,
    [Created]           DATETIME         NOT NULL,
    [LastModified]      DATETIME         NOT NULL,
    [CreatedBy]         NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy]     NVARCHAR (MAX)   NULL,
    [Team_Id]           INT              NULL,
    [StatisticType_Id]  INT              NULL,
    [Game_Id]           INT              NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Statistic_Game] FOREIGN KEY ([Game_Id]) REFERENCES [dbo].[Games] ([Id]),
    CONSTRAINT [Statistic_StatisticType] FOREIGN KEY ([StatisticType_Id]) REFERENCES [dbo].[StatisticTypes] ([Id]),
    CONSTRAINT [Statistic_Team] FOREIGN KEY ([Team_Id]) REFERENCES [dbo].[Teams] ([Id])
);

