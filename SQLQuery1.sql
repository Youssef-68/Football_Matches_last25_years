-- Select Primier League All Matches
SELECT 
    mn.match_date,
    d.division_name,
    ht.team_name AS home_team,
    at.team_name AS away_team,
    mn.ft_home_goals,
    mn.ft_away_goals,
    mn.ft_result,
    mn.ht_home_goals,
    mn.ht_away_goals,
    mn.ht_result,
    mn.form3_home,
    mn.form5_home,
    mn.form3_away,
    mn.form5_away,
    mn.odd_home,
    mn.odd_draw,
    mn.odd_away
FROM Matches_Normalized mn
JOIN Divisions d ON mn.division_id = d.division_id
JOIN Teams ht ON mn.home_team_id = ht.team_id
JOIN Teams at ON mn.away_team_id = at.team_id
WHERE d.division_name = 'E0'
ORDER BY mn.match_date, d.division_name, ht.team_name;