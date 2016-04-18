__author__ = 'hira'

from sqlalchemy import create_engine, MetaData, Table, Column, FLOAT, String

class AttentionDatabase(object):

    def __init__(self, db_name):

        self.__metadata = MetaData()
        self.__attention_items = Table(
            'attention_items', self.__metadata,
            Column('identifier', String, primary_key=True),
            Column('place_name', String),
            Column('attention_body', String),
            Column('latitude', FLOAT),
            Column('longitude', FLOAT),
        )

        self.__engine = create_engine('sqlite:///' + db_name, echo=True)
        self.__metadata.bind = self.__engine
        self.__metadata.create_all()


    def insert(self, item):
        self.__attention_items.insert().execute(identifier=item.identifier,
                                                place_name=item.place_name,
                                                attention_body=item.attention_body,
                                                latitude=item.latitude,
                                                longitude=item.longitude)
    def update(self, item):
        self.__attention_items.update().where(self.__attention_items.c.identifier==item.identifier).execute(place_name=item.place_name,
                                                                                                              attention_body=item.attention_body,
                                                                                                              latitude=item.latitude,
                                                                                                              longitude=item.longitude)
    def remove(self, item):
        self.__attention_items.delete().where(self.__attention_items.c.identifier==item.identifier).execute()

    def remove_all(self):
        self.__attention_items.delete().execute()

    def get_items(self, identifier=None):

        def convert(item):
            dic = {}
            dic['identifier'] = item[0]
            dic['place_name'] = item[1]
            dic['attention_body'] = item[2]
            dic['latitude'] = item[3]
            dic['longitude'] = item[4]
            return dic

        if identifier == None:
            items = self.__attention_items.select().execute().fetchall()
        else:
            items = self.__attention_items.select().where(self.__attention_items.c.identifier==identifier).execute().fetchall()

        return list(map(convert, items))

