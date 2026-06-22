--hledání duplicit

SELECT
    respondent_id,
    COUNT(*)
FROM demo2
GROUP BY respondent_id
HAVING COUNT(*) > 1;

SELECT
    respondent_id,
    COUNT(*)
FROM bmx2 b 
GROUP BY respondent_id
HAVING COUNT(*) > 1
;

-- ověření, že spojení tabulek nevytváří násobné záznamy

SELECT d2.respondent_id, COUNT(b2.respondent_id)
FROM demo2 d2
LEFT JOIN bmx2 b2
  ON d2.respondent_id = b2.respondent_id
GROUP BY d2.respondent_id
HAVING COUNT(b2.respondent_id) > 1
;


--outliery

SELECT 
    MIN(b2.bmi) AS min_bmi,
    MAX(b2.bmi) AS max_bmi,
    MIN(d2.vek) AS min_vek,
    MAX(d2.vek) AS max_vek,
    MIN(d2.prijem_chudoba) AS min_prijem,
    MAX(d2.prijem_chudoba) AS max_prijem
FROM demo2 d2
JOIN bmx2 b2
  ON d2.respondent_id = b2.respondent_id
WHERE d2.vek IS NOT NULL
  AND b2.bmi IS NOT NULL
  AND d2.prijem_chudoba IS NOT NULL
;


--interkvartilové rozpětí, z něhož si můžeme odvodit outliery

WITH kvartil AS (
SELECT
    ROUND(MIN(bmi)::numeric, 2) AS min_bmi,
    ROUND((percentile_cont(0.25) WITHIN GROUP (ORDER BY bmi))::numeric, 2) AS q1,
    ROUND((percentile_cont(0.5)  WITHIN GROUP (ORDER BY bmi))::numeric, 2) AS median,
    ROUND((percentile_cont(0.75) WITHIN GROUP (ORDER BY bmi))::numeric, 2) AS q3,
    ROUND(MAX(bmi)::numeric, 2) AS max_bmi
FROM demo2 d2
JOIN bmx2 b2
  ON d2.respondent_id = b2.respondent_id
WHERE bmi IS NOT NULL
  AND vek > 17
)
SELECT
    q1,
    median,
    q3,
    min_bmi,
    max_bmi,
    ROUND(q3 - q1, 2) AS iqr,
    ROUND(q1 - 1.5 * (q3 - q1), 2) AS dolni_hranice,
    ROUND(q3 + 1.5 * (q3 - q1), 2) AS horni_hranice
FROM kvartil
;


--zjištění outlierů a procento z celé populace

WITH hranice AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (ORDER BY bmi) AS q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY bmi) AS q3
    FROM demo2 d2
    JOIN bmx2 b2
        ON d2.respondent_id = b2.respondent_id
    WHERE d2.vek > 17
      AND bmi IS NOT NULL
),
vypocet AS (
    SELECT
        (q3 + 1.5 * (q3 - q1)) AS horni_hranice
    FROM hranice
)
SELECT
    COUNT(*) AS pocet_outlieru,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM demo2 d2
         JOIN bmx2 b2
           ON d2.respondent_id = b2.respondent_id
         WHERE d2.vek > 17),
        2
    ) AS procento
FROM demo2 d2
JOIN bmx2 b2
  ON d2.respondent_id = b2.respondent_id
CROSS JOIN vypocet v
WHERE d2.vek > 17
  AND b2.bmi > v.horni_hranice
;


-- Kontrola minimálních hodnot BMI u dospělých jedinců

SELECT 
bmi
FROM bmx2 b
JOIN demo2 d
    ON b.respondent_id = d.respondent_id
WHERE vek > 17
ORDER BY
bmi asc
LIMIT 10
;

--rozdělení podle věkových kategorií a příjmové skupiny společně s průměrným bmi a n (počet respondentů)

WITH hranice AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (ORDER BY bmi) AS q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY bmi) AS q3
    FROM demo2 d2
    JOIN bmx2 b2
        ON d2.respondent_id = b2.respondent_id
    WHERE d2.vek > 17
      AND b2.bmi IS NOT NULL
),
vypocet AS (
    SELECT
        q1 - 1.5 * (q3 - q1) AS dolni_hranice
    FROM hranice
),
pohled AS (
    SELECT
        *,
        CASE
            WHEN prijem_chudoba < 1 THEN 'pod_hranici_chudoby'
            WHEN prijem_chudoba < 2 THEN 'nizky_prijem'
            WHEN prijem_chudoba < 4 THEN 'stredni_prijem'
            ELSE 'vysoky_prijem'
        END AS prijmova_skupina,
        CASE
            WHEN vek < 18 THEN '0-17'
            WHEN vek < 30 THEN '18-29'
            WHEN vek < 45 THEN '30-44'
            WHEN vek < 60 THEN '45-59'
            ELSE '60+'
        END AS vekova_skupina
    FROM demo2 d2
    JOIN bmx2 b2
        ON d2.respondent_id = b2.respondent_id
    CROSS JOIN vypocet v
    WHERE bmi IS NOT NULL
      AND d2.prijem_chudoba IS NOT NULL
      AND vek > 17
      AND bmi > v.dolni_hranice
)
SELECT
    prijmova_skupina,
    vekova_skupina,
    COUNT(*) AS pocet,
    ROUND(AVG(bmi)::numeric, 2) AS prumerne_bmi
FROM pohled
GROUP BY 1, 2
ORDER BY vekova_skupina DESC
;
