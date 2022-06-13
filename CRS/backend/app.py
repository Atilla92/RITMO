from sanic import Sanic
from sanic_cors import CORS
from sanic.response import json

app = Sanic(name="Ritmo")

CORS(app, automatic_options=True, supports_credentials=True)


@app.route("/save_result", methods=["POST", "OPTIONS"])
async def save_result(request):
    """Generate a user session"""
    request_json = request.json
    csv_data = request_json["data"]
    name = request_json["name"]
    with open("res/{}.csv".format(name), "w+") as f:
        f.write(csv_data)

    return json({"status": "success"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True, workers=1)
