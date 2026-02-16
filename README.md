<p align="center">
  <img src="https://avatars.githubusercontent.com/u/149707645?s=400&v=4" width="220" alt="NeoServ Logo"/>
</p>

<h1 align="center">NeoServ IPTV Panel</h1>
<p align="center">
  <b>Open-source, community-driven Xtream Codes panel</b><br>
  Built for modern IPTV workflows – powerful, scalable, and free.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/xneoserv/NeoServ" /></a>
  <a href="https://github.com/xneoserv/NeoServ/stargazers"><img src="https://img.shields.io/github/stars/xneoserv/NeoServ?style=flat" /></a>
  <a href="https://github.com/xneoserv/NeoServ/issues"><img src="https://img.shields.io/github/issues/xneoserv/NeoServ" /></a>
</p>

---

# 📑 Table of Contents

<details open>
<summary><strong>📘 Contents</strong></summary>

* 🏁 [Overview](#-overview)
* ⚠️ [Status](#️-status)
* 🧱 [Technology Stack](#-technology-stack)
* 🧩 [Ubuntu Support](#-supported-ubuntu-versions)
* 📥 [Quick Install](#-quick-install)
* 🧰 [Service Management](#-service-management)
* 📂 [Project Structure](#-project-structure)
* 🧮 [Server Requirements & Sizing](#-server-requirements--sizing)
* ⭐ [Features](#-features)
* 🐞 [Known Limitations](#-known-limitations)
* 🤝 [Contributing](#-contributing)
* 📜 [License](#-license)
* ⚖️ [Legal Disclaimer](#-legal-disclaimer)

</details>

---

## 🚀 Overview

**NeoServ** is an open-source IPTV platform based on Xtream Codes.
It enables:

* 📺 Live & VOD streaming
* 🔀 Load balancing
* 📊 Full user/reseller control
* 🎚️ Transcoding & EPG
* 🔐 Hardened security fixes

> ✅ 100% free. No license checks. No server locks.

---

## ⚠️ Status

> **BETA SOFTWARE** — actively developed

---

## 🧱 Technology Stack

| Component | Version    | Description                     |
| --------- | ---------- | ------------------------------- |
| PHP       | 8.2        | Backend runtime                 |
| Nginx     | 1.24       | Web server & reverse proxy      |
| FFmpeg    | 8.0, 7.1, 5.1, 4.4, 4.3, 4.0        | Media transcoding & processing  |
| MariaDB   | 11.4      | SQL database engine             |
| KeyDB     | 6.3.4      | Cache & session storage (Redis) |
| yt-dlp    | 2025.07.21 | Audio/Video downloader          |

---

## 🐧 Supported Ubuntu Versions

NeoServ **officially supports** the following Ubuntu LTS and interim releases:

| Ubuntu Version | Codename        | Status                |
| -------------- | --------------- | --------------------- |
| **22.04**      | Jammy Jellyfish | ✅ **Fully Supported** |
| **22.10**      | Kinetic Kudu    | ⚙️ *Compatible*       |
| **24.04**      | Noble Numbat    | ✅ **Fully Supported** |
| **24.10**      | Oracular Oriole | 🧪 *Under Testing*    |

---

### 💡 Recommendations

For new installations, the **strongly recommended** Ubuntu versions are:

* 🟢 **Ubuntu 22.04 LTS**
* 🟢 **Ubuntu 24.04 LTS**

---

## 📥 Quick Install

> ✅ Ubuntu 22.04 or newer

```bash
# 1. Update system
sudo apt update && sudo apt full-upgrade -y

# 2. Install dependencies
sudo apt install -y python3-pip unzip

# 3. Download and install NeoServ
# (Installation script will be updated)
sudo python3 install
```

---

## 🧰 Service Management

```bash
sudo systemctl start neoserv     # Start
sudo systemctl stop neoserv      # Stop
sudo systemctl restart neoserv   # Restart
sudo systemctl status neoserv    # Status
sudo /home/neoserv/bin/nginx/sbin/nginx -s reload    # Reload Nginx config
journalctl -u neoserv -f         # Live logs
```

---

## 📂 Project Structure

```text.
├─ docs/        # 📚 Project documentation
├─ lb_configs/  # ⚙️ Configurations for building Load Balancer (LB)
└─ src/         # 💻 Main project code
```

---

## 🧮 Server Requirements & Sizing

### 🔧 Minimum Specs

| Component | Recommendation                |
| --------- | ----------------------------- |
| CPU       | 6+ cores (Xeon/Ryzen)         |
| RAM       | 16–32 GB                      |
| Disk      | SSD/NVMe, 480+ GB             |
| Network   | Dedicated 1 Gbps port         |
| OS        | Ubuntu 22.04+ (clean install) |

---

### 📊 Planning Formulae

* **Bandwidth (Mbps)** = Channels × Bitrate
* **Max Users** = Bandwidth ÷ Stream Bitrate

```text
Example:
HD bitrate = 4 Mbps
1 Gbps = ~940 usable Mbps

→ Max Channels: 940 ÷ 4 = ~235
→ Max Users:    940 ÷ 4 = ~235
```

> ⚠️ 10 users watching the same channel = 10× bandwidth (unless caching or multicast used)

---

### 💻 RAM & CPU Usage

| Resource         | Load per Stream |
| ---------------- | --------------- |
| RAM              | 50–100 MB       |
| CPU (transcoded) | ~1 core         |

---

## ✅ Features

* ✅ No server restrictions
* ✅ EPG importer
* ✅ VOD management
* ✅ User/reseller panel
* ✅ Security patches
* ✅ Clean UI

---

## 🔧 Known Limitations

* ❌ Requires Linux knowledge
* ❌ Community-based support
* ❌ Some bugs in transcoding module (in progress)

---

## 🤝 Contributing

We welcome community help!

* 🛠️ [Contributing Guide](CONTRIBUTING.md)
* 👥 [Contributors List](CONTRIBUTORS.md)

---

## 📝 License

[AGPL v3.0](LICENSE)

---

## ⚠️ Legal Disclaimer

> 🚫 **This software is for educational purposes only.**
> ⚖️ You are solely responsible for how it is used.
> We take no responsibility for misuse or illegal deployments.

---
