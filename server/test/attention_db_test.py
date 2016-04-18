__author__ = 'hira'
from unittest import TestCase
from nose.tools import ok_, eq_
from db.db import AttentionDatabase
from attention_item import AttentionItem
import json

class AttentionDatabaseTest(TestCase):
    def setUp(self):
        print('setUp')
        self.database = AttentionDatabase(db_name='testdb.sqlite3')
        self.database.remove_all()

    def tearDown(self):
        print('tearDown')
        self.database.remove_all()

    def test_get_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier1'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        item = AttentionItem()
        item.identifier = 'test_identifier2'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_items(identifier=item.identifier)
        eq_(len(items), 1)

    def test_get_all_items(self):
        item = AttentionItem()
        item.identifier = 'test_identifier1'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        item = AttentionItem()
        item.identifier = 'test_identifier2'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_items()
        print(items)
        eq_(len(items), 2)

        result = json.dumps(items)
        print(result)

    def test_insert_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_items()
        eq_(len(items), 1)

        fetched_item = items[0]
        eq_(fetched_item['identifier'], item.identifier)
        eq_(fetched_item['attention_body'], item.attention_body)
        eq_(fetched_item['place_name'], item.place_name)
        eq_(fetched_item['latitude'], item.latitude)
        eq_(fetched_item['longitude'], item.longitude)

    def test_update_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_items()
        eq_(len(items), 1)

        fetched_item = items[0]

        new_item = AttentionItem()
        new_item.attention_body = 'updated_body'
        new_item.identifier = fetched_item['identifier']

        self.database.update(new_item)
        items = self.database.get_items()
        fetched_item = items[0]
        eq_(len(items), 1)
        eq_(fetched_item['attention_body'], 'updated_body')


    def test_delete_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_items()
        eq_(len(items), 1)

        fetched_item = items[0]
        new_item = AttentionItem()
        new_item.identifier = fetched_item['identifier']
        self.database.remove(new_item)

        items = self.database.get_items()
        eq_(len(items), 0)

    def test_delete_all_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier1'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        item = AttentionItem()
        item.identifier = 'test_identifier2'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_items()
        eq_(len(items), 2)

        self.database.remove_all()

        items = self.database.get_items()
        eq_(len(items), 0)



