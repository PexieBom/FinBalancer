-- Seed podaci za korisnika tperisa22@gmail.com
-- Pokretanje: prvo 001_create_schema.sql, zatim ova skripta.
-- 002_seed_categories.sql NE treba - kategorije dolaze iz JSON-a.

-- Korisnik tperisa22 (Tomislav)
INSERT INTO users (id, email, password_hash, display_name, google_id, apple_id, email_verified, created_at, last_login_at)
VALUES (
    'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2',
    'tperisa22@gmail.com',
    'k07yJwpyldt4HjCytKj4gAdDCNEK1sLqkXWGvIRlX4o=',
    'Tomislav',
    NULL,
    NULL,
    FALSE,
    '2026-02-14 22:12:50.456682+00',
    '2026-02-19 19:00:05.020316+00'
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    display_name = EXCLUDED.display_name,
    last_login_at = EXCLUDED.last_login_at;

-- Guest user (potreban za account_link - tperisa22 je host, crosetup guest)
INSERT INTO users (id, email, password_hash, display_name, google_id, apple_id, email_verified, created_at, last_login_at)
VALUES (
    'f6b8ccb6-6ce9-470c-9a71-a5af29ceab31',
    'crosetup@gmail.com',
    'C2fLiSNtQDKKGzK/bYmS49rxiOCez14KQC0DDPrZepc=',
    'NImax',
    NULL,
    NULL,
    FALSE,
    '2026-02-14 11:17:49.941059+00',
    '2026-02-19 18:45:08.323806+00'
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    display_name = EXCLUDED.display_name,
    last_login_at = EXCLUDED.last_login_at;

-- Kategorije (sve koje transakcije koriste)
INSERT INTO categories (id, name, translations, icon, type) VALUES
('bddaf735-c68c-4d37-a519-8a5d414c6ffa', 'Hrana', '{"en":"Food","hr":"Hrana","de":"Essen","fr":"Alimentation","es":"Comida","it":"Cibo","pt":"Alimentação","nl":"Voedsel"}'::jsonb, 'restaurant', 'expense'),
('454e5ad1-116f-4d4d-b874-da4ca72383c5', 'Transport', '{"en":"Transport","hr":"Transport","de":"Transport","fr":"Transport","es":"Transporte","it":"Trasporto","pt":"Transporte","nl":"Vervoer"}'::jsonb, 'directions_car', 'expense'),
('fd67a85f-d605-42b2-8952-77a59def8b49', 'Stanovanje', '{"en":"Housing","hr":"Stanovanje","de":"Wohnen","fr":"Logement","es":"Vivienda","it":"Abitazione","pt":"Habitação","nl":"Wonen"}'::jsonb, 'home', 'expense'),
('eae56227-03f7-4acc-b8b1-55bc9b4df4c4', 'Zabava', '{"en":"Entertainment","hr":"Zabava","de":"Unterhaltung","fr":"Divertissement","es":"Entretenimiento","it":"Intrattenimento","pt":"Entretenimento","nl":"Entertainment"}'::jsonb, 'movie', 'expense'),
('40d2f1ce-64c5-4227-a371-c7ea3c3df851', 'Zdravlje', '{"en":"Health","hr":"Zdravlje","de":"Gesundheit","fr":"Santé","es":"Salud","it":"Salute","pt":"Saúde","nl":"Gezondheid"}'::jsonb, 'local_hospital', 'expense'),
('e9a32c4f-8abe-4ada-aa81-327b164d8c9a', 'Ostalo', '{"en":"Other","hr":"Ostalo","de":"Sonstiges","fr":"Autre","es":"Otros","it":"Altro","pt":"Outros","nl":"Overig"}'::jsonb, 'category', 'expense'),
('de94859f-944f-4b86-8a7e-97ceaad1d8d2', 'Plaća', '{"en":"Salary","hr":"Plaća","de":"Gehalt","fr":"Salaire","es":"Salario","it":"Stipendio","pt":"Salário","nl":"Salaris"}'::jsonb, 'account_balance_wallet', 'income'),
('6bb8814b-4bfc-425a-9547-b2e81198e50b', 'Bonus', '{"en":"Bonus","hr":"Bonus","de":"Bonus","fr":"Bonus","es":"Bonus","it":"Bonus","pt":"Bônus","nl":"Bonus"}'::jsonb, 'star', 'income'),
('f071be05-fd89-4fae-b7e9-7b7d03609d9b', 'Ostali prihod', '{"en":"Other income","hr":"Ostali prihod","de":"Sonstige Einnahmen","fr":"Autres revenus","es":"Otros ingresos","it":"Altri guadagni","pt":"Outras receitas","nl":"Overige inkomsten"}'::jsonb, 'attach_money', 'income'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Krediti', '{"en":"Loans","hr":"Krediti","de":"Kredite","fr":"Crédits","es":"Créditos","it":"Prestiti","pt":"Empréstimos","nl":"Leningen"}'::jsonb, 'credit_card', 'expense'),
('b2c3d4e5-f6a7-4b6c-9d0e-1f2a3b4c5d6e', 'Posudbe', '{"en":"Borrowing","hr":"Posudbe","de":"Leihen","fr":"Emprunts","es":"Préstamos","it":"Prestiti","pt":"Empréstimos","nl":"Leningen"}'::jsonb, 'handshake', 'expense'),
('c3d4e5f6-a7b8-4c7d-0e1f-2a3b4c5d6e7f', 'Odrzavanje automobila', '{"en":"Car maintenance","hr":"Odrzavanje automobila","de":"Autowartung","fr":"Entretien automobile","es":"Mantenimiento del coche","it":"Manutenzione auto","pt":"Manutenção do carro","nl":"Auto-onderhoud"}'::jsonb, 'build', 'expense'),
('d4e5f6a7-b8c9-4d8e-1f2a-3b4c5d6e7f8a', 'Odrzavanje kuce', '{"en":"Home maintenance","hr":"Odrzavanje kuce","de":"Hauswartung","fr":"Entretien maison","es":"Mantenimiento del hogar","it":"Manutenzione casa","pt":"Manutenção da casa","nl":"Huishoudelijk onderhoud"}'::jsonb, 'home_repair_service', 'expense'),
('e5f6a7b8-c9d0-4e9f-2a3b-4c5d6e7f8a9b', 'Režije', '{"en":"Utilities","hr":"Režije","de":"Nebenkosten","fr":"Charges","es":"Servicios","it":"Bollette","pt":"Contas","nl":"Nutsvoorzieningen"}'::jsonb, 'bolt', 'expense'),
('f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', 'Restorani', '{"en":"Restaurants","hr":"Restorani","de":"Restaurants","fr":"Restaurants","es":"Restaurantes","it":"Ristoranti","pt":"Restaurantes","nl":"Restaurants"}'::jsonb, 'restaurant_menu', 'expense'),
('a7b8c9d0-e1f2-4a1b-4c5d-6e7f8a9b0c1d', 'Trošak goriva', '{"en":"Fuel","hr":"Trošak goriva","de":"Kraftstoff","fr":"Carburant","es":"Combustible","it":"Carburante","pt":"Combustível","nl":"Brandstof"}'::jsonb, 'local_gas_station', 'expense'),
('b8c9d0e1-f2a3-4b2c-5d6e-7f8a9b0c1d2e', 'Digital subscriptions', '{"en":"Digital subscriptions","hr":"Digitalne pretplate","de":"Digitale Abos","fr":"Abonnements digitaux","es":"Suscripciones digitales","it":"Abbonamenti digitali","pt":"Assinaturas digitais","nl":"Digitale abonnementen"}'::jsonb, 'subscriptions', 'expense'),
('c9d0e1f2-a3b4-4c3d-6e7f-8a9b0c1d2e3f', 'Zivotno osiguranje', '{"en":"Life insurance","hr":"Zivotno osiguranje","de":"Lebensversicherung","fr":"Assurance vie","es":"Seguro de vida","it":"Assicurazione sulla vita","pt":"Seguro de vida","nl":"Levensverzekering"}'::jsonb, 'health_and_safety', 'expense'),
('2e30191f-0ec8-466e-b004-ef92758581fa', 'Rezije', '{}'::jsonb, 'category', 'expense')
ON CONFLICT (id) DO NOTHING;

-- Custom kategorije za tperisa22
INSERT INTO custom_categories (id, user_id, name, type, icon) VALUES
('30bc6481-745a-444a-947f-db5b6ba5ce8e', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'Obrt Prihod', 'income', 'custom'),
('ef1712af-c309-4940-8842-132f815090d4', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'Dizanje s bankomata', 'expense', 'custom')
ON CONFLICT (id) DO NOTHING;

-- Novčanik
INSERT INTO wallets (id, user_id, name, balance, currency, is_main) VALUES
('e6bc4221-b7ed-490b-9057-8110d61da5d5', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'Main wallet', 9162, 'EUR', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Transakcije za tperisa22
INSERT INTO transactions (id, user_id, amount, type, category_id, subcategory_id, wallet_id, note, tags, project, project_id, date_created, is_yearly_expense) VALUES
('ad6d0134-ae94-499f-8953-2f363b75304d', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 100, 'expense', 'ef1712af-c309-4940-8842-132f815090d4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'bankomat', '[]'::jsonb, NULL, NULL, '2026-02-15 16:31:23.594778+00', FALSE),
('24fe50a0-9a30-472d-950b-9691a9de286b', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 63.56, 'expense', 'a7b8c9d0-e1f2-4a1b-4c5d-6e7f8a9b0c1d', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'gorivo', '[]'::jsonb, NULL, NULL, '2026-02-15 16:31:52.700725+00', FALSE),
('0f9d2275-1ba0-43fd-a245-492eddf866b0', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 50, 'income', 'f071be05-fd89-4fae-b7e9-7b7d03609d9b', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'baba dala', '[]'::jsonb, NULL, NULL, '2026-02-15 16:32:28.500246+00', FALSE),
('354810ac-ef1f-4ab2-8dd1-e7797a87429e', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 50, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'prebaceno dici', '[]'::jsonb, NULL, NULL, '2026-02-15 16:32:47.437339+00', FALSE),
('e2180e3f-c5f6-49e8-b308-6ce756643269', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 30, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'naknada za placanje', '[]'::jsonb, NULL, NULL, '2026-02-15 16:33:15.904683+00', FALSE),
('9fd8a303-6ce2-4ce5-9108-520829a1cf8e', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 100, 'expense', 'b8c9d0e1-f2a3-4b2c-5d6e-7f8a9b0c1d2e', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'prijenos na revolut', '[]'::jsonb, NULL, NULL, '2026-02-15 16:33:36.283732+00', FALSE),
('1f656008-4c97-422d-9e9a-3cfb46b2dded', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 4.9, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:34:03.120769+00', FALSE),
('c3519111-7186-4d0d-abc8-5e32563a788c', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 63, 'expense', 'f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Restoran fratelli', '[]'::jsonb, NULL, NULL, '2026-02-15 16:34:21.743147+00', FALSE),
('35c0adc6-339c-49dd-8fb3-317ce7702718', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 3412.29, 'income', 'de94859f-944f-4b86-8a7e-97ceaad1d8d2', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:34:43.106849+00', FALSE),
('5c22f249-173a-4cf4-b722-3f5c85f77c19', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 293.63, 'expense', 'c3d4e5f6-a7b8-4c7d-0e1f-2a3b4c5d6e7f', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Polica osiguranja auto', '[]'::jsonb, NULL, NULL, '2026-02-15 16:35:11.160816+00', TRUE),
('886a24f9-030a-4d13-b5b0-4dad398314b0', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Bankovna transakcija', '[]'::jsonb, NULL, NULL, '2026-02-15 16:35:28.084977+00', FALSE),
('777682bd-03f4-49c0-aed4-56e94df0654e', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 4.2, 'expense', '454e5ad1-116f-4d4d-b874-da4ca72383c5', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'autocesta', '[]'::jsonb, NULL, NULL, '2026-02-15 16:35:44.587682+00', FALSE),
('f54ed545-ac11-491e-8513-221229f66fc9', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 4.2, 'expense', '454e5ad1-116f-4d4d-b874-da4ca72383c5', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'autocesta', '[]'::jsonb, NULL, NULL, '2026-02-15 16:35:58.099385+00', FALSE),
('bbbcccc8-eb59-4e64-9c9d-3969e23fc5be', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 2.19, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Lukoil voda', '[]'::jsonb, NULL, NULL, '2026-02-15 16:36:13.688458+00', FALSE),
('2f16bb57-5796-4205-a4e6-a307d38aac0f', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 15.18, 'expense', '40d2f1ce-64c5-4227-a371-c7ea3c3df851', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'ljekarna', '[]'::jsonb, NULL, NULL, '2026-02-15 16:36:33.771991+00', FALSE),
('679187d5-97c8-48cc-a70a-1645b6421403', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 7.69, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:36:46.786983+00', FALSE),
('79c2a05a-95f5-477a-93b8-0640eab6fd84', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 22.88, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:37:05.973377+00', FALSE),
('98e241ed-f731-431e-a9ec-c100890da916', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 27.3, 'expense', 'f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Mcdonalds', '[]'::jsonb, NULL, NULL, '2026-02-15 16:37:19.967384+00', FALSE),
('69c6404d-9837-4a8a-8728-2e590a3bc122', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 248.32, 'expense', 'e5f6a7b8-c9d0-4e9f-2a3b-4c5d6e7f8a9b', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Režije struja', '[]'::jsonb, NULL, NULL, '2026-02-15 16:37:43.933876+00', FALSE),
('f8059919-6092-4267-b9bc-ed59c09e01d9', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:38:19.554336+00', FALSE),
('6c8c5604-a1af-475d-9676-298730b3c6c3', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 26.39, 'expense', 'fd67a85f-d605-42b2-8952-77a59def8b49', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Premija police osiguranja kuce', '[]'::jsonb, NULL, NULL, '2026-02-15 16:38:35.651005+00', FALSE),
('56d2054a-d8fd-4ee9-a7c6-34d6eb6710f9', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 7.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'banka', '[]'::jsonb, NULL, NULL, '2026-02-15 16:38:50.801695+00', FALSE),
('786e511d-3080-4dbc-a70a-951a72914e28', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 20.15, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:39:01.951317+00', FALSE),
('9c7525b4-38ef-4531-9278-49f3dedf582c', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 265, 'expense', 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Kredit auto', '[]'::jsonb, NULL, NULL, '2026-02-15 16:39:18.370781+00', FALSE),
('7b74753b-f7e7-450b-8860-9e4d214f6d68', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:39:30.102194+00', FALSE),
('c95f341e-556a-4c39-bbc3-45d19aa05a10', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 33.67, 'expense', 'e5f6a7b8-c9d0-4e9f-2a3b-4c5d6e7f8a9b', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'A1', '[]'::jsonb, NULL, NULL, '2026-02-15 16:39:42.992325+00', FALSE),
('5f954fa3-7837-403f-a187-ab176dff65a1', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 22.37, 'expense', 'e5f6a7b8-c9d0-4e9f-2a3b-4c5d6e7f8a9b', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Tcom Tome', '[]'::jsonb, NULL, NULL, '2026-02-15 16:40:01.632866+00', FALSE),
('6fd31327-d254-413a-9585-bfbaf75819d9', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:40:12.557789+00', FALSE),
('cf9137f1-3e78-45f6-bb43-84678d4b15a2', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 50, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'magarece mliko', '[]'::jsonb, NULL, NULL, '2026-02-15 16:40:28.655+00', FALSE),
('01b77e25-58fc-4b5d-ab73-b218317dc7cc', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:40:37.417690+00', FALSE),
('e4396289-c9d3-4a91-be4f-7bd7615e0282', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 66.11, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:40:51.535522+00', FALSE),
('01e88e3e-bfac-4fc9-88f0-34c5f72958e9', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 71, 'expense', 'f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Pizzeria Ivo - Krci', '[]'::jsonb, NULL, NULL, '2026-02-15 16:41:12.602875+00', FALSE),
('9e2138a5-90d5-4bcf-9565-8c0b7c13a018', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 50.63, 'expense', 'c3d4e5f6-a7b8-4c7d-0e1f-2a3b4c5d6e7f', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'tehnicki pregled', '[]'::jsonb, NULL, NULL, '2026-02-15 16:41:27.490705+00', TRUE),
('093d8edf-269e-49f3-9c68-3abcd4af4921', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 263.43, 'expense', 'c3d4e5f6-a7b8-4c7d-0e1f-2a3b4c5d6e7f', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Tehnicki pregled + poseban porez bmw', '[]'::jsonb, NULL, NULL, '2026-02-15 16:41:57.559076+00', TRUE),
('3a71f16d-2732-4965-be13-eaee09596471', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 50, 'expense', 'ef1712af-c309-4940-8842-132f815090d4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Bankomat', '[]'::jsonb, NULL, NULL, '2026-02-15 16:42:13.306496+00', FALSE),
('457da316-ae4d-4f93-830f-5d0c08d55e6f', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 15.47, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:42:23.627446+00', FALSE),
('1876ff8b-9cba-42ec-86b9-3786e505aa34', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 16, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:42:34.319267+00', FALSE),
('f4a313b7-3d9f-4c77-acba-00b857de713e', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 4.79, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:42:46.735450+00', FALSE),
('b683fdf5-9120-43c3-9e69-343295af471b', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 404, 'expense', 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:42:58.158087+00', FALSE),
('61d6f60a-4eef-4bee-968e-acfbae2fe7b2', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 566.09, 'expense', 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'kredit bmw', '[]'::jsonb, NULL, NULL, '2026-02-15 16:43:12.258732+00', FALSE),
('ea9eac96-45d5-4eb7-931d-f2cf8c34f736', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 38.6, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:43:25.251109+00', FALSE),
('cf29086d-c3a3-45cd-b0d0-77eb266dbf4a', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 31.47, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:43:43.252664+00', FALSE),
('e3ea707c-6b0b-4e0b-b661-0dfb2f8fbc77', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 25.23, 'expense', 'e5f6a7b8-c9d0-4e9f-2a3b-4c5d6e7f8a9b', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Marina mob', '[]'::jsonb, NULL, NULL, '2026-02-15 16:43:57.591778+00', FALSE),
('a720861e-f3cc-4b12-ad7f-bcdff93c92da', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:44:07.559149+00', FALSE),
('12803c79-162d-46ea-92a3-e2cf8d160d18', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 73.63, 'expense', 'a7b8c9d0-e1f2-4a1b-4c5d-6e7f8a9b0c1d', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'gorivo', '[]'::jsonb, NULL, NULL, '2026-02-15 16:44:23.702793+00', FALSE),
('c16a9561-1722-4f6e-986a-dec3c981d23e', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 4.34, 'expense', '40d2f1ce-64c5-4227-a371-c7ea3c3df851', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:44:40.704847+00', FALSE),
('fe642768-eb68-4d09-93f6-5a3178893d36', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 56.39, 'expense', 'eae56227-03f7-4acc-b8b1-55bc9b4df4c4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Bojanke dici', '[]'::jsonb, NULL, NULL, '2026-02-15 16:44:58.189844+00', FALSE),
('e5d84533-d746-48de-ac1b-793ca0e37612', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 22.5, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:45:18.172028+00', FALSE),
('87d8031a-e11c-4804-995d-42c1e081ff90', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 18.58, 'expense', '40d2f1ce-64c5-4227-a371-c7ea3c3df851', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'croatia ', '[]'::jsonb, NULL, NULL, '2026-02-15 16:45:35.601043+00', FALSE),
('3a2ab116-6c8f-45fd-b270-5ecbf39112ae', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:45:45.109098+00', FALSE),
('f54b3467-d631-4dd5-8adf-8121d61e95b0', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 70, 'expense', 'eae56227-03f7-4acc-b8b1-55bc9b4df4c4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Fran clanarina Judo', '[]'::jsonb, NULL, NULL, '2026-02-15 16:46:05.535748+00', FALSE),
('345d3165-0e67-4b32-a862-74285de6c902', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.6, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'banka naknada', '[]'::jsonb, NULL, NULL, '2026-02-15 16:46:17.737065+00', FALSE),
('fb22dcd5-a499-41e2-a29c-686e30b82e94', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 12.24, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:46:30.408304+00', FALSE),
('55530345-963c-4c56-9086-70dd538d2177', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 15.2, 'expense', 'f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Mcdonalds', '[]'::jsonb, NULL, NULL, '2026-02-15 16:46:45.006339+00', FALSE),
('3b259e74-8084-402d-8e69-2fdfd22904b3', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 112.5, 'expense', 'eae56227-03f7-4acc-b8b1-55bc9b4df4c4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Marina Valentinovo', '[]'::jsonb, NULL, NULL, '2026-02-15 16:47:05.368615+00', FALSE),
('2fe3fa4b-64b6-414e-86da-e3539447b24a', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 0.3, 'expense', 'e9a32c4f-8abe-4ada-aa81-327b164d8c9a', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:47:15.035077+00', FALSE),
('9b102ea5-7dae-4f20-bf2b-17646ab7f35a', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 14.53, 'expense', 'bddaf735-c68c-4d37-a519-8a5d414c6ffa', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:47:25.438836+00', FALSE),
('94356def-85d0-4378-b342-607374c3dbde', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 70, 'expense', 'eae56227-03f7-4acc-b8b1-55bc9b4df4c4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Marina Valentinovo', '[]'::jsonb, NULL, NULL, '2026-02-15 16:47:44.435433+00', FALSE),
('74998ada-ea7f-4500-8853-7c3021392721', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 73.2, 'expense', 'f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Lovac restoran', '[]'::jsonb, NULL, NULL, '2026-02-15 16:48:00.157649+00', FALSE),
('2c319825-9dce-4080-8bac-ac013437ec5c', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 52.97, 'income', 'f071be05-fd89-4fae-b7e9-7b7d03609d9b', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-15 16:50:20.291978+00', FALSE),
('a0a25f4b-a914-4f6f-9a02-927de20b5589', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 500, 'income', '30bc6481-745a-444a-947f-db5b6ba5ce8e', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Obrt - Sam odrzavanje', '[]'::jsonb, NULL, NULL, '2026-02-15 18:31:17.28756+00', FALSE),
('e0d6b8d9-14fe-4da9-bb33-9c0362aba9d4', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 900, 'income', '30bc6481-745a-444a-947f-db5b6ba5ce8e', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Obrt - Asteria', '[]'::jsonb, NULL, NULL, '2026-02-15 18:32:04.161139+00', FALSE),
('dd145374-e46b-4291-8236-8228c08d6b57', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 100, 'expense', 'ef1712af-c309-4940-8842-132f815090d4', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', NULL, '[]'::jsonb, NULL, NULL, '2026-02-17 15:22:08.501187+00', FALSE),
('2fa5b851-6879-463f-aedd-4acd59934ee7', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 52, 'expense', 'f6a7b8c9-d0e1-4f0a-3b4c-5d6e7f8a9b0c', NULL, 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 'Matej kolega rucak', '[]'::jsonb, NULL, NULL, '2026-02-18 12:45:27.556685+00', FALSE)
ON CONFLICT (id) DO NOTHING;

-- Budžet
INSERT INTO wallet_budgets (id, user_id, wallet_id, budget_amount, period_start_day, period_start_date, period_end_date, category_id, created_at, updated_at) VALUES
('2eaa461b-4da8-486c-bc3e-483b2375eb62', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'e6bc4221-b7ed-490b-9057-8110d61da5d5', 815, 16, NULL, NULL, NULL, '2026-02-17 15:23:14.884913+00', '2026-02-17 15:23:14.884006+00')
ON CONFLICT (id) DO NOTHING;

-- Refresh token
INSERT INTO refresh_tokens (token, user_id, expires_at, created_at) VALUES
('_FMY8-SzSn558gVB7lZSQkTeKX3Ac9Fcy63WwEoOTHyfd9JqXRDqDMR_AYp5vKZk', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', '2027-02-19 19:00:05.030598+00', '2026-02-19 19:00:05.030639+00')
ON CONFLICT (token) DO NOTHING;

-- User preferences (defaults)
INSERT INTO user_preferences (user_id, locale, currency, theme) VALUES
('bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'en', 'EUR', 'light')
ON CONFLICT (user_id) DO NOTHING;

-- Account link (tperisa22 host, crosetup guest)
INSERT INTO account_links (id, host_user_id, guest_user_id, status, invited_at, responded_at) VALUES
('abdc27e4-8101-4372-8ee0-a147a13ccc27', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'f6b8ccb6-6ce9-470c-9a71-a5af29ceab31', 0, '2026-02-19 18:44:42.593669+00', NULL)
ON CONFLICT (host_user_id, guest_user_id) DO NOTHING;

-- Otključani achievementi za tperisa22
INSERT INTO unlocked_achievements (id, user_id, achievement_key, unlocked_at) VALUES
(uuid_generate_v4(), 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'first_transaction', '2026-02-14 11:48:14.194938+00'),
(uuid_generate_v4(), 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'first_goal', '2026-02-14 14:14:15.84836+00'),
(uuid_generate_v4(), 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'goal_reached', '2026-02-14 14:14:35.688879+00'),
(uuid_generate_v4(), 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'ten_transactions', '2026-02-14 20:24:01.998095+00'),
(uuid_generate_v4(), 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'month_saved', '2026-02-15 16:34:43.337979+00')
ON CONFLICT (user_id, achievement_key) DO NOTHING;
