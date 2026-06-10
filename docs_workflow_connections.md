# Berger LMS - Workflow Connections Documentation

This document describes the orchestration flow and integration touchpoints between the frontend UI, n8n webhook nodes, and the database operations in the Berger Lead Management System (LMS).

---

## 1. Overview Architecture

Below is a visual representation of how the components interact:

```mermaid
sequenceDiagram
    participant UI as Retailer Capture Form (UI)
    participant HW as HTTP Webhook (lead-capture)
    participant DB as Postgres Database (Supabase)
    participant AM as Auto-Assignment Webhook (assign-painter)

    UI->>HW: 1. POST Submit Lead Request
    activate HW
    HW->>DB: 2. Insert Lead details (Table: leads)
    DB-->>HW: Returns lead_id
    HW->>DB: 3. Log initial status (Table: lead_status_history)
    
    Note over HW, AM: Synchronous HTTP Call
    HW->>AM: 4. POST assign-painter (lead_id, retailer_id)
    activate AM
    AM->>DB: 5. Query candidate using painter_matching_scores View
    DB-->>AM: Returns top painter candidate details
    
    alt Painter Candidate Found
        AM->>DB: 6a. UPDATE leads with current_painter_id & status = 'ASSIGNED'
        AM->>DB: 6b. INSERT lead_assignment_history (status = 'PENDING')
        AM->>DB: 6c. INSERT lead_status_history (status = 'ASSIGNED')
        AM->>DB: 6d. UPSERT painter_performance (increment allocated/open count)
        AM-->>HW: 7a. Return matched details (name, mobile, score)
    else No Painter Found
        AM-->>HW: 7b. Return 404 Unassigned
    end
    deactivate AM
    
    HW-->>UI: 8. Return combined Response (Lead + Assigned Painter info)
    deactivate HW
```

---

## 2. Integration Touchpoints

### A. Retailer Lead Form &rarr; Lead Capture Webhook
- **Trigger:** Frontend form submit event.
- **Data Payload:** Customer details, site specifications (carpet area range), scheduled visit timestamps.
- **Connection Protocol:** Asynchronous HTTP POST request via Fetch API.

### B. Lead Capture Webhook &rarr; Painter Assignment Webhook
- **Trigger:** Insertion of lead details and initialization of `CREATED` status.
- **Data Payload:** `lead_id` (newly generated UUID) and `retailer_id`.
- **Connection Protocol:** Synchronous HTTP POST request executed inside n8n via the upgraded HTTP Request Node (`typeVersion: 4.1`).

### C. Painter Assignment Webhook &rarr; Database View
- **Trigger:** Execution of the assignment matching search query.
- **Data Query:** Queries `painter_matching_scores` joining `retailer_painter_mapping` and `painter_performance` on-the-fly.
- **Connection Protocol:** SQL Select query returning a single record.

### D. Final Webhook Response &rarr; Frontend UI
- **Trigger:** Resolution of the painter assignment request.
- **Data Payload:** Combined response containing success message and matched painter details (ID, Name, Mobile, matching Score).
- **Connection Protocol:** Webhook response JSON output.

---

## 3. Painter Response & Reassignment Sequence

This flow manages the painter interaction when they click Accept or Decline from their mobile link:

```mermaid
sequenceDiagram
    participant UI as Painter Response UI
    participant PW as HTTP Webhook (painter-response)
    participant DB as Postgres Database (Supabase)
    participant AM as Auto-Assignment Webhook (assign-painter)

    UI->>PW: 1. POST Action (accept/reject)
    activate PW
    PW->>DB: 2. Query assignment check
    DB-->>PW: Returns active matching assignment status

    alt Action is ACCEPT
        PW->>DB: 3a. UPDATE lead_assignment_history to ACCEPTED
        PW->>DB: 3b. UPDATE leads to ACCEPTED
        PW->>DB: 3c. INSERT lead_status_history as ACCEPTED
        PW->>DB: 3d. UPSERT painter_performance (increment stats)
        PW-->>UI: 4a. Return full customer details (owner, contact, carpet area)
    else Action is REJECT
        PW->>DB: 5a. UPDATE lead_assignment_history to REJECTED
        PW->>DB: 5b. INSERT lead_status_history as CREATED (with remarks)
        PW->>DB: 5c. UPDATE leads to CREATED (current_painter_id = NULL)
        Note over PW, AM: Asynchronous call to find next painter
        PW->>AM: 6. POST assign-painter (lead_id, retailer_id)
        PW-->>UI: 7. Return confirmation status
    end
    deactivate PW
```

