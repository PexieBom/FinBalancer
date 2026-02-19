-- Seed default categories (expense & income)
-- Run after 001_create_schema.sql

INSERT INTO categories (id, name, icon, type) VALUES
    (uuid_generate_v4(), 'Food', 'restaurant', 'expense'),
    (uuid_generate_v4(), 'Transport', 'directions_car', 'expense'),
    (uuid_generate_v4(), 'Housing', 'home', 'expense'),
    (uuid_generate_v4(), 'Health', 'local_hospital', 'expense'),
    (uuid_generate_v4(), 'Entertainment', 'movie', 'expense'),
    (uuid_generate_v4(), 'Shopping', 'shopping_cart', 'expense'),
    (uuid_generate_v4(), 'Utilities', 'bolt', 'expense'),
    (uuid_generate_v4(), 'Salary', 'work', 'income'),
    (uuid_generate_v4(), 'Freelance', 'handshake', 'income'),
    (uuid_generate_v4(), 'Investment', 'trending_up', 'income'),
    (uuid_generate_v4(), 'Other', 'category', 'expense')
;
