# Attendance Tracker App  
### (100% Local-First, Offline Flutter Application)

## Technical & Implementation Documentation

---

## 1. Project Overview

### 1.1 Product Summary

The Attendance Tracker App is a **fully offline, local-only mobile application** built using **Flutter**.  
It allows students to **track, analyze, and manage attendance** without requiring:

- Internet connection
- Backend server
- User login
- Cloud storage

All data is stored **locally on the user's device**, ensuring **privacy, speed, and reliability**.

---

### 1.2 Key Characteristics

| Aspect | Description |
|------|------------|
| Platform | Flutter (Android / iOS) |
| Architecture | Feature-Based Clean Architecture |
| State Management | GetX |
| Data Storage | Local (SQLite / Hive / SharedPreferences) |
| Connectivity | Fully Offline |
| User Type | Single User |
| Privacy | Device-only storage |

---

## 2. Problem Statement

Students often fail to maintain attendance because:

- Attendance is not tracked daily
- Manual calculations are confusing
- Low attendance is realized too late

There is a need for a **simple, offline, personal attendance tracker** that provides:

- Daily attendance marking
- Automatic percentage calculation
- Early warnings for low attendance

---

## 3. Target Users

- College students
- Engineering students
- Students with strict attendance requirements
- Users who prefer **privacy and offline apps**

---

## 4. Goals & Objectives

### Primary Goals
- Track subject-wise attendance
- Calculate overall attendance automatically
- Prevent attendance from falling below minimum threshold

### Secondary Goals
- Simple and fast UI
- Offline-first experience
- Zero data sharing

---

## 5. Key Assumptions

- Single user per device
- Attendance is marked manually
- No teacher/admin involvement
- Data is for personal reference only

---

## 6. High-Level Architecture

### 6.1 Architecture Style

The app follows a **Feature-Based Modular Architecture** with **clean separation of concerns**.

Each feature is self-contained and includes:
- UI
- State
- Business logic
- Data handling

---

### 6.2 Project Folder Structure

lib/
├── core/
│ ├── constants/
│ ├── utils/
│ ├── theme/
│ ├── routes/
│ └── services/
│--- docs 
├── features/
│ ├── timetable/
│ ├── attendance/
│ ├── dashboard/
│ ├── calendar/
│ └── settings/
│
└── main.dart


---

### 6.3 Feature Folder Structure (Standard)

features/
└── feature_name/
├── controller/
├── data/
│ └── model/
├── implementor/
├── interactor/
└── pages/


---

## 7. Layer Responsibilities

### 7.1 Controller Layer
- Manages UI state
- Uses GetX reactive variables
- Calls interactors
- Updates UI

### 7.2 Interactor Layer
- Contains business logic
- Performs calculations
- Validates rules and conditions

### 7.3 Implementor Layer
- Handles local data storage
- Reads/writes from database
- Abstracts persistence logic

### 7.4 Data / Model Layer
- Defines data structures
- Represents database entities

### 7.5 Pages Layer
- UI screens
- Handles user interaction

---

## 8. Feature Details

---

## Feature 1: Timetable Management

### Purpose
Allow users to create a **weekly timetable** reused every week.

### Folder Structure
features/timetable/
├── controller/
├── data/model/
├── implementor/
├── interactor/
└── pages/


### Data Model

class TimetableEntry {
  String id;
  String subjectId;
  int dayOfWeek;
  String startTime;
  String endTime;
  String type;
}

### Flow

- User adds subject and lecture details

- Data saved locally

- Timetable reused weekly

## Feature 2: Attendance Marking
### Purpose

- Allow users to mark attendance daily.

### Folder Structure

features/attendance/
 ├── controller/
 ├── data/model/
 ├── implementor/
 ├── interactor/
 └── pages/

### Data Model
class AttendanceRecord {
  String id;
  String subjectId;
  DateTime date;
  bool isPresent;
}

### Flow

- App shows today's lectures

- User marks Present / Absent

- Attendance saved locally

## Feature 3: Attendance Calculation Engine
### Formula

Attendance % = (Attended Lectures / Total Lectures) × 100
### Responsibilities

- Calculate subject-wise attendance

- Calculate overall attendance

- Detect low attendance

## Feature 4: Dashboard & Analytics
### Purpose
- Provide a visual overview of attendance.

### Displays

- Overall attendance %

- Subject-wise cards

- Color indicators:

- Green (Safe)

- Yellow (Warning)

- Red (Danger)

## Feature 5: Calendar View
### Purpose
Show attendance history in calendar format.

### Capabilities

- Monthly / weekly view

- Daily attendance summary

- Historical insights

## Feature 6: Settings & Preferences
### Purpose
- Allow user configuration and data safety.

### Options

- Minimum attendance %

- Enable notifications

- Export / Import data (JSON)

- Reset all data

## Navigation & Routing

### Uses open_route

- Centralized route management

- Feature-based navigation

### Example Routes:

- /dashboard
- /timetable
- /today
- /calendar
- /settings

## State Management (GetX)
### Why GetX?

- Lightweight

- Reactive

- Easy dependency injection

- Ideal for offline apps

### Controller Lifecycle

- onInit(): Load local data

- onReady(): Bind UI

- onClose(): Cleanup

## Local Storage Strategy
### Storage Usage

| Data Type	Storage |
| --- | --- |
| Timetable	SQLite / Hive |
| Attendance	SQLite / Hive |
| Settings	SharedPreferences |

### Rules

- No internet access

- No cloud sync

- Manual export/import only

## Notifications
### Use Cases

- Attendance below threshold

- Daily reminder to mark attendance

### Implementation

- Local notifications only

- Triggered after attendance updates

## Non-Functional Requirements
### Requirement	Description

- Offline	Fully functional offline

- Performance	Fast load & response

- Battery	Low background usage

- Privacy	No data sharing

- UX	Simple & clean UI

## MVP Scope Summary

- Timetable creation

- Daily attendance marking

- Automatic calculations

### Dashboard analytics

### Calendar history

### Local alerts

### Offline storage

## Future Enhancements
### Attendance prediction

### Recovery planner

### Home screen widget

### Optional cloud backup

## Conclusion
- The Attendance Tracker App is a privacy-first, offline-first Flutter application designed to solve a real-world student problem.

### It demonstrates:

- Clean architecture

- Strong local data handling

- Scalable feature-based design

- Production-ready structure

### This project is suitable for:

- Academic submission

- Portfolio showcase

- Real-world usage