- **GET `/painter-lead-details`**: Fetch basic site details on landing.
- **POST `/painter-response`**: Updates painter response state and logs status changes.
- **Outbound HTTP request to `/assign-painter`**: Triggers immediate reassignment on painter rejection, keeping the pipeline automated.

---

## 4. Open Leads Dashboard Loading Sequence

This flow manages loading user details and open leads depending on the user type logged in:

```mermaid
sequenceDiagram
    participant UI as Open Leads UI (open-leads-by-user-type.html)
    participant HW as HTTP Webhook (user-open-leads)
    participant DB as Database View (user_open_leads_view)

    UI->>HW: 1. GET user-open-leads (id)
    activate HW
    HW->>DB: 2. Query view where user_id = id
    DB-->>HW: 3. Return user profile + array of open leads
    HW-->>UI: 4. Respond with JSON array
    deactivate HW
```

- **GET `/user-open-leads?userid=...`**: Unified endpoint checking the view and serving Retailers, Painters, and Customers.

---

## 5. Lead Progress Timeline Loading Sequence

This flow manages loading detailed status histories and assignment logs upon clicking a lead card:

```mermaid
sequenceDiagram
    participant UI as Open Leads UI (open-leads-by-user-type.html)
    participant HW as HTTP Webhook (lead-history)
    participant DB as Postgres Tables/Views

    UI->>HW: 1. GET lead-history (lead_id)
    activate HW
    HW->>DB: 2. Query lead_status_history & lead_assignment_history_view
    DB-->>HW: 3. Return status logs + assignment attempts
    HW-->>UI: 4. Respond with aggregated JSON object
    deactivate HW
```

### Integration Touchpoints
- **GET `/lead-history?lead_id=...`**: Fetch combined timeline entries (status logs + partner reassignments).

---

## 6. Painter Check-in & Geofencing Sequence

This flow manages the painter geolocation acquisition, geofencing checks, and check-in updates:

```mermaid
sequenceDiagram
    participant UI as Open Leads UI (open-leads-by-user-type.html)
    participant HW as HTTP Webhook (start-visit)
    participant DB as Postgres Database (Supabase)
    participant TL as Tools Page (project-tools.html)

    UI->>UI: 1. Request GPS via navigator.geolocation
    Note over UI: Acquires latitude/longitude

    alt First Visit (registered_latitude is empty/0)
        UI->>HW: 2a. POST /start-visit (is_first_visit = true)
        activate HW
        HW->>DB: 3a. INSERT site_visits (visit_number = 1)
        HW->>DB: 3b. UPDATE leads (registered_latitude/longitude, status = 'VISITED', updated_at = NOW())
        HW->>DB: 3c. INSERT lead_status_history (ACCEPTED -> VISITED)
        HW-->>UI: 4a. Respond success
        deactivate HW
        UI->>TL: 5a. Redirect to Tools Page
    else Subsequent Visits (registered_latitude exists)
        UI->>UI: 2b. Compute Haversine distance
        alt Distance <= 50m
            UI->>HW: 3b. POST /start-visit (is_first_visit = false)
            activate HW
            HW->>DB: 4b. SELECT max(visit_number)
            HW->>DB: 4c. INSERT site_visits (visit_number = max + 1)
            HW-->>UI: 5b. Respond success
            deactivate HW
            UI->>TL: 6b. Redirect to Tools Page
        else Distance > 50m
            UI->>UI: 3c. Show location mismatch reset error
        end
    end
```

- **POST `/start-visit`**: Records check-in logs and updates lead status to `VISITED` for first visits.
- **Redirection**: On successful check-in, redirects the user to `project-tools.html` with query parameters.

---

## 7. Schedule Follow-up Sequence

This flow manages passing lead detail parameters to the follow-up form and saving follow-up records:

```mermaid
sequenceDiagram
    participant TL as Tools Page (project-tools.html)
    participant UI as Follow-up UI (schedule-followup.html)
    participant HW as HTTP Webhook (schedule-followup)
    participant DB as Postgres Database (Supabase)

    TL->>UI: 1. Redirect with query parameters (lead_id, id, visit_number, owner, mobile, address)
    Note over UI: Populates metadata fields dynamically

    UI->>HW: 2. POST /schedule-followup (lead_id, painter_id, visit_number, date, time, remarks)
    activate HW
    HW->>DB: 3. INSERT INTO followups
    HW->>DB: 4. UPDATE leads (next_followup_date, status = 'FOLLOWUP', updated_at = NOW())
    HW->>DB: 5. INSERT INTO lead_status_history (VISITED -> FOLLOWUP)
    HW-->>UI: 6. Respond success
    deactivate HW

    UI->>TL: 7. Redirect back to Tools Page
```

