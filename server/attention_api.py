import falcon
import json

class AttentionAPI(object):

    def on_get(self, req, resp):
        msg = {
            "message": "Hello, World"
        }
        resp.body = json.dumps(msg)

    def on_post(self, req, resp):
        body = b''

        while True:

            chunk = req.stream.read()
            if not chunk:
                break

            body += chunk
            if req.content_length <= len(body):
                break

        print('request body = ' + str(body))

        resp.body = ''

app = falcon.API()
app.add_route("/", AttentionAPI())

def main():
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 8000, app)
    httpd.serve_forever()
    print('start server')

if __name__ == '__main__':
    main()
