# Berger LMS - Database Activity Tracking Matrix

This document acts as a registry to track which user activities, front-end actions, and back-end flows write to or modify tables and columns in the database.

---

## 1. Activity: Retailer Page Load (Profile Fetch)
* **Trigger Component:** `UI/lead-capture-form.html` (onload event)
* **Backend Endpoint:** GET `/profile?retailer_id=...`
* **Database Action:** Read (SELECT)
* **Tables Affected:**
  - **`users`**: Verifies and reads `name` and `id` where `id` matches path query and `active` is `true`.

---

## 2. Activity: Lead Submission
* **Trigger Component:** `UI/lead-capture-form.html` (form submit event)
* **Backend Endpoint:** POST `/lead-capture`
* **Database Action:** Write (INSERT)
* **Tables Affected:**
  
  ### A. Table: `users`
  A customer user record is created or updated:
  - `user_type` &larr; `'CUSTOMER'`.
  - `name` &larr; Site Owner Name text.
  - `mobile` &larr; Site Owner Mobile number.
  - `active` &larr; `true`.

  ### B. Table: `leads`
  A new row is inserted with the following field mappings:
  - `retailer_id` &larr; retailer UUID from page URL.
  - `site_owner_name` &larr; Site Owner Name text.
  - `site_owner_mobile` &larr; Site Owner Mobile number.
  - `address_line1` &larr; Address line 1 text.
  - `address_line2` &larr; Address line 2 text (or `NULL` if blank).
  - `town` &larr; Town/City text.
  - `state` &larr; State text.
  - `pincode` &larr; Pincode string.
  - `carpet_area` &larr; Mapped numeric value from the dropdown range.
  - `site_type` &larr; Selected painting type option.
  - `budget_range` &larr; Selected budget category option.
  - `expected_start_date` &larr; Date value (or `NULL`).
  - `visit_date` &larr; Date value.
  - `visit_time` &larr; Time value.
  - `current_status` &larr; `'CREATED'`.

  ### B. Table: `lead_status_history`
  A status transition audit trail is created to track creation history:
  - `lead_id` &larr; Generated UUID from the `leads` table insert.
  - `old_status` &larr; `NULL`.
  - `new_status` &larr; `'CREATED'`.
  - `remarks` &larr; `'Initial registration via form'`.
  - `changed_at` &larr; `NOW()` (handled by table default constraint).

---

## 3. Activity: Auto Painter Assignment
* **Trigger Component:** Orchestration step / System background matching process.
* **Backend Endpoint:** POST `/assign-painter`
* **Database Action:** Read & Write (SELECT / INSERT / UPDATE)
* **Tables Affected:**

  ### A. Table: `leads`
  - `current_painter_id` &larr; Matched Painter UUID.
  - `current_status` &larr; `'ASSIGNED'`.
  - `updated_at` &larr; `NOW()`.

  ### B. Table: `lead_assignment_history`
  - `lead_id` &larr; Targets active lead.
  - `painter_id` &larr; Matched painter UUID.
  - `response_status` &larr; `'PENDING'`.
  - `assigned_at` &larr; `NOW()`.

  ### C. Table: `lead_status_history`
  - `lead_id` &larr; Targets active lead.
  - `old_status` &larr; `'CREATED'`.
  - `new_status` &larr; `'ASSIGNED'`.
  - `remarks` &larr; `'Auto-assignment engine matches painter'`.

  ### D. Table: `painter_performance`
  Inserts or updates the painter statistics matrix:
  - `painter_id` &larr; Matched painter UUID.
  - `allocated_sites` &larr; Incremented by `1`.
  - `last_assigned_at` &larr; `NOW()`.
  - `updated_at` &larr; `NOW()`.

---

