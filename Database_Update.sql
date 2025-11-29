-- Create basic tables
CREATE TABLE Divisions (
    division_id INT PRIMARY KEY,
    division_name VARCHAR(100)
);

CREATE TABLE Teams (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(100)
);

CREATE TABLE Matches_Normalized (
    match_id INT PRIMARY KEY,
    division_id INT,
    match_date DATE,
    home_team_id INT,
    away_team_id INT,
    ft_home_goals INT,
    ft_away_goals INT,
    ft_result CHAR(1),
    ht_home_goals INT,
    ht_away_goals INT,
    ht_result CHAR(1),
    form3_home DECIMAL(4,2),
    form5_home DECIMAL(4,2),
    form3_away DECIMAL(4,2),
    form5_away DECIMAL(4,2),
    odd_home DECIMAL(5,2),
    odd_draw DECIMAL(5,2),
    odd_away DECIMAL(5,2),
    FOREIGN KEY (division_id) REFERENCES Divisions(division_id),
    FOREIGN KEY (home_team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams(team_id)
);

-- Insert divisions
INSERT INTO Divisions (division_id, division_name)
SELECT 
    ROW_NUMBER() OVER (ORDER BY Division),
    Division 
FROM (SELECT DISTINCT Division FROM Matches) divisions;

-- Insert teams
INSERT INTO Teams (team_id, team_name)
SELECT 
    ROW_NUMBER() OVER (ORDER BY team_name),
    team_name
FROM (
    SELECT DISTINCT HomeTeam as team_name FROM Matches
    UNION 
    SELECT DISTINCT AwayTeam as team_name FROM Matches
) teams;

-- Insert matches with normalized structure
INSERT INTO Matches_Normalized (
    match_id, division_id, match_date, home_team_id, away_team_id,
    ft_home_goals, ft_away_goals, ft_result,
    ht_home_goals, ht_away_goals, ht_result,
    form3_home, form5_home, form3_away, form5_away,
    odd_home, odd_draw, odd_away
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY m.MatchDate, m.HomeTeam, m.AwayTeam),
    d.division_id,
    m.MatchDate,
    ht.team_id,
    at.team_id,
    m.FTHome,
    m.FTAway,
    m.FTResult,
    m.HTHome,
    m.HTAway,
    m.HTResult,
    m.Form3Home,
    m.Form5Home,
    m.Form3Away,
    m.Form5Away,
    m.OddHome,
    m.OddDraw,
    m.OddAway
FROM Matches m
JOIN Divisions d ON m.Division = d.division_name
JOIN Teams ht ON m.HomeTeam = ht.team_name
JOIN Teams at ON m.AwayTeam = at.team_name;