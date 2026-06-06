# Berger LMS - Pages and Workflows Documentation

This document describes the front-end pages and back-end integration workflows implemented for the Berger Lead Management System (LMS).

---

## 1. Frontend Pages (saved in `/UI`)

### A. Retailer Lead Capture Form
* **File Path:** [lead-capture-form.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/lead-capture-form.html)
* **Access URL:** `http://<host>:<port>/UI/lead-capture-form.html?id=<retailer_id>`
* **Description:** A mobile-first form designed for paint retailers to log new painting/waterproofing customer requests. 
* **Key Features:**
  - Dynamic profile loading (retrieves retailer name from n8n query).
  - Strict mandatory field validation (except Address Line 2).
  - Standardized Carpet Area selector (converting text choices to mapped numeric values).
  - Asynchronous form submission to n8n orchestration webhooks without page reload.
  - Visual loading overlays and success/error status toasts.

### B. Painter Lead Response Form
* **File Path:** [painter-response.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/painter-response.html)
* **Access URL:** `http://<host>:<port>/UI/painter-response.html?painter_id=<painter_id>&lead_id=<lead_id>`
* **Description:** A mobile-first interactive response page for assigned painters to accept or decline lead opportunities.
* **Key Features:**
  - Validates and checks lead assignment status dynamically on page load.
  - Hides sensitive customer details initially, only displaying general location and schedule.
  - Displays a dedicated "regret/expired" page if the lead has been assigned to someone else or has expired.
  - Interactive "Accept" and "Decline/Reject" actions triggering real-time n8n API updates.
  - On acceptance, dynamically reveals full customer details (name, contact link, full address, carpet area, estimated budget) without reloading the page.

### C. Open Leads by User Type Dashboard
* **File Path:** [open-leads-by-user-type.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/open-leads-by-user-type.html)
* **Access URL:** `http://<host>:<port>/UI/open-leads-by-user-type.html?id=<userid>` or `?userid=<userid>`
* **Description:** A smart, premium mobile-first landing dashboard that queries user roles and adapts its headers, styling themes, and lead items for Retailers, Painters, or Customers.
* **Key Features:**
  - Dynamic user profiling (avatar, name, role indicator).
  - Role-specific color schemes (Green for Retailer, Blue for Painter, Gold for Customer) and headings.
  - Generates clickable lead tiles with status badges (`CREATED`, `ASSIGNED`, `ACCEPTED`, `VISITED`, `FOLLOWUP`).
  - Gracefully displays a detailed empty state if there are no open leads matching the account.
  - Visual status overlays and mock click handlers ready for downstream sequence triggers.

### D. Schedule Follow-up Page
* **File Path:** [schedule-followup.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/schedule-followup.html)
* **Access URL:** `http://<host>:<port>/UI/schedule-followup.html?lead_id=<lead_id>&id=<painter_id>&visit_number=<visit_number>&owner_name=<name>&owner_mobile=<mobile>&address=<address>`
* **Description:** A specialized scheduling form for Painters to schedule their next site check-in follow-up.
* **Key Features:**
  - Displays read-only project metadata (client name, client mobile, project address, active visit count) passed from the parent page.
  - Custom date and time selectors.
  - Asynchronously posts to `/schedule-followup` to insert followups log, updates leads next follow-up date, and transitions status history from `VISITED` to `FOLLOWUP`.

### E. Submit Estimate Page
* **File Path:** [submit-estimate.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/submit-estimate.html)
* **Access URL:** `http://<host>:<port>/UI/submit-estimate.html?lead_id=<lead_id>&id=<painter_id>&visit_number=<visit_number>&owner_name=<name>&owner_mobile=<mobile>&address=<address>&painter_name=<pname>&retailer_name=<rname>`
* **Description:** An interactive estimation submission module with client details and branding logo.
* **Key Features:**
  - Dynamic mode switching: Supply Only vs Supply & Apply.
  - Dynamic type switching: Volume (L/Kg) vs Value (price per unit).
  - Fetches product SKUs dynamically from GET `/products`.
  - Conditional apply/manpower charges in INR (Supply & Apply mode only).
  - Collapsible history panel aggregating previous estimates from GET `/previous-estimates`.
  - Asynchronously posts to `/submit-estimate`.

