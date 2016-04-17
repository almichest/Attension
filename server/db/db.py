__author__ = 'hira'

from sqlalchemy import create_engine, MetaData, Table, Column, DECIMAL, String
from attention_item import AttentionItem

class AttentionDatabase(object):

    def __init__(self, db_name):

        self.__metadata = MetaData()
        self.__attention_items = Table(
            'attention_items', self.__metadata,
            Column('identifier', String, primary_key=True),
            Column('place_name', String),
            Column('attention_body', String),
            Column('latitude', DECIMAL),
            Column('longitude', DECIMAL),
        )

        self.__engine = create_engine(db_name, echo=True)
        self.__metadata.bind = self.__engine
        self.__metadata.create_all()


    def insert(self, item):
        self.__attention_items.insert().execute(identifier=item.identifier,
                                                place_name=item.place_name,
                                                attention_body=item.attention_body,
                                                latitude=item.latitude,
                                                longitude=item.longitude)
    def update(self, item):
        self.__attention_items.update().where(self.__attention_items.c.identifier == item.identifier).execute(place_name=item.place_name,
                                                                                                              attention_body=item.attention_body,
                                                                                                              latitude=item.latitude,
                                                                                                              longitude=item.longitude)
    def remove(self, item):
        self.__attention_items.delete().where(self.__attention_items.c.identifier == item.identifier).execute()

    def remove_all(self):
        self.__attention_items.delete().execute()


    def get_all_items(self):

        def convert(item):
            attention_item = AttentionItem()
            attention_item.identifier = item[0]
            attention_item.place_name = item[1]
            attention_item.attention_body = item[2]
            attention_item.latitude = item[3]
            attention_item.longitude = item[4]
            return attention_item


        items = self.__attention_items.select().execute().fetchall()
        return list(map(convert, items))

