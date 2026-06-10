# Berger LMS UI Paths and Dynamic Parameter Reference

This document outlines the routes, query parameters, and example URL configurations for the frontend pages in the Berger Lead Management System (LMS).

- **Base URL**: `https://lms-berger-ui.vercel.app/`
- **Sample UUIDs for reference**:
  - User ID (Retailer/Painter/Customer/DSE/DSO): `7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d`
  - Lead ID: `9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

## Page Routing Matrix

### 1. Lead Capture Form
* **Filename**: `lead-capture-form.html`
* **Role**: Retailer (to capture and submit new customer leads)
* **Required Parameters**:
  - `id`: The UUID of the Retailer submitting the form.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/lead-capture-form.html?id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d`

---

### 2. User Open Leads Pipeline
* **Filename**: `open-leads-by-user-type.html`
* **Role**: Retailer, Painter, or Customer (dynamically alters layout, themes, and capabilities based on user type matched in the DB)
* **Required Parameters**:
  - `id`: The UUID of the user (Retailer ID, Painter ID, or Customer ID).
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/open-leads-by-user-type.html?id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d`

---

### 3. Painter Invitation Response Portal
* **Filename**: `painter-response.html`
* **Role**: Painter (to accept or decline a newly auto-assigned lead)
* **Required Parameters**:
  - `painter_id`: The UUID of the assigned Painter.
  - `lead_id`: The UUID of the corresponding Lead opportunity.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/painter-response.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 4. Painter Job Calendar
* **Filename**: `painter-calendar.html`
* **Role**: Painter (to view monthly/weekly scheduled consults and check-in history)
* **Required Parameters**:
  - `painter_id`: The UUID of the Painter.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/painter-calendar.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d`

---

### 5. Project Tools Menu
* **Filename**: `project-tools.html`
* **Role**: Painter (hub page shown after checking in to direct painters to tool sub-modules)
* **Required Parameters**:
  - `painter_id`: The UUID of the Painter.
  - `lead_id`: The UUID of the active Lead.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/project-tools.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 6. Create & Submit Estimate
* **Filename**: `submit-estimate.html`
* **Role**: Painter (to build items and submit volumes/values for a project estimate)
* **Required Parameters**:
  - `painter_id`: The UUID of the Painter.
  - `lead_id`: The UUID of the active Lead.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/submit-estimate.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 7. Product Catalog & Knowledgebase
* **Filename**: `berger-paints-product-knowledgebase.html`
* **Role**: Painter (reference technical specifications, segment tags, and application guides)
* **Required Parameters**:
  - `userid`: The UUID of the Painter/User viewing the directory.
  - `leadid`: The UUID of the active Lead.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/berger-paints-product-knowledgebase.html?userid=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&leadid=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 8. View Estimate Summary
* **Filename**: `view-estimate.html`
* **Role**: Retailer, Painter, or Customer (to view breakdown, totals, and download PDF)
* **Required Parameters**:
  - `id` (or `userid`): The UUID of the authorized user.
  - `lead_id` (or `leadid`): The UUID of the corresponding Lead opportunity.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/view-estimate.html?id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 9. Schedule Follow-Up
* **Filename**: `schedule-followup.html`
* **Role**: Painter (to register follow-up dates/times when a site visit doesn't instantly close)
* **Required Parameters**:
  - `painter_id`: The UUID of the Painter.
  - `lead_id`: The UUID of the Lead.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/schedule-followup.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 10. Mark Site as Won
* **Filename**: `site-won.html`
* **Role**: Painter (to close the opportunity as won)
* **Required Parameters**:
  - `painter_id`: The UUID of the Painter.
  - `lead_id`: The UUID of the Lead.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/site-won.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 11. Mark Site as Lost
* **Filename**: `site-lost.html`
* **Role**: Painter (to select loss reasons and close the opportunity)
* **Required Parameters**:
  - `painter_id`: The UUID of the Painter.
  - `lead_id`: The UUID of the Lead.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/site-lost.html?painter_id=7a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d&lead_id=9f8e7d6c-5b4a-3f2e-1d0c-9b8a7f6e5d4c`

---

### 12. Corporate/Admin Dashboard
* **Filename**: `dashboard.html`
* **Role**: DSE or DSO (executive metrics, goal tracking, and organizational drilldown)
* **Parameters**: Authenticates and stores session data via `login.html`.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/dashboard.html`

---

### 13. Login Page
* **Filename**: `login.html`
* **Role**: DSO/DSE Portal access authentication.
* **Sample URL**:
  `https://lms-berger-ui.vercel.app/login.html`
