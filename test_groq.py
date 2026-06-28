import urllib.request
import json
import urllib.error

url = "https://api.groq.com/openai/v1/chat/completions"
headers = {
    "Authorization": "Bearer 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",
    "Content-Type": "application/json"
}
data = json.dumps({
    "model": "llama3-8b-8192",
    "messages": [{"role": "user", "content": "Test"}]
}).encode('utf-8')

req = urllib.request.Request(url, data=data, headers=headers)
try:
    response = urllib.request.urlopen(req)
    print("Success:", response.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print("Error:", e.read().decode('utf-8'))
