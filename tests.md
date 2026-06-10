# Berger LMS Manual Verification Test Suite

This document lists the step-by-step manual test cases to verify the core frontend interfaces, parameter logic, and n8n backend integrations.

---

### Test Suite: WhatsApp Message Receiver & Status Filtering

| Test Name | Action to be Done | Result to be Tracked |
| :--- | :--- | :--- |
| **Outbound Callback Suppression** | Trigger an outbound notification message from the system to a user. Observe the n8n execution log in the `whatsapp-message-receiver-nodes` workflow. | The n8n execution should successfully pass through the `IF - Is Message Event` check, evaluating to `false`, and terminate silently without running user-lookup or throwing oauth/JSON parsing errors. |
| **Unregistered User Greeting** | Send a text message ("Hi") to the WhatsApp Business number from a phone number NOT registered in the `users` database. | The system responds with the unregistered notification warning text template. |
| **Retailer List Menu Trigger** | Send a text message ("Hi") to the WhatsApp Business number from a phone number registered as a `RETAILER` in the database. | 1. Received welcome image: `WelcomeToLMS.png`. <br>2. Received List message containing options: **Enter new lead** and **Check old lead status**. |
| **Painter List Menu Trigger** | Send a text message ("Hi") to the WhatsApp Business number from a phone number registered as a `PAINTER` in the database. | 1. Received welcome image: `WelcomeToLMS.png`. <br>2. Received List message containing options: **Select lead to start visit** and **Calendar**. |
| **Customer Track Status Trigger** | Send a text message ("Hi") to the WhatsApp Business number from a phone number registered as a `CUSTOMER` in the database. | Received a message with the `TrackOpenLeads.png` image header and a CTA button labeled "Track Status" pointing to the open leads tracking URL. |

---

### Test Suite: Interactive CTA URL & Image Headers

| Test Name | Action to be Done | Result to be Tracked |
| :--- | :--- | :--- |
| **Retailer Lead Form Dispatch** | Interact with the Retailer welcome menu and select **Enter new lead**. | Received a message with the `RetailerCaptureLead.png` image header and an "Enter Lead" button linking to `lead-capture-form.html?id=<retailer_id>`. |
| **Retailer Open Leads Dispatch** | Interact with the Retailer welcome menu and select **Check old lead status**. | Received a message with the `TrackOpenLeads.png` image header and an "Open Leads" button linking to `open-leads-by-user-type.html?id=<retailer_id>`. |
| **Painter Open Leads Dispatch** | Interact with the Painter welcome menu and select **Select lead to start visit**. | Received a message with the `PainterStartSite.png` image header and an "Open Leads" button linking to `open-leads-by-user-type.html?id=<painter_id>`. |
| **Painter Calendar Dispatch** | Interact with the Painter welcome menu and select **Calendar**. | Received a message with the `PainterCalendar.png` image header and a "View Calendar" button linking to `painter-calendar.html?painter_id=<painter_id>`. |
| **Painter Invitation Dispatch** | Trigger the `POST /assign-painter` auto-assignment workflow endpoint. | The matched painter receives a WhatsApp alert with the `PainterLeadAssigned.png` image header and a "Review Lead" button linking to `painter-response.html?painter_id=<painter_id>&lead_id=<lead_id>`. |

---

### Test Suite: Estimate Details & PDF Generation

| Test Name | Action to be Done | Result to be Tracked |
| :--- | :--- | :--- |
| **Estimate Details Render** | Open the browser to: `https://lms-berger-ui.vercel.app/view-estimate.html?id=<painter_or_retailer_or_customer_id>&lead_id=<lead_id>`. | The page loads properly, displaying correct customer contact details, metadata fields, line-item product breakdowns, and cost totals matching database records. |
| **Missing Parameter Handling** | Navigate to `https://lms-berger-ui.vercel.app/view-estimate.html` without query parameters. | The screen stops loading and renders a clear error dialog saying "Missing lead_id or userid parameters in URL." with a back button. |
| **Download PDF Interaction** | Click the primary purple **Download PDF** button on `view-estimate.html`. | 1. A PDF download triggers in the browser, saving a high-resolution file named `Berger_Paints_Estimate_<lead_id>.pdf`. <br>2. **Critical**: Verify the downloaded PDF document does not contain the "Download PDF" and "Back to Dashboard" buttons. |
