--Export tabulky z vybraných proměnných otevřeného datasetu DEMO_L projektu Nhanes

CREATE TABLE demo2 AS 
SELECT
    "SEQN" AS respondent_id,
    "RIAGENDR" AS pohlavi,
    "RIDAGEYR" AS vek,
    "RIDEXAGM" AS vek_mesice,
    "RIDRETH3" AS rasa,
    "DMDBORN4" AS zeme_narozeni,
    "DMDYRUSR" AS delka_pobytu_usa,
    "DMDEDUC2" AS vzdelani,
    "DMDMARTZ" AS socialni_status,
    "DMDHHSIZ" AS clenove_domacnost,
    "INDFMPIR" AS prijem_chudoba
FROM demo;

--Export tabulky z vybraných proměnných otevřeného datasetu BMX_L projektu Nhanes

CREATE TABLE bmx2 AS 
SELECT
	"SEQN" AS respondent_id, 
	"BMXWT" AS vaha, 
	"BMXRECUM" AS delka,
	"BMXHT" AS vyska, 
	"BMXBMI" AS bmi
FROM
bmx;
