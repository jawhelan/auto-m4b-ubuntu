
# auto-m4b-ubuntu


[![Build and Push Docker Image to Docker Hub](https://github.com/jawhelan/auto-m4b-ubuntu/actions/workflows/docker-publish.yml/badge.svg?branch=main)](https://github.com/jawhelan/auto-m4b-ubuntu/actions/workflows/docker-publish.yml)

[![Docker Pulls](https://img.shields.io/docker/pulls/jawhelan/auto-m4b-ubuntu)](https://hub.docker.com/r/jawhelan/auto-m4b-ubuntu)
[![Docker Image Version](https://img.shields.io/docker/v/jawhelan/auto-m4b-ubuntu?sort=semver)](https://hub.docker.com/r/jawhelan/auto-m4b-ubuntu)



This project builds and runs a custom Docker container named auto-m4b-ubuntu, designed to convert MP3 audiobook files into .m4b format with embedded chapters and metadata, using the open-source tool m4b-tool. It is tailored for single-track M4B output with unified metadata.

The environment is optimized for batch processing of audiobooks and can be extended or automated with wrapper scripts. It uses an Ubuntu-based image, preconfigured with:

- `m4b-tool` (m4b-tool.phar) (installed via PHP 8.2 .phar and/or apt)

- `ffmpeg` for media processing

- `eyeD3` for MP3 metadata extraction

## 🐳 Docker Image Details
**Base Image**: ubuntu:latest

**Installed Tools:**

- m4b-tool (via m4b-tool.phar)

- ffmpeg

- eyeD3
**Volumes:**
/temp
/config

## 📝 `docker-compose.yml`
```yaml
version: '3.7'

services:
  auto-m4b-ubuntu:
    image: jawhelan/auto-m4b-ubuntu
    container_name: auto-m4b-ubuntu
    volumes:
      - ./config:/config
      - ./temp:/temp
    environment:
      TZ: America/New_York  # Use your own timezone
      PUID: "1024"  # Use your own PUID and PGID
      PGID: "100"
      CPU_CORES: "2"
      SLEEPTIME: "1m"
      MAKE_BACKUP: "N"
    restart: unless-stopped 
```

## 📂 Folder Layout (example)  
### Volumes
```
/Temp
/config
```


## 📂📂 Working Directories 

```
/temp/
└── Book Title/
    ├── 0001 - Chapter One.mp3
    ├── 0002 - Chapter Two.mp3
    ├── cover.jpg
/config/
    ├──batch-m4b-builder.sh  # optional to override
```

## 📥 Pull the image from Docker:

```bash
docker pull jawhelan/auto-m4b-ubuntu
```

## 🚀 Launch container
```bash
docker compose up -d
```
---
# 🎧 Batch M4B Audiobook Builder

This project simplifies the conversion of folders of MP3 files into chaptered `.m4b` audiobooks with embedded metadata and optional cover art. It runs inside a containerized environment for reliability and portability.
---
## ⚙️ Main Script: `batch-m4b-builder.sh`  

**Creates:**  
- A single-track `.m4b` audiobook  
- Clean chapter markers named `Chapter 1`, `Chapter 2`, etc.  
- Proper metadata: title, artist, album, year, genre, comment  
- A `.done` marker to prevent duplicate processing  

### ✅ Operational Requirements:
- MP3 files named in chapter order 
- Optional: `cover.jpg` in the same folder (if not mb4-tool will auto extract from mp3)

### 🖥️🏃 Usage (from host)
```bash
docker exec auto-m4b-ubuntu /usr/local/bin/batch-m4b-builder.sh
```
- optional for override
```bash
docker exec -it auto-m4b-ubuntu /config/batch-m4b-builder.sh
```
### 🐚🏃 Usage (from container)

```bash
docker exec -it auto-m4b-ubuntu bash  
/usr/local/bin/batch-m4b-builder.sh
```

- optional for override
```bash
docker exec -it auto-m4b-ubuntu bash  
/config/batch-m4b-builder.sh
```
---

## ⚙️ Alternate Builders

### ⚙️ `file-m4b-builder.sh` — Use Full Filename as Chapter Title
- Chapters are named from the full filename
- Suitable for podcasts or complex filenames

---

### ⚙️ `track-m4b-builder.sh` — Use “Track - Chapter” Style
- Each MP3 becomes a separate chapter named like `001_Chapter_1`
- Good for advanced players and debug


## 📝 Batch M4B Builder Notes

- Each `.m4b` file includes:
  - Chapter metadata
  - Embedded tags
  - Optional cover image
- A `.done` file is created inside each folder to prevent repeated processing. Delete it to reprocess.

---

## 📦 `m4b-tool` (m4b-tool.phar)

These are pre-installed in the Docker image.

### 📚 m4b-tool Overview & Usage Guide

#### 🧰 What is `m4b-tool`?

`m4b-tool` is a powerful command-line utility designed to create and manage `.m4b` audiobook files. It can merge, extract and inject chapter data, convert formats, and tag audiobooks with detailed metadata.

#### 📁 Set up working directories
To run manually first set up the working directories
```bash
mkdir -p temp/input temp/output
```

📁 File Organization Tip  
Set up a structure like this
```

   ── temp
       ├── input
       │    ├── 01.mp3
       │    ├── 02.mp3
       │    └── ...
       └── output
```

📦 Basic Merge

```bash
php m4b-tool.phar merge temp/input --output-file temp/output/book.m4b
```

🖼 With Metadata & Cover Art
```bash
php m4b-tool.phar merge temp/input \
  --output-file temp/output/book.m4b \
  --name "My Audiobook Title" \
  --author "Author Name" \
  --album "Audiobook Album" \
  --cover cover.jpg  
```

🔇 Automatically Generate Chapters by Silence
```bash
php m4b-tool.phar merge temp/input \
  --output-file temp/output/book.m4b \
  --silence \
  --max-chapter-length 900
```
⏩ Speed Up Conversion (multi-core)
```bash
php m4b-tool.phar merge temp/input \
  --output-file temp/output/book.m4b \
  --jobs 4
```
Adjust --jobs to match your CPU core count.  
🔍 Full List of Options
```bash
php m4b-tool.phar help
```

---

## 💬 Credits

- 🛠 `m4b-tool`: [Andreas (sandreas)](https://github.com/sandreas)
- 🔧 `libmp4v2` source: [Sérgio Basto](https://github.com/sergiomb2/libmp4v2)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 📬 Feedback
Pull requests and improvements welcome!
