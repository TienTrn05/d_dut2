# Notification Service API - Queue

## Overview
The **Notification Service API** enables sending notifications to a specific user in the system.  
Each notification includes a **title** and **body**, and the API is secured using an **API Key** per environment.

---

## Environments

| Environment | Base URL |
|------------|----------|
| Development | https://notifications.dev.dut.navia.io.vn |
| Production | https://notifications.dut.udn.vn |

---

## Endpoint

### Send Notification

POST /api/notifications/send-notification

```json
{
  "userId": "",
  "title": "",
  "body": ""
}
```

### Get remain turn

GET /api/notifications/queue/remain-turn?userId={userId}

---

## Authentication
This API requires **two authentication mechanisms**:

1. **Bearer Token**
2. **API Key**

### Required Headers

| Header | Required | Description |
|------|----------|-------------|
| x-api-key | Yes | API key corresponding to the environment |

### API Keys

- **Development**


x-api-key: 4FjlkKjH1D6k5aCRixp4hzfFxOI1ZBxXIw5ScjIQ


- **Production**


x-api-key: 4FxMMfND3VBZitSm0AKS2wc4YYqxra8D8DpPmkzH66Av37wQf


> ⚠️ **Warning:** Never use the Production API key in the Development environment or expose API keys publicly.