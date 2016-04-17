import falcon
import json

class Get(object):

    def on_get(self, req, resp):
        msg = {
            "message": "Hello, World"
        }
        resp.body = json.dumps(msg)

class Post(object):
    def on_post(self, req, resp):

        validation = self.validate_post_request_header(req)
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

        dic = json.loads(body.decode('utf-8'), encoding='utf-8')

        validation = self.validate_post_request_body(dic)
        if validation == '400':
            resp.status = falcon.HTTP_400
            resp.body = ''
            return

        resp.status = falcon.HTTP_200
        resp.body = ''

    def validate_post_request_header(self, req):
        if req.content_type != 'application/json':
            return '400'
        if req.content_length <= 0:
            return '400'

        return '200'

    def validate_post_request_body(self, body):
        if not 'identifier' in body:
            return '400'

        return '200'

app = falcon.API()
app.add_route('/', Get())
app.add_route('/add/', Post())

def main():
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 8000, app)
    httpd.serve_forever()
    print('start server')

if __name__ == '__main__':
    main()