## 4. Activity: Painter Accept Lead
* **Trigger Component:** `UI/painter-response.html` (Accept button event)
* **Backend Endpoint:** POST `/painter-response` (`action` = `'accept'`)
* **Database Action:** Write (UPDATE / INSERT)
* **Tables Affected:**

  ### A. Table: `lead_assignment_history`
  - Updates `response_status` to `'ACCEPTED'` and `response_at` to `NOW()` for the matching lead and painter ID where `response_status` was `'PENDING'`.

  ### B. Table: `leads`
  - Updates `current_status` to `'ACCEPTED'` and `updated_at` to `NOW()`.

  ### C. Table: `lead_status_history`
  - Inserts a new transition history record:
    - `lead_id` &larr; Target lead UUID.
    - `old_status` &larr; `'ASSIGNED'`.
    - `new_status` &larr; `'ACCEPTED'`.
    - `remarks` &larr; `'Accepted by matched painter'`.

  ### D. Table: `painter_performance`
  - Updates the painter statistics:
    - `accepted_sites` &larr; Incremented by `1`.
    - `allocated_sites` &larr; Incremented by `1` (if row did not exist).
    - `open_leads` &larr; Incremented by `1` (if row did not exist).
    - `updated_at` &larr; `NOW()`.

---

## 5. Activity: Painter Reject Lead
* **Trigger Component:** `UI/painter-response.html` (Decline button event)
* **Backend Endpoint:** POST `/painter-response` (`action` = `'reject'`)
* **Database Action:** Write & Read (UPDATE / INSERT)
* **Tables Affected:**

  ### A. Table: `lead_assignment_history`
  - Updates `response_status` to `'REJECTED'` and `response_at` to `NOW()` for the matching lead and painter ID where `response_status` was `'PENDING'`.

  ### B. Table: `leads`
  - Resets `current_status` to `'CREATED'`, `current_painter_id` to `NULL`, and `updated_at` to `NOW()`.

  ### C. Table: `lead_status_history`
  - Inserts a new transition history record:
    - `lead_id` &larr; Target lead UUID.
    - `old_status` &larr; `'ASSIGNED'`.
    - `new_status` &larr; `'CREATED'` (reverted to allow re-assignment matching).
    - `remarks` &larr; `'Decline submitted by painter'`.

---

## 6. Activity: Load Dashboard Open Leads
* **Trigger Component:** `UI/open-leads-by-user-type.html` (onload event)
* **Backend Endpoint:** GET `/user-open-leads?userid=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`user_open_leads_view`**: Queries all matching profiles and leads filtered by `user_id` where the lead status is not closed (not `WON`/`LOST`).

---

## 7. Activity: Load Lead Details Progress Timeline
* **Trigger Component:** `UI/open-leads-by-user-type.html` (card click event)
* **Backend Endpoint:** GET `/lead-history?lead_id=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`lead_status_history`**: Queries all status changes sorted chronologically.
  - **`lead_assignment_history_view`**: Queries all assignment records and matches them with painter profiles to show details of assignment matching and rejections.

---

## 8. Activity: Painter Check-in / Start Visit
* **Trigger Component:** `UI/open-leads-by-user-type.html` (Start Site Visit button event)
* **Backend Endpoint:** POST `/start-visit`
* **Database Action:** Write (INSERT / UPDATE)
* **Tables Affected:**

  ### A. Table: `site_visits`
  Inserts a new record tracking the painter visit check-in details:
  - `visit_id` &larr; Mapped UUID.
  - `lead_id` &larr; Target lead UUID.
  - `painter_id` &larr; Active Painter UUID.
  - `visit_number` &larr; `1` (for first visit) or `max_visit + 1` (subsequent visits).
  - `latitude`, `longitude` &larr; GPS coordinates from browser.
  - `visit_time` &larr; `NOW()`.

  ### B. Table: `leads` (First Visit Only)
  - Updates reference coordinates: `registered_latitude` &larr; GPS latitude, `registered_longitude` &larr; GPS longitude.
  - Updates current status: `current_status` &larr; `'VISITED'`.
  - Updates change timestamp: `updated_at` &larr; `NOW()`.

  ### C. Table: `lead_status_history` (First Visit Only)
  Inserts a status transition trail record:
  - `lead_id` &larr; Target lead UUID.
  - `old_status` &larr; `'ACCEPTED'`.
  - `new_status` &larr; `'VISITED'`.
  - `remarks` &larr; `'First site visit started (coordinates registered)'`.
  - `changed_at` &larr; `NOW()`.

