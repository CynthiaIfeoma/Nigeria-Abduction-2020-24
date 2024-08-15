CREATE TABLE nigeria_abductions (
    event_id_cnty VARCHAR(50),
    event_date DATE,
    year INTEGER,
    time_precision INTEGER,
    disorder_type VARCHAR(100),
    event_type VARCHAR(100),
    sub_event_type VARCHAR(100),
    actor1 VARCHAR(200),
    assoc_actor_1 VARCHAR(200),
    inter1 INTEGER,
    actor2 VARCHAR(200),
    assoc_actor_2 VARCHAR(200),
    inter2 INTEGER,
    interaction INTEGER,
    civilian_targeting VARCHAR(100),
    iso INTEGER,
    region VARCHAR(100),
    country VARCHAR(50),
    admin1 VARCHAR(100),
    admin2 VARCHAR(100),
    admin3 VARCHAR(100),
    location VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    geo_precision INTEGER,
    source VARCHAR(500),
    source_scale VARCHAR(50),
    notes TEXT,
    fatalities INTEGER,
    tags VARCHAR(200),
    timestamp BIGINT
)

--Geographical Heat Map of Abduction Events: This visualization will show the concentration of abduction incidents across different regions in Nigeria, helping to identify high-risk areas.
SELECT admin1 AS States, admin2 AS Local_Governments, location, latitude, longitude, COUNT(*) AS incident_count
FROM nigeria_abductions
GROUP BY admin1, admin2, location, latitude, longitude
ORDER BY incident_count DESC;

--Temporal Trend Analysis of Abductions by Actor: This will show how different actors' activities have changed over time, potentially revealing patterns or shifts in tactics.
SELECT DATE_TRUNC('week', event_date) AS week, actor1, COUNT(*) AS incident_count
FROM nigeria_abductions
GROUP BY week, actor1
ORDER BY week, incident_count DESC

--Abduction Tactics Analysis: This analysis will show the relationship between the type of location, time of day, and the number of abductees, helping to understand the tactics used by different groups.
SELECT 
    actor1 AS Group,
    CASE 
        WHEN admin2 LIKE '%City%' OR admin2 LIKE '%Municipal%' THEN 'Urban'
        ELSE 'Rural'
    END AS area_type,
    CASE 
        WHEN EXTRACT(HOUR FROM event_date::timestamp) BETWEEN 6 AND 18 THEN 'Day'
        ELSE 'Night'
    END AS time_of_day,
    AVG(
        CASE 
            WHEN notes ~* 'abduct|kidnap|hostage' THEN 1
            ELSE 0
        END
    ) AS abduction_rate
FROM nigeria_abductions
GROUP BY actor1, area_type, time_of_day
ORDER BY actor1, abduction_rate DESC;

--Effectiveness of Security Responses: This analysis will show different states ability to rescue abducted victims
SELECT 
    admin1 AS States,
    COUNT(*) AS total_incidents,
    SUM(CASE WHEN notes LIKE '%rescued%' THEN 1 ELSE 0 END) AS successful_rescues,
	 SUM(CASE WHEN notes NOT LIKE '%rescued%' OR fatalities > 0 THEN 1 ELSE 0 END) AS unsuccessful_rescues
FROM nigeria_abductions
GROUP BY admin1 
ORDER BY admin1;

--Network Analysis of Actor Collaborations: This analysis will reveal potential collaborations between different actors, which can be crucial for understanding the broader landscape of security threats.
SELECT 
    actor1,
    assoc_actor_1,
    COUNT(*) AS collaboration_count
FROM nigeria_abductions
WHERE assoc_actor_1 IS NOT NULL AND assoc_actor_1 != ''
GROUP BY actor1, assoc_actor_1
ORDER BY collaboration_count DESC;

--Actor Analysis: Top Perpetrators and Their Operating Areas:This analysis helps in understanding the major threat actors and their geographical focus.
SELECT 
    actor1,
    admin1,
    COUNT(*) AS event_count
FROM nigeria_abductions
GROUP BY actor1, admin1
HAVING COUNT(*) > 5
ORDER BY actor1, event_count DESC;

--Victim Profile Analysis: Understanding who is being targeted can help in developing protective strategies for vulnerable groups.
SELECT 
    CASE 
        WHEN notes LIKE '%women%' THEN 'Women'
	    WHEN notes LIKE '%men%' THEN 'Men'
        WHEN notes LIKE '%children%' THEN 'Children'
        ELSE 'Others'
    END AS victim_category,
    COUNT(*) AS event_count
FROM nigeria_abductions
GROUP BY victim_category
ORDER BY event_count DESC;

--Abduction Method and Outcome Analysis: This can provide insights into the modus operandi of perpetrators and the effectiveness of rescue operations.
SELECT 
    CASE 
        WHEN notes LIKE '%ransom%' THEN 'Ransom Demanded'
        WHEN notes IS NULL OR notes = '' THEN 'Unknown'
        ELSE 'No Ransom Mentioned'
    END AS ransom_status,
    CASE 
        WHEN notes LIKE '%rescued%' OR notes LIKE '%released%' THEN 'Rescued/Released'
        ELSE 'Unknown'
    END AS outcome,
    COUNT(*) AS event_count
FROM nigeria_abductions
GROUP BY ransom_status, outcome
ORDER BY ransom_status, outcome;




