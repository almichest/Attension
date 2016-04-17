__author__ = 'hira'
from unittest import TestCase
from nose.tools import ok_, eq_
from db.db import AttentionDatabase
from attention_item import AttentionItem

class AttentionDatabaseTest(TestCase):
    def setUp(self):
        print('setUp')
        self.database = AttentionDatabase(db_name='sqlite:///testdb.sqlite3')
        self.database.remove_all()

    def tearDown(self):
        print('tearDown')
        self.database.remove_all()

    def test_insert_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_all_items()
        eq_(len(items), 1)

        fetched_item = items[0]
        eq_(fetched_item.identifier, item.identifier)
        eq_(fetched_item.attention_body, item.attention_body)
        eq_(fetched_item.place_name, item.place_name)
        eq_(fetched_item.latitude, item.latitude)
        eq_(fetched_item.longitude, item.longitude)

    def test_update_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_all_items()
        eq_(len(items), 1)

        fetched_item = items[0]
        fetched_item.attention_body = 'updated_body'

        self.database.update(fetched_item)
        items = self.database.get_all_items()
        fetched_item = items[0]
        eq_(len(items), 1)
        eq_(fetched_item.attention_body, 'updated_body')


    def test_delete_item(self):
        item = AttentionItem()
        item.identifier = 'test_identifier'
        item.attention_body = 'test_body'
        item.place_name = 'test_place_name'
        item.latitude = 0.5
        item.longitude = 1.0
        self.database.insert(item)

        items = self.database.get_all_items()
        eq_(len(items), 1)

        fetched_item = items[0]
        self.database.remove(fetched_item)

        items = self.database.get_all_items()
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

        items = self.database.get_all_items()
        eq_(len(items), 2)

        self.database.remove_all()

        items = self.database.get_all_items()
        eq_(len(items), 0)