### F. Confirm Site Won Page
* **File Path:** [site-won.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/site-won.html)
* **Access URL:** `http://<host>:<port>/UI/site-won.html?lead_id=<lead_id>&id=<painter_id>&visit_number=<visit_number>&owner_name=<name>&owner_mobile=<mobile>&address=<address>&painter_name=<pname>&retailer_name=<rname>`
* **Description:** A mobile-first confirmation screen where painters review their latest estimate before registering a site as Won.
* **Key Features:**
  - Automatically queries estimate history to retrieve and display the latest version.
  - Generates warning/block state if no estimates have been submitted yet.
  - Dynamically computes and formats volumetric/financial subtotals and grand totals matching the confirmed estimate parameters.
  - Buttons to proceed to confirm or redirect to edit/submit a new estimate.
  - Asynchronously triggers mark site won flow.

### G. Confirm Site Lost Page
* **File Path:** [site-lost.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/site-lost.html)
* **Access URL:** `http://<host>:<port>/UI/site-lost.html?lead_id=<lead_id>&id=<painter_id>&visit_number=<visit_number>&owner_name=<name>&owner_mobile=<mobile>&address=<address>&painter_name=<pname>&retailer_name=<rname>`
* **Description:** A mobile-first screen for painters to register a site closure when a lead is lost.
* **Key Features:**
  - Queries GET `/lost-reasons` to fetch reasons from the database.
  - Provides a stylized single-select dropdown of reasons (e.g. Price Too High, Chosen Another Brand).
  - Submit action records the site as Lost and returns the user to the landing dashboard pipeline.

---

## 2. Configuration Settings

### A. Webhook configuration
* **File Path:** [config.js](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/config.js)
* **Description:** Stores the base URL path (`CONFIG.N8N_WEBHOOK_URL`) for n8n API queries so webhooks can be updated globally without changing source code.

---

## 3. Backend Workflows (saved in `/Backend`)

### A. Lead Capture & Profile Handler Nodes
* **File Path:** [lead-capture-form-nodes.json](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/Backend/lead-capture-form-nodes.json)
* **Type:** n8n workflow pipeline.
* **Integrations:** Standard Postgres database nodes connecting directly to Supabase.
* **Workflows Included:**
  
  #### 1. Retailer Profile Load (GET `/profile`)
  - **Trigger:** Webhook GET request.
  - **Flow:** Takes `retailer_id` parameter &rarr; queries database to check if user exists and is active &rarr; responds via webhook node with user details.
  
  #### 2. Lead Capture Submission (POST `/lead-capture`)
  - **Trigger:** Webhook POST request containing lead payload details.
  - **Flow:** 
    - Inserts or updates (upserts) the customer in the `users` table as a `'CUSTOMER'` using their unique mobile number.
    - Inserts a record in the `leads` table using standard SQL insert (maps carpet area string range to numeric representation).
    - Inserts a status transition record into the `lead_status_history` table as `CREATED`.
    - Invokes the painter assignment subworkflow (`POST /assign-painter`) via an HTTP Request node, passing the newly generated `lead_id` and the `retailer_id`.
    - Returns the combined response containing both lead creation success and matched painter assignment details (such as name, mobile, and final assignment score).

