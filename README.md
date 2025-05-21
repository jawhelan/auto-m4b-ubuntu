
# 🎷 auto-m4b-ubuntu — Convert Audio Files to M4B with Docker

This project wraps [m4b-tool](https://github.com/sandreas/m4b-tool) into a clean Docker container using PHP 8.2 and FFmpeg, allowing you to convert audiobooks or other audio files into `.m4b` format with minimal setup and no broken build steps.

## 📦 What's Included

* PHP 8.2 from the official Ubuntu repo (no PPAs)
* Precompiled `m4b-tool.phar` (included locally)
* FFmpeg for media processing
* Docker & Docker Compose support
* `/config` and `/temp` volume mounts for input/output

## 📁 Folder Structure

```
.
├── Dockerfile              # Build instructions for the container
├── docker-compose.yml      # Compose service for running the tool
├── m4b-tool.phar           # Binary for m4b-tool
├── clean_untagged.sh       # Optional: script to clean up unused images
├── config/                 # Volume: custom config, if needed
└── temp/                   # Volume: store input/output files
```

## 🚀 Usage

### 1. Build the image

```bash
docker compose build
```

### 2. Run an interactive container

```bash
docker run -it --rm -v "$(pwd)/temp:/temp" m4b-auto bash
```

Or use the built-in `docker-compose.yml`:

```bash
docker compose up -d
```

### 3. Example conversion command

Inside the container:

```bash
m4b-tool merge /temp/*.mp3 --output-file /temp/output.m4b
```

## 🧼 Cleanup

To remove untagged (dangling) Docker images:

```bash
./clean_untagged.sh
```

## ⚙️ Environment Variables (Optional)

Set these in `docker-compose.yml` if needed:

| Variable    | Description              |
| ----------- | ------------------------ |
| `PUID`      | User ID for permissions  |
| `PGID`      | Group ID for permissions |
| `CPU_CORES` | CPU limit hint (unused)  |
| `SLEEPTIME` | Optional sleep cycle     |

## ✅ Requirements

* Docker
* Docker Compose v2

## 📄 License

This repo uses [m4b-tool](https://github.com/sandreas/m4b-tool), which is licensed under MIT. This wrapper repo is provided as-is.

# 📦 auto-m4b-ubuntu

A lightweight Docker container to run [`m4b-tool`](https://github.com/sandreas/m4b-tool) for converting MP3s and other audio formats into `.m4b` audiobook files.

---

## 🐳 Docker Features

* Built on Ubuntu 22.04
* Uses PHP 8.2 to meet latest m4b-tool requirements
* Ships with ffmpeg and all required PHP extensions
* Volume mounts for `/config` and `/temp`
* No broken dependencies or third-party repo errors

---

## 🔧 Quick Start

```bash
# Clone this repo
cd /your/project/folder

# Build the container
docker compose build

# Run the container in background
docker compose up -d

# Or run interactively for testing
docker run -it --rm -v "$PWD/temp:/temp" -v "$PWD/config:/config" m4b-auto bash
```

To convert audio inside the container:

```bash
m4b-tool merge /temp/foldername --output-file /config/output.m4b
```

---

## 🗂️ File Structure

```text
├── Dockerfile                # Container definition
├── docker-compose.yml       # Compose service
├── m4b-tool.phar            # Prebuilt m4b-tool binary
├── clean_untagged.sh        # Optional helper to delete untagged images
├── config/                  # Output files and persistent data
└── temp/                    # Place your input audio here
```

---

## 📚 m4b-tool Command Reference & Examples

### 🔄 Convert MP3 to M4B

```bash
m4b-tool merge /temp/mybook --output-file /config/mybook.m4b
```

### 🕓 Set Chapter Length (Auto-chapters)

```bash
m4b-tool merge /temp/book --output-file /config/book.m4b --chapter-length 10
```

### 📝 Add Custom Metadata

```bash
m4b-tool merge /temp/tolkien --output-file /config/lotr.m4b \
  --name "LOTR" --artist "J.R.R. Tolkien"
```

### 🔎 Split M4B by Chapters

```bash
m4b-tool split --audio-book /config/series.m4b --output-dir /temp/split
```

### 🎯 Fix Chapter Marks

```bash
m4b-tool chapters --fix /config/broken.m4b
```

---

## ✅ Requirements

* Docker
* Docker Compose
* Your own `m4b-tool.phar` in the working directory

---

## 🧼 Optional: Clean Untagged Docker Images

```bash
./clean_untagged.sh
```

# Why Containerize `m4b-tool`?

Containerizing `m4b-tool` using Docker provides numerous benefits over installing and running it directly on your host machine. Here's a breakdown of the key advantages:

---

## ✅ Reasons to Use a Docker Container

### 1. **No Local Dependency Hassles**

* Avoid installing PHP 8.2+ and various extensions (curl, zip, mbstring, etc.) manually.
* Eliminate conflicts with existing software or PHP versions on your system.

### 2. **Isolated and Clean Environment**

* Every container runs in a fresh, sandboxed environment.
* Keeps your host OS clean and free from unneeded libraries or configurations.

### 3. **Portable and Consistent**

* Docker ensures the tool works the same across all systems (Linux, Windows, macOS).
* Easily share your setup with others via Dockerfiles or GitHub.

### 4. **Reproducible Builds**

* Your Dockerfile is a documented, version-controlled record of a working setup.
* Run the same commands with the same outcomes every time.

### 5. **Great for Automation and Batch Jobs**

* Easily integrate into NAS, home servers, or CI/CD environments.
* Perfect for scheduled tasks (e.g. batch convert folders of MP3s to M4B overnight).

### 6. **Zero System Pollution**

* Don't risk modifying your global PHP configuration or package registry.
* Everything lives inside the container and can be destroyed or rebuilt easily.

---

## Summary

Docker gives you flexibility, repeatability, and peace of mind. If you're serious about working with `m4b-tool` regularly, a containerized approach is clean, maintainable, and future-proof.




---

## 👤 Credits

* [sandreas/m4b-tool](https://github.com/sandreas/m4b-tool)
* Built and containerized by James Whelan




