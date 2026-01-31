-- Goals in First Half, Second Half, Total Match 
SELECT 
	d.division_name,
	SUM(m.ft_home_goals + m.ft_away_goals) AS total_goals,
	SUM(m.ht_home_goals) AS h1_home_goals,
	SUM(m.ht_away_goals) AS h1_away_goals,
	SUM(m.ft_home_goals - m.ht_home_goals) AS h2_home_goals,
	SUM(m.ft_away_goals - m.ht_away_goals) AS h2_away_goals,
	SUM(m.ft_home_goals) AS ft_home_goals,
	SUM(m.ft_away_goals) AS ft_away_goals
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Goals Percentage in First Half, Second Half, Total Match 
SELECT 
	d.division_name,
	SUM(m.ft_home_goals + m.ft_away_goals) AS total_goals,
	SUM(m.ht_home_goals) * 100.0 / NULLIF(SUM(m.ft_home_goals + m.ft_away_goals), 0) AS h1_home_goals_pct,
	SUM(m.ht_away_goals) * 100.0 / NULLIF(SUM(m.ft_home_goals + m.ft_away_goals), 0) AS h1_away_goals_pct,
	SUM(m.ft_home_goals - m.ht_home_goals) * 100.0 / NULLIF(SUM(m.ft_home_goals + m.ft_away_goals), 0) AS h2_home_goals_pct,
	SUM(m.ft_away_goals - m.ht_away_goals) * 100.0 / NULLIF(SUM(m.ft_home_goals + m.ft_away_goals), 0) AS h2_away_goals_pct
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Decided & Comeback Rate
SELECT
    d.division_name,
    COUNT(*) AS total_matches,
    SUM(CASE 
        WHEN m.ht_result = m.ft_result THEN 1 
        ELSE 0 
    END) * 100.0 / COUNT(*) AS decided_from_ht_pct,
	SUM(CASE
        WHEN m.ht_result = 'H' AND m.ft_result = 'A' THEN 1
        WHEN m.ht_result = 'A' AND m.ft_result = 'H' THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS comeback_rate
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Measures home advantage using win rate and average goal difference
SELECT
    d.division_name,
    SUM(CASE WHEN m.ft_result = 'H' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS home_win_pct,
	SUM(CASE WHEN m.ft_result = 'D' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS draw_win_pct,
	SUM(CASE WHEN m.ft_result = 'A' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS away_win_pct
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Shows the pure impact of home advantage
SELECT
    d.division_name,
    SUM(CASE 
		WHEN m.form5_home < m.form5_away AND m.ft_result = 'H' THEN 1
        ELSE 0 END) * 100.0 / COUNT(*) AS home_upset_pct,
	SUM(CASE 
		WHEN m.form5_away < m.form5_home AND m.ft_result = 'A' THEN 1
        ELSE 0 END) * 100.0 / COUNT(*) AS away_upset_pct,
	SUM(CASE 
		WHEN m.form5_home > m.form5_away AND m.ft_result = 'H' THEN 1
        ELSE 0 END) * 100.0 / COUNT(*) AS home_succ_rate,
	SUM(CASE 
		WHEN m.form5_away > m.form5_home AND m.ft_result = 'A' THEN 1
        ELSE 0 END) * 100.0 / COUNT(*) AS away_succ_rate
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Compares short-term (3 matches) vs medium-term (5 matches) form spread
SELECT
    d.division_name,
    AVG(m.form3_home) AS avg_form3_home,
    AVG(m.form5_home) AS avg_form5_home,
	AVG(m.form3_away) AS avg_form3_away,
    AVG(m.form5_away) AS avg_form5_away
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Odds accuracy: checks if the favorite (lower odd) actually won
SELECT
    d.division_name,
    SUM(CASE
        WHEN m.odd_home < m.odd_away AND m.ft_result = 'H' THEN 1
        WHEN m.odd_away < m.odd_home AND m.ft_result = 'A' THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS odds_accuracy,

	100.0/AVG(
        CASE 
		WHEN m.ft_result = 'H' THEN m.odd_home
        WHEN m.ft_result = 'A' THEN m.odd_away
        ELSE m.odd_draw 
	    END) AS avg_winning_odd_pct

FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;

-- Identifies attacking vs defensive leagues
SELECT
    d.division_name,
    AVG(m.ft_home_goals + m.ft_away_goals) AS avg_goals_per_match,
    AVG(ABS(m.ft_home_goals - m.ft_away_goals)) AS avg_goal_difference
FROM Matches_Normalized m
JOIN Divisions d ON m.division_id = d.division_id
WHERE d.division_name IN (
    'E0',
    'SP1',
    'D1',
    'I1',
    'F1'
)
GROUP BY d.division_name
ORDER BY d.division_name DESC;