### B. Painter Auto-Assignment Logic Nodes
* **File Path:** [painter-assignment-nodes.json](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/Backend/painter-assignment-nodes.json)
* **Type:** n8n workflow pipeline.
* **Integrations:** Standard Postgres database nodes querying Supabase views and updating tables.
* **Workflows Included:**
  
  #### 1. Auto Painter Assignment (POST `/assign-painter`)
  - **Trigger:** Webhook POST request containing `lead_id` and `retailer_id`.
  - **Flow:** 
    - Queries the database view `painter_matching_scores` (filtering out painters who have already been assigned this lead ID before).
    - Checks candidate scores computed dynamically by formula: `(0.4 * Acceptance) + (0.4 * Conversion) + (0.2 * Availability)`.
    - Selects top candidate (respecting equal opportunity priority `allocated_sites = 0` first, then final score DESC, then last assigned date ASC).
    - If found: updates the lead table, creates a record in `lead_assignment_history`, logs audit history to `lead_status_history`, and upserts/increments the painter stats in `painter_performance`.
    - Responds with `assigned` state alongside painter ID, name, mobile, and matching score.
    - If not found: responds with `unassigned` 404 state.

### C. Painter Response Handler Nodes
* **File Path:** [painter-response-nodes.json](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/Backend/painter-response-nodes.json)
* **Type:** n8n workflow pipeline.
* **Integrations:** Standard Postgres database nodes querying and updating Supabase tables, and outbound HTTP request nodes for re-triggering assignments.
* **Workflows Included:**

  #### 1. Fetch Lead Details (GET `/painter-lead-details`)
  - **Trigger:** Webhook GET request with `painter_id` and `lead_id` query parameters.
  - **Flow:** Queries the database to check if the lead status is `ASSIGNED`, current matched painter is `painter_id`, and assignment status is `PENDING`. If found, returns the address components and scheduled visit times. If not found or expired, returns a 404 error with a regret response.

  #### 2. Process Response (POST `/painter-response`)
  - **Trigger:** Webhook POST request containing `action` (`accept` or `reject`), `painter_id`, and `lead_id`.
  - **Flow:**
    - Checks database to verify if the assignment is still valid and `PENDING`.
    - **Accept Flow:**
      - Updates `lead_assignment_history.response_status` to `'ACCEPTED'`.
      - Updates `leads.current_status` to `'ACCEPTED'`.
      - Inserts log in `lead_status_history` with status `'ACCEPTED'`.
      - Upserts `painter_performance` counters (`allocated_sites`, `accepted_sites`, `open_leads`).
      - Responds with the complete customer info (name, mobile, budget, area) to show in the UI.
    - **Reject Flow:**
      - Updates `lead_assignment_history.response_status` to `'REJECTED'`.
      - Inserts log in `lead_status_history` with status `'CREATED'` (remarks noting painter rejection).
      - Resets `leads.current_status` to `'CREATED'` and `current_painter_id` to `NULL`.
      - Dispatches an asynchronous POST request to the `/assign-painter` webhook to initiate immediate matching with another candidate.
      - Responds with a confirmation message.

