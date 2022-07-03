This project builds a small AWS Lambda image to scan barcodes from pictures. The Lambda is put behind an AWS HTTP API Gatewy.
It uses SAM for building and testing.

# Setup

Run 
```
sam build --cached && sam local start-api
```
to create a local API at http://localhost:3000.

You can test the functionality by creating a media folder and saving a picture under ./media/picture.jpg.
Then run
```
python3 main.py
```
and it should return a JSON of the form
```
{"code": "#########"}
```

# Details

The final Lambda image has a size of 73.3MB.

# Pyzbar Modification
Note that pyzbar was slightly modified. Specifically in zbar_library.py
```
from ctypes.util import find_library

find_library('zbar')
```
was changed to the explicit
```
path = Path("/usr/lib/libzbar.so.0") 
```
to circumvent issues under alpine python.
