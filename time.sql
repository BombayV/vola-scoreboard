CREATE TABLE `time_played` (
  `license`     VARCHAR(60) NOT NULL,
  `time`      INT(12) NOT NULL DEFAULT 0,
  PRIMARY KEY (`license`)
);