- **GET Parameters**: No database query is made on page load. All metadata values are read directly from URL query parameters.
- **POST `/schedule-followup`**: Updates the lead schedule and inserts followup rows.

---

## 8. Submit Estimate Sequence

This flow manages product catalog loading, version resolution, estimate insertion, and history aggregation:

```mermaid
sequenceDiagram
    participant TL as Tools Page (project-tools.html)
    participant UI as Estimate UI (submit-estimate.html)
    participant HW as HTTP Webhook (submit-estimate)
    participant DB as Postgres Database (Supabase)

    TL->>UI: 1. Redirect with metadata parameters
    UI->>HW: 2. GET /products
    HW->>DB: 3. Fetch active products
    DB-->>UI: 4. Populate drop-down select options
    
    opt Expand Previous Estimates
        UI->>HW: 5. GET /previous-estimates
        HW->>DB: 6. SELECT from estimate_details_view
        DB-->>UI: 7. Render historical estimate versions
    end

    UI->>HW: 8. POST /submit-estimate (payload details)
    activate HW
    HW->>DB: 9. Calculate new estimate version (MAX + 1)
    HW->>DB: 10. INSERT INTO estimates (header record)
    Note over HW: Loop array items
    HW->>DB: 11. Bulk INSERT INTO estimate_items
    HW->>DB: 12. UPDATE leads (latest_estimate_id, status = 'FOLLOWUP')
    HW->>DB: 13. INSERT lead_status_history
    HW-->>UI: 14. Respond success with version number
    deactivate HW

    UI->>TL: 15. Redirect back to Tools Page
```

- **GET `/products`**: Populates the product search items.
- **GET `/previous-estimates`**: Connects via `estimate_details_view` to read historic version cards.
- **POST `/submit-estimate`**: Batch logs calculations and updates lead status.

---

## 9. Partner Portal Login Sequence

```mermaid
sequenceDiagram
    participant UI as Login Page (login.html)
    participant HW as HTTP Webhook (login)
    participant DB as Postgres Database (Supabase)

    UI->>HW: 1. POST login (username, password)
    activate HW
    HW->>DB: 2. Query check credentials against user_credentials and users
    DB-->>HW: Returns match id, name, user_type
    alt Match Found
        HW-->>UI: 3a. Respond success with user details
        UI->>UI: Save user to localStorage
        UI->>UI: Redirect to dashboard.html
    else Match Not Found
        HW-->>UI: 3b. Respond 401 Unauthorized
    end
    deactivate HW
```

---

## 10. Partner Portal Summary & Drilldown Sequence

```mermaid
sequenceDiagram
    participant UI as Executive Dashboard (dashboard.html)
    participant HW as HTTP Webhook (dashboard-summary / dashboard-drilldown)
    participant DB as Postgres Database (Supabase)

    UI->>HW: 1. GET /dashboard-summary (user_id, user_type)
    activate HW
    HW->>DB: 2. Query stats, list, funnel from lead_detail_drilldown_view
    DB-->>HW: Returns dashboard data object
    HW-->>UI: 3. Respond summary payload
    deactivate HW
    UI->>UI: Populate KPIs
    UI->>UI: Render Funnel stage and Sales value charts
    UI->>UI: Render initial Child Table

    opt Drill Down on Row Click
        UI->>HW: 4. GET /dashboard-drilldown (parent_type, parent_id)
        activate HW
        HW->>DB: 5. Query sub-level (Retailers / Leads / Profile)
        DB-->>HW: Returns list / logs details
        HW-->>UI: 6. Respond drilldown data
        deactivate HW
        UI->>UI: Append Breadcrumb path
        UI->>UI: Re-render Table sheet or tabbed Profile panel
    end
```

---

## 11. Secure Product Knowledge Base Sequence

```mermaid
sequenceDiagram
    participant UI as Knowledge Base (berger-paints-product-knowledgebase.html)
    participant HW as HTTP Webhook (products-knowledgebase)
    participant DB as Postgres Database (Supabase)

    UI->>HW: 1. GET /products-knowledgebase (userid, leadid)
    activate HW
    HW->>DB: 2. Verify UUID format and query lead_detail_drilldown_view
    DB-->>HW: Returns authorized flag & products json array
    alt Authorized is True
        HW-->>UI: 3a. Respond HTTP 200 with catalog array
        UI->>UI: Populate stats counters
        UI->>UI: Render products cards grid
    else Authorized is False / Format Invalid
        HW-->>UI: 3b. Respond HTTP 403 Forbidden / Error details
        UI->>UI: Render Access Denied overlay lock
    end
    deactivate HW
```

