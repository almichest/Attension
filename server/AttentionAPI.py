import falcon
import json

class AttentionAPI(object):

    def on_get(self, req, resp):
        msg = {
            "message": "Hello, World"
        }
        resp.body = json.dumps(msg)

app = falcon.API()
app.add_route("/", AttentionAPI())

def main():
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 8000, app)
    httpd.serve_forever()

if __name__ == '__main__':
    main()
