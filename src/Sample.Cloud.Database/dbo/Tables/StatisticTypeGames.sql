CREATE TABLE [dbo].[StatisticTypeGames] (
    [StatisticType_Id] INT NOT NULL,
    [Game_Id]          INT NOT NULL,
    PRIMARY KEY CLUSTERED ([StatisticType_Id] ASC, [Game_Id] ASC),
    CONSTRAINT [StatisticType_Games_Source] FOREIGN KEY ([StatisticType_Id]) REFERENCES [dbo].[StatisticTypes] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [StatisticType_Games_Target] FOREIGN KEY ([Game_Id]) REFERENCES [dbo].[Games] ([Id]) ON DELETE CASCADE
);

