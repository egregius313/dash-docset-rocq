import unittest

from doc2dash.parsers.types import EntryType

from coq_parser import RocqSphinxParser


class RocqSphinxParserTest(unittest.TestCase):
    def test_maps_rocq_and_standard_inventory_roles(self):
        parser = RocqSphinxParser(None)

        expected_types = {
            "rocq:attr": EntryType.ATTRIBUTE,
            "rocq:cmd": EntryType.FUNCTION,
            "rocq:cmdv": EntryType.VARIABLE,
            "rocq:exn": EntryType.EXCEPTION,
            "rocq:flag": EntryType.SETTING,
            "rocq:index": EntryType.GUIDE,
            "rocq:opt": EntryType.OPTION,
            "rocq:prodn": EntryType.TYPE,
            "rocq:table": EntryType.SETTING,
            "rocq:tacn": EntryType.FUNCTION,
            "rocq:tacv": EntryType.VARIABLE,
            "rocq:thm": EntryType.FUNCTION,
            "rocq:warn": EntryType.EXCEPTION,
            "std:doc": EntryType.GUIDE,
            "std:label": EntryType.SECTION,
            "std:term": EntryType.WORD,
            "std:token": EntryType.WORD,
        }

        for inventory_type, entry_type in expected_types.items():
            with self.subTest(inventory_type=inventory_type):
                self.assertEqual(entry_type, parser.convert_type(inventory_type))

    def test_ignores_unknown_inventory_roles(self):
        self.assertIsNone(RocqSphinxParser(None).convert_type("rocq:unknown"))
