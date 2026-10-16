from doc2dash.parsers.intersphinx import InterSphinxParser
from doc2dash.parsers.types import EntryType

TYPE_MAP = {
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


class RocqSphinxParser(InterSphinxParser):
    def convert_type(self, inv_type):
        return TYPE_MAP.get(inv_type)
