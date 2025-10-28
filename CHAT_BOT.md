## Tích hợp bot vào ứng dụng giao diện (Conversation + Chat)

### Các biến sử dụng

-   <JWT>: 
-   <CHATBOT_ID>: cmgkj1m26000c14lcvzlds075
-   <API_KEY>: 
-   <HOST>: http://171.244.46.201:8080

---

### 1) Tạo cuộc hội thoại (create conv)

-   Method: `POST`
-   URL: `/api/conversations`
-   Header: `Authorization: Bearer <JWT>`
-   Body (JSON): `{ "chatbot_id": "<CHATBOT_ID>" }`

Ví dụ curl:

```bash
curl -X POST \
  "<HOST>/api/conversations" \
  -H "Authorization: Bearer <JWT>" \
  -H "Content-Type: application/json" \
  -d '{
    "chatbot_id": "<CHATBOT_ID>"
  }'
```

API tạo hội thoại trả về `conversation_id` để dùng cho bước chat.

---

### 2) Gửi tin nhắn chat tới bot

-   Method: `POST`
-   URL: `/ai/chat`
-   Header: `x-api-key: <API_KEY>`
-   Body (JSON):
    -   `message` (string) – câu hỏi/tin nhắn của người dùng
    -   `chatbot_id` (string) – id bot
    -   `conversation_id` (string) – id cuộc hội thoại hiện tại (lấy từ bước 1)
    -   `stream` (boolean, optional, mặc định `false`)
    -   `provider` (string, optional: ví dụ `openai`, `groq`)
    -   `api_key` (string, optional – bắt buộc nếu có `provider`)

Ví dụ curl:

```bash
curl -X POST \
  "<HOST>/ai/chat" \
  -H "Content-Type: application/json" \
  -H "x-api-key: <API_KEY>" \
  -d '{
    "message": "Xin chào, hỗ trợ mình nhé?",
    "chatbot_id": "<CHATBOT_ID>",
    "conversation_id": "<CONVERSATION_ID>",
    "stream": false
  }'
```

Nếu muốn dùng provider/khóa riêng:

```json
{
    "message": "...",
    "chatbot_id": "...",
    "conversation_id": "...",
    "provider": "openai",
    "api_key": "<YOUR_PROVIDER_API_KEY>"
}
```

---

### 3) Danh sách cuộc hội thoại (list conv)

-   Method: `GET`
-   URL: `/api/conversations`
-   Header: `Authorization: Bearer <JWT>`

Ví dụ curl:

```bash
curl -X GET \
  "<HOST>/api/conversations" \
  -H "Authorization: Bearer <JWT>"
```

---

### 4) Lấy chi tiết cuộc hội thoại (get detail conv)

-   Method: `GET`
-   URL: `/api/conversations/{id}`
-   Header: `Authorization: Bearer <JWT>`

Ví dụ curl:

```bash
curl -X GET \
  "<HOST>/api/conversations/<CONVERSATION_ID>" \
  -H "Authorization: Bearer <JWT>"
```

---

### 5) Xoá cuộc hội thoại (delete conv)

-   Method: `DELETE`
-   URL: `/api/conversations/{id}`
-   Header: `Authorization: Bearer <JWT>`

Ví dụ curl:

```bash
curl -X DELETE \
  "<HOST>/api/conversations/<CONVERSATION_ID>" \
  -H "Authorization: Bearer <JWT>"
```
