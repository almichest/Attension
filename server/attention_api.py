import falcon
import json
from attention_item import AttentionItem
from db.db import AttentionDatabase

_database = AttentionDatabase(db_name='db.sqlite3')
_debug_database = AttentionDatabase(db_name='debug_db.sqlite3')

class Get(object):

    _OK = '0'
    _INVALID_QUERY = '1'

    def on_get(self, req, resp):

        if hasattr(req, 'query_string') and req.query_string.count('debug=true'):
            items = _database.get_items()
        else:
            items = _debug_database.get_items()

        if hasattr(req, 'query_string') and 0 < len(req.query_string):
            print('query = ' + req.query_string)
            validation = self.validate_query(req.query_string)
            if validation[0] == '400':
                resp.status = falcon.HTTP_400
                error = '{error_code : ' + validation[1] + '}'
                resp.body = error
                return

            items = self.filter_with_query(req.query_string, items)

        resp.body = json.dumps(items)

    def validate_query(self, query):
        import urllib.parse
        queries = urllib.parse.parse_qs(query)
        if not 'longitude' in queries or not 'latitude' in queries or not 'radius' in queries :
            return ('400', self._INVALID_QUERY )
        return ('200', self._OK)


    def filter_with_query(self, query, items):
        print(query)
        return items

class Post(object):

    _OK = '0'
    _INVALID_CONTENT_TYPE = '1'
    _INVALID_CONTENT_LENGTH = '2'
    _INVALID_CONTENT_BODY = '3'
    _SAME_IDENTIFIER_ALREADY_EXISTS = '4'

    def on_post(self, req, resp):

        if hasattr(req, 'query_string') and req.query_string.count('debug=true'):
            database = _database
        else:
            database = _debug_database

        validation = self.validate_post_request_header(req)
        if validation[0] == '400':
            resp.status = falcon.HTTP_400
            error = '{error_code : ' + validation[1] + '}'
            resp.body = error
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

        self.add_item(dic, database)

        resp.status = falcon.HTTP_200
        resp.body = ''

    def add_item(self, dic, database):
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

        database.insert(item)

    def validate_post_request_header(self, req):
        if req.content_type != 'application/json':
            return ('400', self._INVALID_CONTENT_TYPE)
        if req.content_length <= 0:
            return ('400', self._INVALID_CONTENT_BODY)

        return ('200', self._OK)

    def validate_post_request_body(self, body):
        if not 'identifier' in body:
            return ('400', self._INVALID_CONTENT_BODY)
        if _database.get_items(identifier=body['identifier']):
            return ('400', self._SAME_IDENTIFIER_ALREADY_EXISTS)

        return ('200', self._OK)

app = falcon.API()
app.add_route('/api/', Get())
app.add_route('/api/add/', Post())

def start_server():
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 8000, app)
    httpd.serve_forever()


