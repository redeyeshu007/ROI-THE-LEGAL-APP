<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0B0F19,50:14213D,100:1E3A8A&height=200&section=header&text=ROI%20—%20The%20Legal%20App&fontSize=44&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Rules%20of%20India%20%7C%20AI-Powered%20Legal%20Intelligence%20Platform&descAlignY=58&descSize=16" width="100%"/>

<a href="https://github.com/SriramGandhiS/ROI-THE-LEGAL-APP">
  <img src="https://readme-typing-svg.demolab.com/?lines=Enterprise-Grade+Legal+Intelligence+for+India;NEEDHi+%26+VIDDHI+AI+Reasoning+Engines;Flutter+%C2%B7+React+%C2%B7+Firebase+%C2%B7+Groq;IPC+to+BNS+Statute+Transformation+Engine&font=Fira+Code&center=true&width=620&height=40&color=A9B4C0&vCenter=true&size=19&pause=1800" alt="Typing SVG"/>
</a>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://react.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Groq](https://img.shields.io/badge/Groq-1A1A1A?style=for-the-badge&logo=openai&logoColor=white)](https://groq.com)
[![License](https://img.shields.io/badge/License-Proprietary-6B0F1A?style=for-the-badge)](LICENSE)

<img src="https://img.shields.io/github/repo-size/SriramGandhiS/ROI-THE-LEGAL-APP?style=flat-square&color=1E3A8A&label=REPO%20SIZE" />
<img src="https://img.shields.io/github/last-commit/SriramGandhiS/ROI-THE-LEGAL-APP?style=flat-square&color=14213D&label=LAST%20COMMIT" />
<img src="https://img.shields.io/github/contributors/SriramGandhiS/ROI-THE-LEGAL-APP?style=flat-square&color=0B0F19&label=CONTRIBUTORS" />

<br/><br/>

An enterprise-grade, multi-platform legal assistance ecosystem built with **Flutter (Mobile)** and **React (Web)**, engineered to democratize legal awareness and equip Indian citizens with constitutional and statutory knowledge through advanced artificial intelligence.

</div>

<br/>

<div align="center">

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

</div>

## Table of Contents

- [Feature & Workflow Overview](#feature--workflow-overview)
- [System Architecture](#system-architecture)
- [User Query Workflow](#user-query-workflow)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Project Directory Structure](#project-directory-structure)
- [Security & Access Configuration](#security--access-configuration)
- [Installation & Setup](#installation--setup)
- [Core Development Team](#core-development-team)
- [License & Intellectual Property](#license--intellectual-property)

<div align="center">

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

</div>

## Feature & Workflow Overview

| Module | Core Functionality | Status & Flow |
| :--- | :--- | :--- |
| **NEEDHi — AI Legal Tutor** | Real-time legal assistant for IPC and BNS sections | Active — User Query → Groq / Gemini Inference → Structured Advice |
| **Gamified Scenarios** | Legal scenario challenges with a points and ranking system | Active — Situation Simulation → Decision Logic → Score Calculation |
| **Legalytics Web Console** | Administrative dashboard for tracking user cases and queries | Active — React Dashboard → Firebase Realtime Sync → Audit Logs |
| **Multilingual Voice AI (VIDDHI)** | Voice-to-text legal query processing in regional languages | Active — Speech Input → Transcription Model → Translation → Response |

---

## System Architecture

```mermaid
graph TD
    A[Citizen User] -->|Flutter Mobile App| B(Mobile Front-End)
    A -->|React Web App| C(Web Admin / Chat Console)

    subgraph "Client Layer"
        B
        C
    end

    subgraph "Orchestration & Data Layer"
        D[Firebase Authentication]
        E[(Firestore Database)]
        F[Firebase Storage]
    end

    subgraph "AI Processing Core"
        G[Google Gemini Pro]
        H[Groq Llama 3]
        I[OpenAI GPT-4]
    end

    B -->|Auth & Analytics| D
    B -->|User Data & Offline Sync| E
    B -->|Media Uploads| F
    C -->|Configuration & Auditing| E

    B -->|Secure API Requests| G
    B -->|Voice AI Inference| H
    C -->|Deep Legal Document Parsing| I

    style A fill:#1E3A8A,stroke:#0B0F19,color:#ffffff
    style B fill:#02569B,stroke:#0B0F19,color:#ffffff
    style C fill:#20232A,stroke:#0B0F19,color:#61DAFB
    style D fill:#14213D,stroke:#0B0F19,color:#ffffff
    style E fill:#14213D,stroke:#0B0F19,color:#ffffff
    style F fill:#14213D,stroke:#0B0F19,color:#ffffff
    style G fill:#1E3A8A,stroke:#0B0F19,color:#ffffff
    style H fill:#3D3D3D,stroke:#0B0F19,color:#ffffff
    style I fill:#0B3D2E,stroke:#0B0F19,color:#ffffff
```

---

## User Query Workflow

```mermaid
sequenceDiagram
    actor U as Citizen User
    participant M as Mobile / Web App
    participant Auth as Firebase Auth
    participant AI as NEEDHi AI Engine
    participant DB as Firestore

    U->>M: Open application and authenticate
    M->>Auth: Verify credentials
    Auth-->>M: Session token issued
    U->>M: Submit legal query (text or voice)
    M->>AI: Forward query to inference engine
    AI-->>M: Structured legal response (IPC mapped to BNS)
    M->>DB: Persist query and response
    M-->>U: Display instant legal advice
    U->>M: Attempt daily quiz or scenario
    M->>DB: Store score and update ranking
    DB-->>M: Return updated leaderboard
    M-->>U: Present performance feedback
```

---

## Key Features

### NEEDHi — AI Legal Tutor
A structured AI chatbot designed to explain complex Indian constitutional law, criminal codes, and civic rights.
- **Multilingual support** — legal guidance dynamically translated and rendered in Hindi, Tamil, Telugu, Kannada, Bengali, and additional regional languages.

### VIDDHI — Voice AI Assistant
A hands-free, low-latency voice assistant that integrates browser and device microphones with real-time speech-to-text and AI legal reasoning to deliver instant verbal legal consultations.

### AI-Driven Daily Quiz
An interactive module that dynamically generates daily legal scenario challenges to assess a user's understanding of fundamental rights and constitutional provisions, with results tracked in Firebase.

### Statute Transformation (IPC to BNS)
A comparative analysis tool mapping sections of the legacy **Indian Penal Code (IPC)** directly to the newly enacted **Bharatiya Nyaya Sanhita (BNS)**, assisting both citizens and legal professionals through the transitional framework.

---

## Technology Stack

<div align="center">

| Layer | Technologies |
| :--- | :--- |
| **Mobile Framework** | Flutter (Dart), Bloc / Provider state management |
| **Web Console** | React.js, Tailwind CSS |
| **Backend & Database** | Firebase — Authentication, Firestore, Cloud Storage |
| **AI Models** | Groq Llama 3, Google Gemini Pro, OpenAI GPT-4 API |
| **Design System** | Plus Jakarta Sans and Inter typography, dark-mode-first interface |

</div>

---

---

## Security & Access Configuration

> [!IMPORTANT]
> **API Key Sanitization Notice.** All production API keys — Gemini, OpenAI, Groq, and Firebase credentials — have been removed from the public repository to mitigate security risk. To exercise the interactive AI features locally, configure your own configuration files with valid API tokens as outlined below.

---

## Installation & Setup

### Running the Flutter Mobile Application

```bash
# 1. Navigate to the mobile application directory
cd roi_app

# 2. Fetch project dependencies
flutter pub get

# 3. Add your google-services.json (from Firebase Console) to android/app/

# 4. Configure API keys in lib/consts.dart or lib/screens/ChatbotScreen.dart

# 5. Launch the application on a connected device or emulator
flutter run
```

### Running the React Web Dashboard

```bash
# 1. Navigate to the web project directory
cd legalytics-react

# 2. Install npm dependencies
npm install

# 3. Create a .env file in the project root
echo "REACT_APP_GROQ_API_KEY=your_groq_key_here" > .env

# 4. Start the development server
npm start
```

---

## Core Development Team

<div align="center">

Developed by **EAT AND LEARN TEAM**

| Avatar | Contributor | GitHub Handle | Role & Specialization | Profile |
| :---: | :--- | :--- | :--- | :---: |
| <img src="https://github.com/SriramGandhiS.png" width="48" style="border-radius:50%"> | **Sriram S** | `@SriramGandhiS` | API Integration, Overall Development & Team Management | [Profile](https://github.com/SriramGandhiS) |
| <img src="https://github.com/Solairajan1509.png" width="48" style="border-radius:50%"> | **Solairajan** | `@Solairajan1509` | Full Stack Developer | [Fork](https://github.com/Solairajan1509/ROI-THE-LEGAL-APP) |
| <img src="https://ui-avatars.com/api/?name=Vengata+Visva&background=14213D&color=fff" width="48" style="border-radius:50%"> | **Vengata Visva** | Vengata Visva | Lead Mobile Engineer & Flutter Architecture | Team Member |
| <img src="https://github.com/Suriyakumar4036.png" width="48" style="border-radius:50%"> | **Suriya Kumar** | `@Suriyakumar4036` | Research & Development | [Fork](https://github.com/Suriyakumar4036/ROI-THE-LEGAL-APP) |
| <img src="https://github.com/sanjaysekar5.png" width="48" style="border-radius:50%"> | **Sanjay Sekar** | `@sanjaysekar5` | Git Actions | [Fork](https://github.com/sanjaysekar5/ROI-THE-LEGAL-APP) |
| <img src="https://github.com/selvinjef123.png" width="48" style="border-radius:50%"> | **Selvin Jef** | `@selvinjef123` | Quality Assurance / Tester | [Fork](https://github.com/selvinjef123/ROI-THE-LEGAL-AP) |
| <img src="https://github.com/redeyeshu007.png" width="48" style="border-radius:50%"> | **Red Eye Shu** | `@redeyeshu007` | Lead Solution Architect & Feature Specialist | [Fork](https://github.com/redeyeshu007/ROI-THE-LEGAL-APP) |
| <img src="https://github.com/rizz-architect.png" width="48" style="border-radius:50%"> | **Rizz Architect** | `@rizz-architect` | CI/CD Pipeline & Automated Workflows | [Fork](https://github.com/rizz-architect/ROI-THE-LEGAL-APP) |

</div>

---

## License & Intellectual Property

**Hackathon Project** — all rights reserved by **EAT AND LEARN TEAM**.

This repository is published exclusively for educational review, architectural assessment, and portfolio evaluation. Unauthorized replication, redistribution, commercialization, or modification of this source code is strictly prohibited without consent from the **EAT AND LEARN TEAM**.

*Developed by **EAT AND LEARN TEAM**.*

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1E3A8A,50:14213D,100:0B0F19&height=110&section=footer"/>

**EAT AND LEARN TEAM**

</div>
