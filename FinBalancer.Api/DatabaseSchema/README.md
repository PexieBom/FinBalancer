# FinBalancer Database Schema (PostgreSQL)

## Database-First pristup

1. **Schema** – SQL skripte u ovom folderu
2. **ORM** – Entity Framework Core s Npgsql
3. **Entiteti** – ručno kreirani u `Data/EntityModels/` prema schemi (ili scaffold iz baze)

## Uspostava baze

### 1. Kreiraj bazu

```bash
psql -U postgres -c "CREATE DATABASE finbalancer;"
```

### 2. Pokreni skripte

```bash
psql -U postgres -d finbalancer -f 001_create_schema.sql
# Za praznu bazu s default kategorijama:
psql -U postgres -d finbalancer -f 002_seed_categories.sql
# ILI za migraciju podataka korisnika tperisa22 (iz JSON-a):
psql -U postgres -d finbalancer -f 003_seed_user_tperisa22.sql
psql -U postgres -d finbalancer -f 004_seed_missing_data.sql
psql -U postgres -d finbalancer -f 005_add_access_tokens.sql
psql -U postgres -d finbalancer -f 006_update_category_translations.sql
psql -U postgres -d finbalancer -f 007_allow_global_budget.sql
psql -U postgres -d finbalancer -f 008_multiple_budgets_and_main.sql
psql -U postgres -d finbalancer -f 009_schema_version_table.sql
```

**Napomena:** `003_seed_user_tperisa22.sql` uključuje sve kategorije iz JSON-a i ne treba pokretati `002_seed_categories.sql`.  
`004_seed_missing_data.sql` dodaje subscription plans i tperisa22 yearly plan.  
`005_add_access_tokens.sql` dodaje tablicu za perzistenciju Bearer tokena (potrebno za dodavanje transakcija nakon restarta API-ja).

### 3. Connection string i konfiguracija (appsettings.json)

Connection string je već dodan. Za korištenje PostgreSQL umjesto JSON datoteka postavi:

```json
{
  "Storage": {
    "UseMockData": false
  }
}
```

Kada je `UseMockData: false`, API koristi EF Core repozitorije i PostgreSQL.

## Verzija sheme (schema_version)

Tablica `schema_version` bilježi primijenjene migracije. Svaka nova migracija treba dodati `INSERT` za svoj `version`. Trenutna verzija = `MAX(version)` iz tablice.

## Scaffold (opcija – generira entitete iz baze)

Ako želiš automatski generirati/aktualizirati entitete iz postojeće baze:

```bash
cd FinBalancer.Api
dotnet ef dbcontext scaffold "Host=localhost;Database=finbalancer;Username=postgres;Password=xxx" Npgsql.EntityFrameworkCore.PostgreSQL -o Data/Scaffolded -c FinBalancerDbContext --force
```

Ovo generira nove klase u `Data/Scaffolded/`. Ručni entiteti u `Data/EntityModels/` su prilagođeni postojećem kodu.
