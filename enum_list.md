# Berger LMS - Enum Values and Constraints Reference

This file documents the valid enum options, constrained values, and statuses allowed across various columns in the Berger LMS Database.

---

## 1. User Types (`users.user_type`)
Valid roles for users registered in the system:
- `RETAILER`
- `PAINTER`
- `DSE`
- `DSO`
- `ADMIN`
- `CUSTOMER`

---

## 2. Lead Status (`leads.current_status` & `lead_status_history.new_status`)
Represents the stage of a painting or waterproofing site:
- `CREATED` (Default status upon form capture)
- `ASSIGNED` (Assigned to a painter)
- `ACCEPTED` (Accepted by the assigned painter)
- `VISITED` (Site visit completed)
- `FOLLOWUP` (Requires follow-up visits/calls)
- `WON` (Job won / closed successfully)
- `LOST` (Job lost / closed unsuccessfully)

> [!NOTE]
> In `lead_status_history.old_status`, the value can be:
> - `NULL` (representing initial creation transitions to `CREATED`).
> - `CREATED` (representing transition when painter is auto-assigned to `ASSIGNED`).


---

## 3. Lead Assignment Response (`lead_assignment_history.response_status`)
Tracks the status of a lead assignment offer sent to a painter:
- `PENDING` (Default upon offer dispatch)
- `ACCEPTED` (Painter agreed to visit/work)
- `REJECTED` (Painter turned down the lead)
- `EXPIRED` (Offer timeout exceeded without response)

---

## 4. Notifications Status (`notifications.status`)
Tracks communication message delivery states:
- `PENDING`
- `SENT`
- `DELIVERED`
- `READ`
- `FAILED`

---

## 5. Carpet Area Ranges (`leads.carpet_area`)
The frontend captures carpet area ranges which are mapped to representative `NUMERIC` values in the database during n8n orchestration:
- `< 500 sq ft` &rarr; `250`
- `500 - 1000 sq ft` &rarr; `750`
- `1000 - 1500 sq ft` &rarr; `1250`
- `1500 - 2000 sq ft` &rarr; `1750`
- `> 2000 sq ft` &rarr; `2500`
- Unspecified / Invalid &rarr; `NULL`

---

## 6. Estimate Mode (`estimates.estimate_mode`)
- `SUPPLY` (Supply of paint only)
- `SUPPLY_APPLY` (Supply of paint as well as application)

## 7. Estimate Type (`estimates.estimate_type`)
- `VOLUME` (Volume estimation in Litre/Kg)
- `VALUE` (Value estimation incorporating unit pricing)


