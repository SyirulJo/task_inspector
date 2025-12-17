# Task Inspector 📋

A comprehensive Flutter-based task inspection and reporting application designed for operational, maintenance, and facility management use cases.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 🌟 Features

### Core Functionality
- **Role-Based Access Control** - Separate dashboards for Administrators and Staff
- **QR Code Verification** - Ensure personnel are at the correct location before task execution
- **Dynamic Checklists** - Configurable forms with multiple input types (Pass/Fail, Text, Ratings)
- **Photo Attachment** - Capture up to 5 photos per report with camera/gallery support
- **Task Creation Flow** - Complete admin workflow to create and assign tasks
- **Analytics Dashboard** - Visual insights with charts and performance metrics

### Admin Features
- View all assets and their QR codes
- Create custom tasks with dynamic checklists
- Assign tasks to staff members with scheduling
- Monitor completion rates and quality trends
- Review submitted reports with photos and timestamps

### Staff Features
- View assigned tasks with status indicators
- Scan QR codes to verify location
- Complete checklists with photo evidence
- Submit reports with automatic timestamps
- Track personal task history

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK
- Chrome (for web testing) or Android/iOS device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SyirulJo/task_inspector.git
   cd task_inspector
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run build_runner** (for Hive type adapters)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run -d chrome  # For web
   flutter run            # For mobile
   ```

## 🧪 Testing

### Quick Test Credentials
- **Admin**: `admin@test.com` / `password`
- **Staff**: `staff@test.com` / `password`

Or use the quick login buttons on the login screen.

### Test Scenarios

**Admin Workflow:**
1. Login as Admin
2. Click analytics icon to view dashboard
3. Click "Assign Task" to create a new task
4. View asset QR codes

**Staff Workflow:**
1. Login as Staff
2. Select a task from the dashboard
3. Scan QR code (use simulation on web)
4. Complete checklist and add photos
5. Submit report

## 📁 Project Structure

```
lib/
├── main.dart
└── src/
    ├── core/
    │   └── theme.dart
    ├── features/
    │   ├── authentication/
    │   │   ├── domain/
    │   │   ├── data/
    │   │   └── presentation/
    │   ├── assets/
    │   ├── tasks/
    │   ├── reports/
    │   └── dashboard/
    ├── shared/
    │   └── widgets/
    └── routing/
        └── app_router.dart
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive
- **Charts**: FL Chart
- **QR Scanning**: Mobile Scanner
- **Image Handling**: Image Picker

## 📊 Architecture

The app follows **Clean Architecture** principles with a feature-first approach:

- **Domain Layer**: Models and business logic
- **Data Layer**: Repositories and data sources
- **Presentation Layer**: UI components and state management

## 🎨 Design

- **Theme**: Modern Slate/Sky color palette
- **UI Framework**: Material Design 3
- **Typography**: Google Fonts (Inter)
- **Responsive**: Works on mobile, tablet, and web

## 📸 Screenshots

### Admin Dashboard
View assets, reports, and access analytics

### Task Creation
Dynamic checklist builder with multiple question types

### Staff Task Execution
QR verification, photo capture, and report submission

### Analytics Dashboard
Completion trends and quality distribution charts

## 🔄 Offline Support

The app uses a local-first architecture with Hive, allowing:
- Offline task completion
- Local data persistence
- Future sync capabilities

## 🚧 Future Enhancements

- [ ] Push notifications for task assignments
- [ ] Signature capture
- [ ] PDF report generation
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Backend integration (Firebase/AWS)
- [ ] Recurring tasks
- [ ] Advanced filtering and search

## 📝 License

This project is licensed under the MIT License.

## 👥 Contributors

- **Syahirul Johari** - Initial work

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
