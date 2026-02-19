-- Update categories kojima nedostaju translations
-- Pokretanje: nakon 001-005
--
-- Ažurira kategorije gdje je translations NULL ili prazan objekt {},
-- popunjavajući ih s prijevodima (poznate mapiranja + fallback: name u svim jezicima).

UPDATE categories c
SET translations = COALESCE(
    CASE c.name
        -- Poznata mapiranja (isti prijevodi kao u categories.json)
        WHEN 'Food' THEN '{"en":"Food","hr":"Hrana","de":"Essen","fr":"Alimentation","es":"Comida","it":"Cibo","pt":"Alimentação","nl":"Voedsel"}'::jsonb
        WHEN 'Transport' THEN '{"en":"Transport","hr":"Transport","de":"Transport","fr":"Transport","es":"Transporte","it":"Trasporto","pt":"Transporte","nl":"Vervoer"}'::jsonb
        WHEN 'Housing' THEN '{"en":"Housing","hr":"Stanovanje","de":"Wohnen","fr":"Logement","es":"Vivienda","it":"Abitazione","pt":"Habitação","nl":"Wonen"}'::jsonb
        WHEN 'Health' THEN '{"en":"Health","hr":"Zdravlje","de":"Gesundheit","fr":"Santé","es":"Salud","it":"Salute","pt":"Saúde","nl":"Gezondheid"}'::jsonb
        WHEN 'Entertainment' THEN '{"en":"Entertainment","hr":"Zabava","de":"Unterhaltung","fr":"Divertissement","es":"Entretenimiento","it":"Intrattenimento","pt":"Entretenimento","nl":"Entertainment"}'::jsonb
        WHEN 'Shopping' THEN '{"en":"Shopping","hr":"Shopping","de":"Einkaufen","fr":"Shopping","es":"Compras","it":"Shopping","pt":"Compras","nl":"Winkelen"}'::jsonb
        WHEN 'Utilities' THEN '{"en":"Utilities","hr":"Režije","de":"Nebenkosten","fr":"Charges","es":"Servicios","it":"Bollette","pt":"Contas","nl":"Nutsvoorzieningen"}'::jsonb
        WHEN 'Salary' THEN '{"en":"Salary","hr":"Plaća","de":"Gehalt","fr":"Salaire","es":"Salario","it":"Stipendio","pt":"Salário","nl":"Salaris"}'::jsonb
        WHEN 'Freelance' THEN '{"en":"Freelance","hr":"Slobodno zanimanje","de":"Freelance","fr":"Freelance","es":"Freelance","it":"Freelance","pt":"Freelance","nl":"Freelance"}'::jsonb
        WHEN 'Investment' THEN '{"en":"Investment","hr":"Ulaganja","de":"Investition","fr":"Investissement","es":"Inversión","it":"Investimento","pt":"Investimento","nl":"Investering"}'::jsonb
        WHEN 'Other' THEN '{"en":"Other","hr":"Ostalo","de":"Sonstiges","fr":"Autre","es":"Otros","it":"Altro","pt":"Outros","nl":"Overig"}'::jsonb
        WHEN 'Rezije' THEN '{"en":"Utilities","hr":"Režije","de":"Nebenkosten","fr":"Charges","es":"Servicios","it":"Bollette","pt":"Contas","nl":"Nutsvoorzieningen"}'::jsonb
        ELSE NULL
    END,
    -- Fallback: koristi name u svim jezicima
    jsonb_build_object(
        'en', c.name,
        'hr', c.name,
        'de', c.name,
        'fr', c.name,
        'es', c.name,
        'it', c.name,
        'pt', c.name,
        'nl', c.name
    )
)
WHERE c.translations IS NULL
   OR c.translations = '{}'::jsonb;
