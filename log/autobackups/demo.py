CLIENT_SECRET_FILE = './client_secret_tugas.json'
API_NAME = 'drive'
API_VERSION = 'v3'
SCOPES = ['https://www.googleapis.com/auth/drive']
service = Create_Service(CLIENT_SECRET_FILE, API_NAME, API_VERSION, SCOPES)
folder_id = '1auNsJDRkxSjEjx1sbOr7jDyDKoyo1OkP'
file_names = ['/var/log/nginx/access.log']
mime_types = ['text/plain']
def func():
    try:
        for file_name, mime_type in zip(file_names, mime_types):
            file_metadata = {
                'name' : file_name,
                'parents' : [folder_id]
            }

            media = MediaFileUpload(file_name, mimetype=mime_type)
            service.files().create(
                body=file_metadata,
                media_body=media,
                fields='id',
            ).execute()
            print("Success")
    except:
        print("Error!")

func()