
Why This Structure?
Separation of Concerns:
Core: Keeps app-wide setup separate from business logic or UI.

Models: Centralizes data structures for easy access and modification.

Managers: Isolates logic and state management (e.g., RSProfileManager handles profiles, FITREPImporter handles imports).

Views: Groups primary screens for navigation and high-level UI.

Components: Separates reusable UI pieces to avoid cluttering Views and promote reuse.

Sections: Keeps sectional UI components (specific to larger views like LogbookView) organized.

Utilities: Houses extensions and static data that don’t belong elsewhere.

Scalability:
As your app grows, adding new views, components, or managers won’t clutter the structure.

New utility functions or models can easily slot into their respective folders.

Maintainability:
Finding a file is intuitive (e.g., need a view? Check Views; need a model? Check Models).

Refactoring or updating a component (like DraftRow) won’t affect unrelated files.

Consistency with Your Existing Structure:
Builds on your current folders (Managers, Views, etc.) while organizing unplaced files (ContentView.swift, AttributeGuidance.swift, etc.).

Core
FitnessReportApp.swift: The main entry point of the app, defining the app’s structure using SwiftUI’s @main attribute. It initializes the ContentView as the root view.

Persistence.swift: Configures Core Data persistence for the app, providing a shared controller and an in-memory preview instance for testing.

Theme.swift: Manages the app’s background gradient theme, providing a reusable LinearGradient and a View extension to apply it based on the user’s color scheme (light/dark mode).

Models
DueDates.swift: Defines the DueDate struct for FITREP due dates by rank and component (active, reserve, active reserve), with a singleton DueDates class providing a static list of due dates.

FitnessReport.swift: Represents a single Fitness Report (FITREP) with properties like name, grade, attributes, and status. Includes logic to calculate the MRO average and supports JSON encoding/decoding.

Managers
RSProfileManager.swift: Manages the app’s FITREP data, storing profiles in a JSON file (profiles.json). Handles adding, updating, deleting, and calculating statistics (e.g., averages, relative values) for reports, with automatic saving and loading.

FITREPImporter.swift: Parses FITREP data from PDF files or text, converting it into FitnessReport objects and importing them into RSProfileManager. Includes logic to estimate attributes from averages.

Views
ContentView.swift: The root view of the app, presenting a tabbed interface with LogbookView, ProfileView, and MROView. Manages the Terms of Use prompt based on user acceptance.

DashboardView.swift: Displays a chart-based dashboard for a specific grade, showing relative values (RV) of published reports over time, with options to view details or share as PDF.

LogbookView.swift: Presents a comprehensive logbook with sections for dashboard stats, draft reports, and FITREP due dates, supporting refresh and draft details navigation.

MROView.swift: Manages Marine Reported On (MRO) reports, displaying drafts and published reports with filtering by grade, and allowing adding, editing, and sharing reports.

ProfileView.swift: Provides profile management options, including importing reports from PDFs, sharing the app, and clearing all data, with a custom gradient background.

ReportDetailView.swift: Shows detailed information for a selected FitnessReport, including attributes and metadata, with options to edit or share as PDF.

ReportEditorView.swift: Allows editing or creating a FitnessReport, with fields for name, grade, attributes, and billet details, including validation and attribute guidance.

TermsOfUseView.swift: Displays the app’s Terms of Use, requiring user acceptance to proceed, storing acceptance status in UserDefaults.

Components
DashboardRow.swift: A reusable row component for the dashboard, displaying grade, report count, and statistics (high, average, low) with a grade-specific image.

DraftRow.swift: A swipeable row component for draft reports, showing key details (grade, name, due date, type) with options to publish or delete via swipe gestures.

ShareSheet.swift: A UIViewControllerRepresentable wrapper for UIActivityViewController, enabling sharing of content (e.g., text or URLs) from the app.

SharePDFView.swift: Generates and shares a PDF report for a selected FitnessReport, including ranking and attribute details, using UIGraphicsPDFRenderer.

AttributeGuidanceView.swift: A popup view providing detailed guidance for a selected attribute, allowing the user to choose a grade (A-H) based on definitions.

Sections
LogbookSections.swift: Contains sectional views for LogbookView:
DashboardSection: Displays aggregated stats for published reports by grade.

DraftsSection: Lists draft reports with tappable rows.

DueDatesSection: Shows FITREP due dates by rank and component with grade images.

Utilities
Calendar+Extensions.swift: Extends Calendar with a helper method to calculate the start of a month for a given date.

AttributeGuidance.swift: Provides static data for attribute definitions and rating guidance (A-H) used in AttributeGuidanceView and ReportEditorView.

Preview Content
Preview Assets (assumed folder): Contains images and other assets used for previews (e.g., grade insignia), referenced in views like DraftRow and DueDatesSection.

