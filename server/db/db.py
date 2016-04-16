__author__ = 'hira'

from sqlalchemy import create_engine, MetaData, Table, Column, DECIMAL, String
from attention_item import AttantionItem

__metadata = MetaData()
__attention_items = Table(
    'attention_items', __metadata,
    Column('identifier', String, primary_key=True),
    Column('place_name', String),
    Column('attention_body', String),
    Column('latitude', DECIMAL),
    Column('longitude', DECIMAL),
)

__engine = create_engine('sqlite:///db.sqlite3', echo=True)
__metadata.bind = __engine
__metadata.create_all()

print("hoge")

def insert(item):
    __attention_items.insert().execute(identifier=item.identifier,
                                       place_name=item.place_name,
                                       attention_body=item.attention_body,
                                       latitude=item.latitude,
                                       longitude=item.longitude)
def update(item):
    __attention_items.update().where(__attention_items.c.identifier == item.identifier).execute(place_name=item.place_name,
                                                                                                attention_body=item.attention_body,
                                                                                                latitude=item.latitude,
                                                                                                longitude=item.longitude)

