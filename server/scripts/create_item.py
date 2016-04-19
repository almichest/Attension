__author__ = 'hira'
import sys
import json
import urllib3

def main():
    identifier = sys.argv[1]
    url = 'http://localhost:8000/api/add'

    post_data = json.dumps({
        'identifier': identifier,
        'attention_body': "hogehogehogehogehogehoge"
    })

    headers = {
        'Content-Type': 'application/json'
    }

    http = urllib3.PoolManager()

    http.request('POST', url, headers=headers, body=post_data)


if __name__ == '__main__':
    main()
