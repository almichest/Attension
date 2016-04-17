import falcon
import json

class AttentionAPI(object):

    def on_get(self, req, resp):
        msg = {
            "message": "Hello, World"
        }
        resp.body = json.dumps(msg)

    def on_post(self, req, resp):

        validation = self.validate_post_request(req)
        if validation == '400':
            resp.status = falcon.HTTP_400
            resp.body = ''
            return

        body = b''

        while True:

            chunk = req.stream.read()
            if not chunk:
                break

            body += chunk
            if req.content_length <= len(body):
                break

        print('request body = ' + str(body))

        resp.status = falcon.HTTP_200
        resp.body = ''

    def validate_post_request(self, req):
        if req.content_type != 'application/json':
            return '400'
        if req.content_length <= 0:
            return '400'

        return '200'

app = falcon.API()
app.add_route("/", AttentionAPI())

def main():
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 8000, app)
    httpd.serve_forever()
    print('start server')

if __name__ == '__main__':
    main()
