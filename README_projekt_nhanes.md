# Projekt SQL: NHANES data

## Výběr datasetu

Pro zkoumání vlivu socioekonomických faktorů na zdraví byla využita veřejně dostupná data z projektu NHANES (National Health and Nutrition Examination Survey) za období 2021–2023.

Pro analýzu byly použity dva datasety:

- **DEMO_L** – demografické údaje respondentů  
- **BMX_L** – údaje o tělesných měřeních respondentů  

Základním spojovacím klíčem mezi oběma datasety je proměnná `SEQN`, která jednoznačně identifikuje každého respondenta.

---

## Výběr proměnných

### Demografický dataset (DEMO_L)

Byly vybrány následující proměnné:

- respondent ID (primární klíč)
- pohlaví
- věk
- rasa / etnicita
- země narození
- délka pobytu v USA
- dosažené vzdělání
- rodinný stav
- počet členů domácnosti
- poměr příjmu domácnosti k hranici chudoby (`INDFMPIR`)

### Dataset tělesných měření (BMX_L)

- respondent ID
- tělesná hmotnost
- tělesná výška (případně délka těla u malých dětí)
- BMI (Body Mass Index)

---

## Hypotéza

BMI je ovlivněno socioekonomickými faktory, zejména příjmem domácnosti.

---

## Výzkumná otázka

Existuje vztah mezi příjmem domácnosti a hodnotou BMI?

Při analýze je nutné zohlednit věk respondentů, protože BMI se v průběhu života přirozeně mění.

---

## Postup analýzy

### 1. Vytvoření pracovních tabulek

Nejprve byly vytvořeny pracovní tabulky:

- `demo2`
- `bmx2`

Obsahují pouze proměnné relevantní pro plánovanou analýzu.

---

### 2. Kontrola duplicit

U obou tabulek byla provedena kontrola duplicit na základě primárního klíče `respondent_id`.

Kontrola neodhalila žádné duplicitní záznamy a bylo ověřeno, že spojení tabulek pomocí `LEFT JOIN` nevytváří duplicitní řádky.

---

### 3. Výběr proměnných pro analýzu

Pro zodpovězení výzkumné otázky byly vybrány proměnné:

- respondent_id
- věk
- BMI
- index příjmu domácnosti (`INDFMPIR`)

---

### 4. Kontrola extrémních hodnot

Nejprve byly zkontrolovány minimální a maximální hodnoty vybraných proměnných.

U proměnné `INDFMPIR` byly nalezeny hodnoty rovné 0.

Podle dokumentace NHANES však hodnota 0 nepředstavuje chybu ani odlehlou hodnotu, ale označuje domácnosti s nulovým nebo velmi nízkým příjmem. Tyto záznamy proto nebyly z analýzy odstraněny.

---

### 5. Identifikace odlehlých hodnot BMI

Pro identifikaci odlehlých hodnot BMI byla použita metoda interkvartilového rozpětí (IQR).

Protože interpretace BMI u dětí a dospívajících je odlišná od dospělé populace, byli z této části analýzy vyloučeni respondenti mladší 18 let.

#### Statistika pro dospělou populaci

| Ukazatel        | Hodnota |
|----------------|--------:|
| Q1             | 24,5    |
| Medián         | 28,3    |
| Q3             | 33,4    |
| Minimum BMI    | 11,1    |
| Maximum BMI    | 74,8    |
| IQR            | 8,9     |
| Dolní hranice  | 11,15   |
| Horní hranice  | 46,75   |

Za odlehlé hodnoty byly považovány BMI nižší než 11,15 a vyšší než 46,75.

---

### 6. Vyhodnocení horních odlehlých hodnot

Bylo zjištěno 183 respondentů s BMI vyšším než 46,75.

Tito respondenti představovali přibližně 2,89 % dospělé populace ve vzorku.

Přestože jsou tyto hodnoty statisticky odlehlé, odpovídají reálné populaci osob s těžkou obezitou. Proto nebyly z analýzy odstraněny.

---

### 7. Vyhodnocení dolních odlehlých hodnot

Byl identifikován jeden respondent s BMI 11,1.

Tato hodnota byla extrémní a představovala těžkou podváhu. Vzhledem k tomu, že šlo o jediný případ, byl tento záznam z analýzy vyloučen.

---

### 8. Analýza vztahu mezi příjmem a BMI

Respondenti byli rozděleni do čtyř příjmových skupin:

- pod hranicí chudoby  
- nízký příjem  
- střední příjem  
- vysoký příjem  

Současně byli rozděleni do věkových kategorií:

- 18–29 let  
- 30–44 let  
- 45–59 let  
- 60 a více let  

Pro každou kombinaci byla vypočtena průměrná hodnota BMI.

#### Průměrné BMI podle skupin

| Příjmová skupina | Věk   | Počet respondentů | Průměrné BMI |
|------------------|------|------------------:|-------------:|
| nízký příjem     | 60+  | 489               | 29,69 |
| pod hranicí chudoby | 60+ | 289            | 30,39 |
| střední příjem   | 60+  | 736               | 29,80 |
| vysoký příjem    | 60+  | 846               | 28,91 |
| nízký příjem     | 45–59| 212               | 31,22 |
| pod hranicí chudoby | 45–59 | 195          | 30,78 |
| střední příjem   | 45–59| 289               | 31,33 |
| vysoký příjem    | 45–59| 424               | 30,72 |
| nízký příjem     | 30–44| 232               | 31,68 |
| pod hranicí chudoby | 30–44 | 211          | 31,37 |
| střední příjem   | 30–44| 317               | 30,87 |
| vysoký příjem    | 30–44| 406               | 28,20 |
| nízký příjem     | 18–29| 164               | 28,20 |
| pod hranicí chudoby | 18–29 | 175          | 27,64 |
| střední příjem   | 18–29| 247               | 27,83 |
| vysoký příjem    | 18–29| 190               | 26,59 |

Směrodatná odchylka BMI se pohybovala přibližně mezi 6 a 9 body, což ukazuje na vysokou variabilitu uvnitř skupin.

---

## Výsledky

Ve všech věkových kategoriích vykazovali respondenti s vysokým příjmem nejnižší průměrné BMI.

Největší rozdíl byl ve skupině 30–44 let:

- nízký příjem: **31,68**
- vysoký příjem: **28,20**
- rozdíl: **3,48 BMI**

Ve skupině 45–59 let byl rozdíl pouze 0,61 BMI.

Výsledky naznačují, že vyšší příjem domácnosti souvisí s nižším BMI, přičemž nejvýraznější vztah je ve věku 30–44 let.

---

## Závěr

Analýza dat NHANES 2021–2023 naznačuje existenci vztahu mezi příjmem domácnosti a BMI. Ve všech věkových kategoriích měli respondenti s vyšším příjmem nižší průměrné BMI než respondenti s nižším příjmem.

Nejsilnější vztah byl pozorován ve skupině 30–44 let, což podporuje hypotézu, že socioekonomické postavení domácnosti souvisí se zdravotním stavem měřeným pomocí BMI.
