__author__ = 'hira'
import math

_a2 = 6378137.0 ** 2.0
_b2 = 6356752.314140 ** 2.0
_e2 = (_a2 - _b2) / _a2

def distance_by_huubeny(p1, p2):
    def d2r(deg):
        return deg * (2.0 * math.pi) / 360.0
    (lon1, lat1, lon2, lat2) = map(d2r, p1 + p2)
    w = 1.0 - _e2 * math.sin((lat1 + lat2) / 2.0) ** 2.0
    c2 = math.cos((lat1 + lat2) / 2.0) ** 2.0
    return math.sqrt((_b2 / w ** 3.0) * (lat1 - lat2) ** 2.0 + (_a2 / w) * c2 * (lon1 - lon2) ** 2.0)