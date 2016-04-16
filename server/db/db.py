__author__ = 'hira'

from sqlalchemy import create_engine, MetaData, Table, Column, Float, String

metadata = MetaData()
attention_items = Table(
    'attention_items', metadata,
    Column('identifier', String, primary_key=True),
    Column('place_name', String),
    Column('attention_body', String),
    Column('latitude', Float),
    Column('longitude', Float),
)

engine = create_engine('sqlite:///db.sqlite3', echo=True)
metadata.bind = engine
metadata.create_all()

def insert(item):
    attention_items.insert().execute(identifier='hogehoge', place_name='新宿駅')