---

## 9. Activity: Painter Schedule Follow-up
* **Trigger Component:** `UI/schedule-followup.html` (Schedule Follow-up submit button event)
* **Backend Endpoint:** POST `/schedule-followup`
* **Database Action:** Write (INSERT / UPDATE)
* **Tables Affected:**

  ### A. Table: `followups`
  Inserts a new follow-up appointment record:
  - `followup_id` &larr; Mapped UUID.
  - `lead_id` &larr; Target lead UUID.
  - `visit_number` &larr; Mapped visit count in which follow-up is scheduled.
  - `followup_date`, `followup_time` &larr; Scheduled date and time values.
  - `remarks` &larr; Visit summary details.
  - `created_at` &larr; `NOW()`.

  ### B. Table: `leads`
  - Updates next follow-up date: `next_followup_date` &larr; `followup_date`.
  - Updates current status: `current_status` &larr; `'FOLLOWUP'`.
  - Updates change timestamp: `updated_at` &larr; `NOW()`.

  ### C. Table: `lead_status_history`
  Inserts a status transition record:
  - `lead_id` &larr; Target lead UUID.
  - `old_status` &larr; `'VISITED'`.
  - `new_status` &larr; `'FOLLOWUP'`.
  - `remarks` &larr; Scheduled follow-up remarks.
  - `changed_at` &larr; `NOW()`.

---

## 10. Activity: Submit Project Estimate
* **Trigger Component:** `UI/submit-estimate.html` (Submit Estimate button event)
* **Backend Endpoint:** POST `/submit-estimate`
* **Database Action:** Write (INSERT / UPDATE)
* **Tables Affected:**

  ### A. Table: `estimates`
  Inserts a consolidated project estimate header row:
  - `estimate_id` &larr; Generated UUID.
  - `lead_id` &larr; Target lead UUID.
  - `painter_id` &larr; Active Painter UUID.
  - `estimate_version` &larr; Calculated auto-increment value.
  - `estimate_mode` &larr; `'SUPPLY'` or `'SUPPLY_APPLY'`.
  - `estimate_type` &larr; `'VOLUME'` or `'VALUE'`.
  - `estimate_json` &larr; Payload items JSON array.
  - `material_total`, `labour_cost`, `grand_total` &larr; Supply, manpower, and sum values.
  - `submitted_at` &larr; `NOW()`.

  ### B. Table: `estimate_items`
  Inserts individual paint catalog product item breakdown rows:
  - `estimate_item_id` &larr; Generated UUID.
  - `estimate_id` &larr; Foreign key matching generated header ID.
  - `product_id` &larr; Product catalogue SKU UUID.
  - `quantity` &larr; Litre/Kilogram amount.
  - `rate` &larr; Price per unit (0 if Volume).
  - `line_total` &larr; Multiplying quantity by rate (0 if Volume).

  ### C. Table: `leads`
  - Updates latest estimate foreign key: `latest_estimate_id` &larr; Mapped header ID.
  - Updates current status: `current_status` &larr; `'FOLLOWUP'`.
  - Updates change timestamp: `updated_at` &larr; `NOW()`.

  ### D. Table: `lead_status_history`
  Logs estimate transition history:
  - `lead_id` &larr; Target lead UUID.
  - `old_status` &larr; `'VISITED'`.
  - `new_status` &larr; `'FOLLOWUP'`.
  - `remarks` &larr; Submission version notes.
  - `changed_at` &larr; `NOW()`.

---

## 11. Activity: Partner Portal Authentication
* **Trigger Component:** `UI/login.html` (Form submit check)
* **Backend Endpoint:** POST `/login`
* **Database Action:** Read (SELECT)
* **Tables Affected:**
  - **`user_credentials`**: Selects where username matches (case-insensitive) and checks if plaintext password is correct.
  - **`users`**: Selects related user profile details (`id`, `name`, `user_type`).

