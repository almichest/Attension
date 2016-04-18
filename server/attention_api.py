import falcon
import json
from attention_item import AttentionItem
from db.db import AttentionDatabase

_database = AttentionDatabase(db_name='db.sqlite3')

class Get(object):

    def on_get(self, req, resp):
        items = _database.get_items()
        print(items)
        resp.body = json.dumps(items)

class Post(object):
    def on_post(self, req, resp):

        validation = self.validate_post_request_header(req)
        if validation == '400':
            resp.status = falcon.HTTP_400
            resp.body = ''
            return

        body = b''

        while True:
            chunk = req.stream.read(65536)
            print(chunk)
            if not chunk:
                break

            body += chunk
            if req.content_length <= len(body):
                break

        dic = json.loads(body.decode('utf-8'), encoding='utf-8')

        validation = self.validate_post_request_body(dic)
        if validation[0] == '400':
            resp.status = falcon.HTTP_400
            error = '{error_code : ' + validation[1] + '}'
            resp.body = error
            return

        self.add_item(dic)

        resp.status = falcon.HTTP_200
        resp.body = ''

    def add_item(self, dic):
        item = AttentionItem()
        item.identifier = dic['identifier']
        if 'place_name' in dic:
            item.place_name = dic['place_name']
        if 'attention_body' in dic:
            item.attention_body = dic['attention_body']
        if 'latitude' in dic:
            item.latitude = dic['latitude']
        if 'longitude' in dic:
            item.longitude = dic['longitude']

        _database.insert(item)

    def validate_post_request_header(self, req):
        if req.content_type != 'application/json':
            return '400'
        if req.content_length <= 0:
            return '400'

        return '200'

    def validate_post_request_body(self, body):
        if not 'identifier' in body:
            return ('400', '1')
        if _database.get_items(identifier=body['identifier']):
            return ('400', '2')

        return '200'

app = falcon.API()
app.add_route('/', Get())
app.add_route('/add/', Post())

def start_server():
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 8000, app)
    httpd.serve_forever()


