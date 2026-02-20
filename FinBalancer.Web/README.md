# FinBalancer Landing Page

Marketing stranica za finbalancer.com – statični HTML/CSS/JS.

## Struktura

```
FinBalancer.Web/
├── index.html      # Glavna stranica
├── blog.html       # Blog lista s pagingom
├── post.html       # Pojedinačni post (param: ?id=slug)
├── styles.css      # Stilovi
├── blog.js         # Blog utilities
├── data/
│   └── blog.json   # Blog postovi (uredi za nove članke)
├── images/         # Slike
└── README.md
```

### Blog

- Izvor podataka: `data/blog.json` + `blog-data.js` (JS verzija za učitavanje bez fetch-a)
- Kad dodaješ post u `blog.json`, ažuriraj i `blog-data.js`: `window.BLOG_POSTS = ` + sadržaj JSON niza
- 3 najnovija se prikazuju na homepageu
- `blog.html` – lista s pagingom (6 po stranici)
- `post.html?id=slug` – pojedinačni članak
- **Napomena:** Otvaranje preko `file://` zahtijeva da `blog-data.js` bude u rootu (bez fetch-a)

## Deployment

1. **Netlify / Vercel / GitHub Pages**  
   Učitaj cijeli folder – root je `index.html`.

2. **Ručni upload**  
   Kopiraj sadržaj na web server (npr. u `public_html` ili `www`).

3. **Base URL za app**  
   Linkovi vode na `https://app.finbalancer.com`. Ako je app na drugoj adresi, prilagodi u `index.html`.