---

## 12. Activity: Load Partner Portal Summary Aggregations
* **Trigger Component:** `UI/dashboard.html` (onload check)
* **Backend Endpoint:** GET `/dashboard-summary?user_id=...&user_type=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`lead_detail_drilldown_view`**: Queries all nested children nodes, computing totals, conversion rates, won counts, estimate sums, and stage status counts (`funnel`) matching active user type (`DSO` or `DSE`).

---

## 13. Activity: Load Partner Portal Sub-Hierarchy Drill-down
* **Trigger Component:** `UI/dashboard.html` (Table row click event / Breadcrumb toggle)
* **Backend Endpoint:** GET `/dashboard-drilldown?parent_type=...&parent_id=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`lead_detail_drilldown_view`**: Returns retailers under a DSE, or leads under a retailer.
  - **`site_visits`**: Returns all visit check-ins for a specific lead.
  - **`estimates`**: Returns estimate history logs for a specific lead.
  - **`lead_status_history`**: Returns status change audit trials for a specific lead.

---

## 14. Activity: Fetch Product Knowledge Catalog
* **Trigger Component:** `UI/berger-paints-product-knowledgebase.html` (onload check)
* **Backend Endpoint:** GET `/products-knowledgebase?userid=...&leadid=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`lead_detail_drilldown_view`**: Checks that the requested `userid` matches one of the assigned roles (`dso_id`, `dse_id`, `retailer_id`, `painter_id`) associated with the `leadid` row.
  - **`products`**: If authorized, retrieves the list of active products including `product_id`, `sku_code`, `product_name`, `category`, `unit`, `description`, `specifications`, `segment`, and `tags`.

---

## 15. Activity: Fetch Estimate Viewer Details
* **Trigger Component:** `UI/view-estimate.html` (onload event)
* **Backend Endpoint:** GET `/latest-estimate?lead_id=...&user_id=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`estimate_details_view`**: Returns the list of product items, quantities, rates, and line totals for the matching estimate ID.

---

## 16. Activity: Read/Write Chat History Conversation Context
* **Trigger Component:** WhatsApp Message Agent Query loop (`Backend/whatsapp-message-receiver-nodes.json`)
* **Backend Endpoint:** Orchestration inside the JS Agent Loop Code Node
* **Database Action:** Read & Write (SELECT / INSERT)
* **Tables Affected:**
  - **`chat_history`**: 
    - **Read**: Selects the last 10 messages ordered by `created_at` where `user_id` matches the sender's UUID.
    - **Write**: Inserts the new user query message and the final assistant response message at the end of the loop.

---

## 17. Activity: Load Painter Consultation Calendar
* **Trigger Component:** `UI/painter-calendar.html` (onload event)
* **Backend Endpoint:** GET `/painter-visits?painter_id=...`
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`leads`**: Selects all leads assigned to `current_painter_id`.
  - **`site_visits`**: Run counts of visit events per lead.

---

## 18. Activity: Painter Assignment Timeout Check
* **Trigger Component:** Background Cron service (`Backend/painter-assignment-timeout-nodes.json`)
* **Backend Endpoint:** Automated scheduled query runs every 2 hours
* **Database Action:** Read & Write (SELECT / UPDATE)
* **Tables Affected:**
  - **`lead_assignment_history`**: Reads pending records older than 6 hours and updates `response_status` to `'EXPIRED'`.
  - **`leads`**: Joins to check active status.

---

## 19. Activity: Daily Site Visit Reminders Cron Execution
* **Trigger Component:** Background Cron service (`Backend/daily-visit-reminders.json`)
* **Backend Endpoint:** Automated scheduled query runs daily at 8:00 AM
* **Database Action:** Read (SELECT)
* **Tables/Views Affected:**
  - **`leads`**: Reads visits scheduled for the current date.
  - **`users`**: Joins on `current_painter_id` to get contact details for notifications.










