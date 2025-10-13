# 🎵 Cadence: Life in Music

**A modern, idle life simulation game focused on the music industry.**

![Platform](https://img.shields.io/badge/platform-iOS%2016.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-Proprietary-red)

---

## 📖 Overview

**Cadence: Life in Music** is the first title in the *Cadence* series by **Lunae Studio**. Build your music career from street performer to global superstar through skill progression, songwriting, recording, live performances, and reputation management.

### Core Features (MVP)

- ✅ **Idle Progression** - Your career continues even when offline
- ✅ **Music Creation** - Write songs, rehearse, record, and release
- ✅ **Live Performances** - Book gigs at venues across 5 global cities
- ✅ **Multiplayer** - Collaborate on concerts, compete on charts
- ✅ **Non-Pay-to-Win** - Cosmetic-only monetization

---

## 🏗️ Architecture

### Tech Stack

- **Frontend**: SwiftUI + Swift 5.9+
- **Persistence**: SwiftData (local cache)
- **Backend**: Supabase (Postgres + PostgREST + Realtime)
- **Auth**: Apple Game Center
- **Analytics**: TelemetryDeck (privacy-first)
- **Crash Reporting**: Sentry
- **CI/CD**: GitHub Actions + Fastlane

### Module Structure

CadenceLifeInMusic/
├── Packages/
│   ├── CadenceAuth          # Game Center authentication
│   ├── CadenceCore          # Domain models & protocols
│   ├── CadenceMusicLoop     # Songwriting, gigs, recording
│   ├── CadenceEconomy       # Wallet, transactions, equipment
│   ├── CadenceSocial        # Messaging, collaboration
│   ├── CadenceNetworking    # Supabase client
│   ├── CadenceUI            # Reusable SwiftUI components
│   └── CadencePersistence   # SwiftData models
├── CadenceLifeInMusic/      # Main app target
├── Tests/                   # Unit tests
├── UITests/                 # UI automation tests
├── fastlane/                # Deployment automation
└── docs/                    # Documentation

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+**
- **iOS 16.0+ Simulator or Device**
- **Apple Developer Account** (for Game Center & TestFlight)
- **Supabase Project** (see [Backend Setup](docs/guides/backend-setup.md))

### Installation

1. **Clone the repository**:
```bash
   git clone https://github.com/aylinulaba/cadence-life-in-music-ios.git
   cd cadence-life-in-music-ios
