import requests
url = "http://localhost:3000/"
image_file = 'media/picture.jpg'
#files = {'media': open('media/picture.jpg', 'rb')}
#requests.post(url, files=files)
#requests.post(url)
import base64
import json

import requests


with open(image_file, "rb") as f:
    im_bytes = f.read()
im_b64 = base64.b64encode(im_bytes).decode("utf8")

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

payload = json.dumps({"image": im_b64})
#payload = json.dumps({"image": "test"})
response = requests.post(url, data=payload, headers=headers)
print(response.text)
