__author__ = 'hira'

import unittest
from nose.tools import ok_, eq_
import util


class UtilTestCase(unittest.TestCase):
    def test_hubeny(self):
        p1 = (50, 100)
        p2 = (100, 50)

        result = util.distance_by_huubeny(p1, p2)

        ok_(0 < result)

