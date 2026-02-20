/**
 * Shared blog utilities – used by index.html for latest posts
 */
async function fetchBlogPosts() {
  const res = await fetch('data/blog.json');
  const posts = await res.json();
  return posts.sort((a, b) => new Date(b.date) - new Date(a.date));
}

function renderBlogCard(post) {
  const date = new Date(post.date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
  return `
    <article class="blog-card">
      <a href="post.html?id=${post.id}">
        <img src="${post.image}" alt="${post.title}">
        <div class="blog-card-body">
          <time>${date}</time>
          <h3>${post.title}</h3>
          <p>${post.excerpt}</p>
        </div>
      </a>
    </article>
  `;
}
