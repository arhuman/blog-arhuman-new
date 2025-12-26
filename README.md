# Arhuman's Blog

Personal blog built with Hugo static site generator using the Mainroad theme.

## Installation

Clone the repository with submodules:

```bash
git clone --recurse-submodules https://github.com/arhuman/hugo-blog-new.git
cd hugo-blog-new
```

If you already cloned without submodules, initialize them:

```bash
git submodule init
git submodule update
```

## Development

Start the development server:

```bash
hugo server -D
```

The site will be available at `http://localhost:1313`

## Building

Build the static site:

```bash
hugo
```

Output will be in the `public/` directory.

## Creating Content

The site uses **directory-based multilingual structure** with separate `en/` and `fr/` directories.

**Create a new English blog post:**

```bash
hugo new content/en/post/my-post-name.md
```

**Create a new French blog post:**

```bash
hugo new content/fr/post/my-post-name.md
```

**Create other pages:**

```bash
# English about page
hugo new content/en/about.md

# French about page
hugo new content/fr/about.md
```

## Theme Management

The site uses the Mainroad theme as a git submodule, pinned to a specific commit for stability.

**Update theme to latest version:**

```bash
git submodule update --remote themes/mainroad
git add themes/mainroad
git commit -m "Update mainroad theme"
```

**Check current theme version:**

```bash
git submodule status
```

## Image Optimization

Optimize images without quality loss:

```bash
./scripts/optimize-images.sh [directory]
```

Default directory is `static/img`. The script:
- Optimizes JPEGs with jpegtran
- Optimizes GIFs with gifsicle (preserves animation)
- Optimizes PNGs with sips

Install required tools on macOS:

```bash
brew install jpeg gifsicle
```

## Configuration

Main configuration is in `config.toml`. Key settings:
- Site title and description
- Author information
- Social media links
- Menu structure
- Theme parameters

## Project Structure

```
.
├── config.toml          # Main configuration
├── content/            # Markdown content (directory-based i18n)
│   ├── en/            # English content
│   │   ├── post/      # English blog posts
│   │   ├── pres/      # English presentations
│   │   ├── now/       # English "now" page
│   │   └── about.md   # English about page
│   └── fr/            # French content
│       ├── post/      # French blog posts
│       ├── pres/      # French presentations
│       ├── now/       # French "now" page
│       └── about.md   # French about page
├── static/            # Static assets (images, CSS, JS)
├── themes/            # Hugo themes (git submodules)
│   └── mainroad/      # Active theme
└── public/            # Generated site (ignored in git)
```

**Multilingual Structure:**
- English content: `content/en/` → URLs: `/en/...`
- French content: `content/fr/` → URLs: `/fr/...`
- No language suffixes in filenames (clean `.md` extension)
- Language determined by directory structure
