#!/usr/bin/env python3

import sys
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import Element, fromstring

def main():
  filename = sys.argv[1]
  version = sys.argv[2]
  tree = ET.parse(filename)
  dic: Element = tree.getroot().find("dict")
  for x in [
      "<key>dashIndexFilePath</key>",
      "<string>index.html</string>",
      "<key>DashDocSetFallbackURL</key>",
      f"<string>https://rocq-prover.org/doc/V{version}/refman/</string>"
  ]:
    dic.append(fromstring(x))
  tree.write(filename)

if __name__ == "__main__":
  main()
