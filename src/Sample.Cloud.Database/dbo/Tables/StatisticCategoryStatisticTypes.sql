CREATE TABLE [dbo].[StatisticCategoryStatisticTypes] (
    [StatisticCategory_Id] INT NOT NULL,
    [StatisticType_Id]     INT NOT NULL,
    PRIMARY KEY CLUSTERED ([StatisticCategory_Id] ASC, [StatisticType_Id] ASC),
    CONSTRAINT [StatisticCategory_StatisticTypes_Source] FOREIGN KEY ([StatisticCategory_Id]) REFERENCES [dbo].[StatisticCategories] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [StatisticCategory_StatisticTypes_Target] FOREIGN KEY ([StatisticType_Id]) REFERENCES [dbo].[StatisticTypes] ([Id]) ON DELETE CASCADE
);

