import fastapi
import uvicorn
import os
import json

app = fastapi.FastAPI()

@app.get("/")
def index():
    return {"message": "There is nothing here."}

@app.get("/apps")
def apps():
    # Scan /apps directory for apps
    apps_dir = r"C:\Users\raspb\OneDrive\Desktop\App launcher CCT\apps"
    apps = []
    for app in os.listdir(apps_dir):
        apps.append(app)
        # Exclude apps that start with !
        if app.startswith("!"):
            apps.remove(app)
    return {"apps": apps}

@app.get("/apps/{app}")
def app_details(app: str):
    # Get app details
    app_details = {}
    with open(fr"C:\Users\raspb\OneDrive\Desktop\App launcher CCT\apps\{app}\app.json", "r") as f:
        app_details = json.load(f)
    return app_details

@app.get("/apps/{app}/download/lua")
def download_app_lua(app: str):
    # Send the main.lua and logo.pbm files
    app_dir = fr"C:\Users\raspb\OneDrive\Desktop\App launcher CCT\apps\{app}"
    try:
        with open(os.path.join(app_dir, "main.lua"), "rb") as f:
            main_lua = f.read()
            return fastapi.responses.StreamingResponse(iter([main_lua]), media_type="application/octet-stream")
    except FileNotFoundError:
        return {"message": "Lua not found"}
    
@app.get("/apps/{app}/download/logo")
def download_app_logo(app: str):
    # Send the logo.pbm file
    app_dir = fr"C:\Users\raspb\OneDrive\Desktop\App launcher CCT\apps\{app}"
    try:
        with open(os.path.join(app_dir, "logo.pbm"), "rb") as f:
            logo_pbm = f.read()
            return fastapi.responses.StreamingResponse(iter([logo_pbm]), media_type="image/x-portable-bitmap")
    except FileNotFoundError:
        return {"message": "Logo not found"}

@app.get("/get")
def get(file):
    app_dir = r"C:\Users\raspb\OneDrive\Desktop\App launcher CCT"
    if file == "main":
        with open(os.path.join(app_dir, "main.lua"), "rb") as f:
            main_lua = f.read()
            return fastapi.responses.StreamingResponse(iter([main_lua]), media_type="application/octet-stream")
    elif file == "ui":
        with open(os.path.join(app_dir, "ui.lua"), "rb") as f:
            main_lua = f.read()
            return fastapi.responses.StreamingResponse(iter([main_lua]), media_type="application/octet-stream")
    elif file == "startup":
        with open(os.path.join(app_dir, "startup.lua"), "rb") as f:
            main_lua = f.read()
            return fastapi.responses.StreamingResponse(iter([main_lua]), media_type="application/octet-stream")
    else:
        return {"message": "File not found"}

    
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)