### D. User Landing & Open Leads List Handler
* **File Path:** [user-landing-nodes.json](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/Backend/user-landing-nodes.json)
* **Type:** n8n workflow pipeline.
* **Integrations:** Standard Postgres database nodes querying Supabase database views.
* **Workflows Included:**

  #### 1. Fetch User Open Leads (GET `/user-open-leads`)
  - **Trigger:** Webhook GET request containing `userid` or `id` query parameters.
  - **Flow:** Queries the unified database view `user_open_leads_view` where the user ID matches the target.
  - **Response:** Responds with the JSON array containing the user profile metadata and details for all their currently active (non-closed) leads.

  #### 2. Fetch Lead Progress History (GET `/lead-history`)
  - **Trigger:** Webhook GET request containing `lead_id` query parameter.
  - **Flow:** Performs a dual JSON aggregation query fetching status history entries from `lead_status_history` and assignment attempts from the `lead_assignment_history_view` view.
  - **Response:** Responds with a single JSON object containing `{ status_history: [...], assignment_history: [...] }`.

  #### 3. Log Painter Visit Check-in (POST `/start-visit`)
  - **Trigger:** Webhook POST request containing `lead_id`, `painter_id`, `latitude`, `longitude`, and `is_first_visit`.
  - **Flow:**
    - Checks `is_first_visit` condition.
    - **First Visit:**
      - Inserts record into `site_visits` with `visit_number = 1`, coordinates, and current timestamp.
      - Updates `leads` table setting `registered_latitude` and `registered_longitude` to coordinates, `current_status = 'VISITED'`, and `updated_at = NOW()`.
      - Logs status history entry (`ACCEPTED` -> `VISITED`).
      - Returns success response.
    - **Subsequent Visits:**
      - Queries `site_visits` to retrieve the current maximum `visit_number`.
      - Inserts a new record into `site_visits` setting `visit_number = max_visit + 1`, coordinates, and current timestamp.
      - Returns success response with the incremented visit number.
  - **Response:** Responds with `{ status: "success", visit_number: X, first_visit: true/false }`.

  #### 4. Schedule Follow-up (POST `/schedule-followup`)
  - **Trigger:** Webhook POST request containing `lead_id`, `painter_id`, `visit_number`, `followup_date`, `followup_time`, and `remarks`.
  - **Flow:**
    - Inserts a record into the `followups` table with a new UUID and payload parameters.
    - Updates `leads` table to set `next_followup_date = followup_date`, `current_status = 'FOLLOWUP'`, and `updated_at = NOW()`.
    - Inserts transition log into `lead_status_history` (`VISITED` -> `FOLLOWUP`).
  - **Response:** Responds with `{ status: "success", message: "Follow-up scheduled successfully" }`.

  #### 5. Fetch Products Catalog (GET `/products`)
  - **Trigger:** Webhook GET request.
  - **Flow:** Queries the `products` table for active products sorted by category and name.
  - **Response:** Returns JSON array of `{ product_id, sku_code, product_name, category, unit }`.

  #### 6. Fetch Previous Estimates (GET `/previous-estimates`)
  - **Trigger:** Webhook GET request with `lead_id`.
  - **Flow:** Queries `estimate_details_view` grouped and sorted by `estimate_version`.
  - **Response:** Returns JSON array of items from previous estimates.

  #### 7. Submit Site Estimate (POST `/submit-estimate`)
  - **Trigger:** Webhook POST request containing `lead_id`, `painter_id`, `mode`, `estimate_type`, `estimate_items`, `material_total`, `labour_cost`, `grand_total`.
  - **Flow:**
    - Calculates `new_version = MAX(estimate_version) + 1` for this `lead_id`.
    - Inserts a record in the `estimates` table.
    - Uses a code block to construct a bulk SQL query to insert one row per product in `estimate_items`.
    - Updates `leads` to set `latest_estimate_id` to the newly created estimate, set `current_status = 'FOLLOWUP'`, and `updated_at = NOW()`.
    - Inserts transition log into `lead_status_history` (`VISITED` -> `FOLLOWUP`).
  - **Response:** Responds with `{ status: "success", estimate_id: UUID, version: INTEGER }`.

  #### 8. Confirm Site Won (POST `/mark-site-won`)
  - **Trigger:** Webhook POST request containing `lead_id`, `painter_id`, `estimate_id`, `version`.
  - **Flow:**
    - Updates `leads` table to set `current_status = 'WON'`, `latest_estimate_id = estimate_id`, and `closed_at = NOW()`.
    - Inserts status transition log into `lead_status_history` (from the current state dynamically queried to `WON`).
    - Updates `painter_performance` table to increment `won_sites` (+1) and decrement `open_leads` (-1).
  - **Response:** Responds with `{ status: "success", message: "Site registered as WON successfully" }`.

  #### 9. Fetch Lost Reasons (GET `/lost-reasons`)
  - **Trigger:** Webhook GET request.
  - **Flow:** Queries the `lost_reasons` table for active lost reasons sorted by name.
  - **Response:** Returns JSON array of active reasons `{ lost_reason_id, reason_name }`.

  #### 10. Confirm Site Lost (POST `/mark-site-lost`)
  - **Trigger:** Webhook POST request containing `lead_id`, `painter_id`, `lost_reason_id`.
  - **Flow:**
    - Updates `leads` table to set `current_status = 'LOST'`, `lost_reason_id = lost_reason_id`, and `closed_at = NOW()`.
    - Inserts status transition log into `lead_status_history` (from the current state dynamically queried to `LOST`).
    - Updates `painter_performance` table to increment `lost_sites` (+1) and decrement `open_leads` (-1).
  - **Response:** Responds with `{ status: "success", message: "Site registered as LOST successfully" }`.

