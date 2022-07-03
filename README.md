This project builds a Lambda image to scan barcodes from pictures.
It uses SAM for building and testing.

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



