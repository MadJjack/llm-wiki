---
type: api
tags: []
created: <!-- YYYY-MM-DD -->
updated: <!-- YYYY-MM-DD -->
status: draft
---

# API

> Inventory of all HTTP endpoints, events, or public interfaces.
> Agent updates this whenever an endpoint is added, changed, or removed.

## Authentication

<!-- How requests are authenticated — e.g. Bearer JWT, API key, session cookie -->

---

## Endpoints

> Agent creates a subsection per resource/domain area.

<!-- Template per endpoint:

### POST /resource
**Auth required:** Yes / No
**Description:** What it does.

**Request:**
\`\`\`json
{
  "field": "type — description"
}
\`\`\`

**Response 200:**
\`\`\`json
{
  "field": "type — description"
}
\`\`\`

**Errors:**
| Status | Reason |
|---|---|
| 400 | Validation failure |
| 401 | Missing or invalid auth |
| 404 | Resource not found |

-->

---

## Versioning

<!-- e.g. URL versioning /v1/, header versioning, or none -->

## Rate Limiting

<!-- Limits, headers returned, behavior when exceeded -->

## Related
- [[wiki/architecture/overview]]
- [[wiki/integrations/_index]]