---

## 4. Estimation Modes and Types Technical Specification

The Berger LMS estimate module allows painters to submit estimates under two **Estimation Modes** combined with two **Estimate Types**, creating a 2x2 matrix of business logic:

### A. Estimation Matrix Overview

| Mode (`estimate_mode`) | Type (`estimate_type`) | Input Fields per Item | Material Total (`material_total`) | Manpower Cost (`labour_cost`) | Grand Total (`grand_total`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Supply Only** (`SUPPLY`) | **Volume** (`VOLUME`) | Category, Product, Qty | Summed Volume by Unit (e.g. `20.00 L + 5.00 Kg`) | `0.00` (Hidden in UI) | Summed Volume by Unit (e.g., `25.00 L`) |
| **Supply Only** (`SUPPLY`) | **Value** (`VALUE`) | Category, Product, Qty, Rate | Summed Rupees (`Rs 12,500.00`) | `0.00` (Hidden in UI) | Material Total (`Rs 12,500.00`) |
| **Supply & Apply** (`SUPPLY_APPLY`) | **Volume** (`VOLUME`) | Category, Product, Qty | Summed Volume by Unit (e.g. `15.00 L`) | Manpower Charges in INR (`Rs 5,000.00`) | Manpower Cost (INR) + Volume (e.g., `Rs 5,000.00 + 15.00 L`) |
| **Supply & Apply** (`SUPPLY_APPLY`) | **Value** (`VALUE`) | Category, Product, Qty, Rate | Summed Rupees (`Rs 10,000.00`) | Manpower Charges in INR (`Rs 3,500.00`) | Material Cost + Manpower Cost (`Rs 13,500.00`) |

---

### B. Business & Calculation Logic

#### 1. Cascading Category/Product Selection
- Painters choose a **Category** first. This filters the catalog dynamically to populate only matching products under the **Product Name / SKU** selector.
- The product unit (`L` or `Kg`) is fetched dynamically from the database and displayed as a label beside the quantity input.

#### 2. Unit Normalization
- Product units in the database (which may vary as `LTR`, `Litre`, `KG`, `Kgs`) are normalized on the client side:
  - `LTR`, `Litre`, `LITRE`, `LTRS` &rarr; `L`
  - `KG`, `Kgs`, `KILOGRAM`, `kg` &rarr; `Kg`

#### 3. Subtotals Compilation
- **Value Estimates (`VALUE`)**: Items are grouped by category, and subtotals are calculated in Rupees:
  $$\text{Subtotal}_{\text{Category}} = \sum (\text{Quantity} \times \text{Rate})$$
- **Volume Estimates (`VOLUME`)**: Items are grouped by category, and subtotals are grouped separately by unit:
  $$\text{Subtotal}_{\text{Category}} = \text{Sum(Quantities in L)} \text{ L} \text{ and } \text{Sum(Quantities in Kg)} \text{ Kg}$$

#### 4. Grand Totals Display
- **Value Mode**: Material Total ($M$), Manpower ($L$), and Grand Total ($G$) are all monetary values:
  $$G = M + L$$
- **Volume Mode**: Material Total ($M$) is a physical volume string (e.g. `12.50 L + 5.00 Kg`). 
  - For **Supply Only**, Grand Total equals Material Total.
  - For **Supply & Apply**, Grand Total displays as:
    $$\text{Rs } L \text{ (Manpower) } + M \text{ (Material)}$$

---

### C. Database Architecture

The data is persisted across three Supabase tables:

1. **`estimates` (Header Table)**
   - `estimate_mode`: Stored as `VARCHAR` (`SUPPLY` or `SUPPLY_APPLY`).
   - `estimate_type`: Stored as `VARCHAR` (`VOLUME` or `VALUE`).
   - `material_total`: Stored as `NUMERIC`.
     - In **Value** mode, stores the calculated total material cost.
     - In **Volume** mode, stores `0` or is ignored (volume details are logged in `estimate_items`).
   - `labour_cost`: Stored as `NUMERIC` (stores the application charges or `0`).
   - `grand_total`: Stored as `NUMERIC`.
     - In **Value** mode, stores $\text{Material} + \text{Labour}$.
     - In **Volume** mode, stores the `labour_cost` amount since volumes cannot be numerically summed with money.
   - `estimate_json`: A JSONB snapshot of all raw item inputs.

2. **`estimate_items` (Item Table)**
   - `quantity`: Stored as `NUMERIC` (paint amount).
   - `rate`: Stored as `NUMERIC` (unit price in INR, or `0` for volume estimates).
   - `line_total`: Stored as `NUMERIC` (quantity $\times$ rate, or `0` for volume estimates).

3. **`estimate_details_view` (Consolidated View)**
   - Joins `estimates`, `estimate_items`, and `products` to provide unified query access. 
   - Included in migrations `00004` and `00005` to support version grouping in the UI historical accordion.

---

## 5. DSO & DSE Partner Portal (Tableau/Odoo-Style Portal)

### A. Frontend Pages

#### 1. Login Page
* **File Path:** [login.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/login.html)
* **Access URL:** `http://<host>:<port>/UI/login.html`
* **Description:** Clean credential matching login portal with Berger branding. Saves user session details in browser storage on success.

#### 2. Executive Dashboard
* **File Path:** [dashboard.html](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/UI/dashboard.html)
* **Access URL:** `http://<host>:<port>/UI/dashboard.html`
* **Description:** Tableau-style executive metrics overview and drill-down tool. Adaptable depending on role (`DSE`, `DSO`, `ADMIN`).
* **Key Features:**
  - **KPI Cards**: Live aggregations for total pipeline opportunities, closed won counts, conversion rates, and total sales value.
  - **Breadcrumbs**: Hierarchical drill-down tracking showing nested stack navigation (e.g. DSO &rarr; DSEs &rarr; Retailers &rarr; Leads).
  - **Interactive Chart.js Funnels**: Dynamically displays lead volumes per status stage as a horizontal bar funnel and sales value allocation as a doughnut chart.
  - **Sales Goal Target Progress Tracker**: Compares won contract values against a target threshold of ₹5,00,000, displaying progress indicators.
  - **Header Column Sorting**: Clickable table headers that re-sort rows dynamically.
  - **Odoo-Style Tabbed Profiles**: Displays Estimates, Visits, and History logs for individual leads inside a tabbed dashboard profile.

### B. Backend Workflows
* **File Path:** [dse-dso-dashboard-nodes.json](file:///Users/kaustavroychoudhury/Desktop/LMS%20Berger/Backend/dse-dso-dashboard-nodes.json)
* **Workflows Included:**
  
  #### 1. User Authenticator (POST `/login`)
  - Queries `user_credentials` table joining `users` to match username and plaintext password.
  
  #### 2. Dashboard Summary Handler (GET `/dashboard-summary`)
  - Aggregates overall opportunities metrics, child nodes lists, and status-funnel value splits from `lead_detail_drilldown_view` view.
  
  #### 3. Sub-Hierarchy Drill-down (GET `/dashboard-drilldown`)
  - Retrieves active child sub-nodes (Retailer lists, Leads arrays, and tabbed Profile logs) matching parent UUID inputs.