---

## 12. Estimate Details & PDF Generation Sequence

```mermaid
sequenceDiagram
    participant UI as Estimate Viewer UI (view-estimate.html)
    participant HW as HTTP Webhook (latest-estimate)
    participant DB as Database (estimate_details_view)
    participant PDF as html2pdf.js engine

    UI->>HW: 1. GET /latest-estimate (lead_id, user_id)
    activate HW
    HW->>DB: 2. SELECT matching estimate records
    DB-->>HW: Returns items array
    HW-->>UI: 3. Respond with estimate details JSON
    deactivate HW
    UI->>UI: Render products catalog details & aggregates

    opt Click Download PDF
        UI->>UI: Trigger Download PDF Listener
        Note over UI, PDF: Exclude buttons with data-html2canvas-ignore
        UI->>PDF: Pass .app-container element
        PDF->>PDF: Capture DOM and compile to PDF
        PDF-->>UI: Trigger browser download (.pdf file)
    end
```

---

## 13. WhatsApp Parallel Tool Agent Loop & Memory Sequence

```mermaid
sequenceDiagram
    participant WT as WhatsApp Trigger
    participant LU as Look Up User Node
    participant AL as JS Agent Loop Node (Code Node)
    participant DB as Supabase REST API
    participant OA as OpenAI gpt-4o-mini
    participant WA as Send Agent WhatsApp Node

    WT->>LU: 1. Message Trigger received ("HI" or text query)
    LU->>AL: 2. Pass sender name, ID, and message body
    activate AL

    AL->>DB: 3. Fetch past 10 messages (chat_history table)
    DB-->>AL: Returns history array
    AL->>OA: 4. POST completion (messages + tools schema)
    activate OA
    
    alt OpenAI Requests Database Query Tool Execution
        OA-->>AL: 5. Returns array of tool_calls (query_lead_details, query_site_visits, query_estimates)
        deactivate OA
        
        Note over AL, DB: Parallel fetch execution
        AL->>DB: 6. Resolve all tool queries via Promise.all
        DB-->>AL: Returns database tables/views results
        
        AL->>OA: 7. POST completion with tool query response arrays
        activate OA
        OA-->>AL: 8. Returns final text answer response
        deactivate OA
    else No Tools Required / Direct Response
        activate OA
        OA-->>AL: 5b. Returns direct completion text
        deactivate OA
    end

    AL->>DB: 9. POST save messages (user query + final assistant answer) to chat_history
    AL->>WA: 10. Pass final text string output
    deactivate AL
    WA->>WT: 11. Dispatches message payload back to user via WhatsApp
```

---

## 14. Painter Consultation Calendar Load Flow

```mermaid
sequenceDiagram
    participant UI as Calendar Page (painter-calendar.html)
    participant HW as HTTP Webhook (painter-visits)
    participant DB as Postgres Database (Supabase)

    UI->>HW: 1. GET /painter-visits?painter_id=painter_id
    activate HW
    HW->>DB: 2. SELECT leads and count(site_visits)
    DB-->>HW: Returns list of assigned sites & visit counts
    HW-->>UI: 3. Respond with JSON array
    deactivate HW
    UI->>UI: Filter and render Scheduled vs Completed tabs
```

---

## 15. Painter Assignment Timeout Reassignment Sequence

```mermaid
sequenceDiagram
    participant CT as Cron Trigger (Every 2h)
    participant DB as Postgres Database (Supabase)
    participant AM as Auto-Assignment Webhook (assign-painter)

    CT->>DB: 1. Query PENDING assignments > 6 hours old
    DB-->>CT: Returns matching assignment_id & lead_id list
    loop For each expired assignment
        CT->>DB: 2. UPDATE lead_assignment_history to EXPIRED
        CT->>AM: 3. POST assign-painter (lead_id, retailer_id)
        activate AM
        Note over AM: Search & match next candidate
        AM-->>CT: Returns new assignment status
        deactivate AM
    end
```

---

## 16. Daily Site Visit Reminders Notification Sequence

```mermaid
sequenceDiagram
    participant CT as Cron Trigger (Daily 8AM)
    participant DB as Postgres Database (Supabase)
    participant WA as Meta WhatsApp API

    CT->>DB: 1. Query today's consults (leads + painter users)
    DB-->>CT: Returns scheduled visits list with contact details
    loop For each scheduled visit
        CT->>WA: 2. Send interactive cta_url calendar link to Painter
        CT->>WA: 3. Send text reminder containing painter details to Customer
    end
```









