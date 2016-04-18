__author__ = 'hira'

class AttentionItem(object) :

    def __init__(self):
        self._identifier = ''
        self._place_name = ''
        self._attention_body = ''
        self._latitude = 0
        self._longitude = 0

    @property
    def identifier(self):
        return self._identifier

    @identifier.setter
    def identifier(self, identifier):
        self._identifier = identifier

    @property
    def place_name(self):
        return self._place_name

    @place_name.setter
    def place_name(self, place_name):
        self._place_name = place_name

    @property
    def attention_body(self):
        return self._attention_body

    @attention_body.setter
    def attention_body(self, attention_body):
        self._attention_body = attention_body

    @property
    def latitude(self):
        return self._latitude

    @latitude.setter
    def latitude(self, latitude):
        self._latitude = latitude

    @property
    def longitude(self):
        return self._longitude

    @longitude.setter
    def longitude(self, longitude):
        self._longitude = longitude

