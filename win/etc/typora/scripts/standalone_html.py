#!/usr/bin/env python
# A simple script to suck up HTML, convert any images to inline Base64
# encoded format and write out the converted file.
#
# Usage: python standalone_html.py <input_file.html> <output_file.html>
#
# TODO: Consider MHTML format: https://en.wikipedia.org/wiki/MHTML
# TODO: only convert resource size < 10MB
# ref - [Convert HTML to a self contained file with inline Base64 encoded PNG images](https://gist.github.com/pansapiens/110431456e8a4ba4f2eb )

import os
import filetype
import mimetypes
import base64
import requests
import urllib 
from bs4 import BeautifulSoup


def guess_type(filepath):
    """
    Return the mimetype of a file, given it's path.
    This is a wrapper around two alternative methods - Unix 'file'-style
    magic which guesses the type based on file content (if available),
    and simple guessing based on the file extension (eg .jpg).
    :param filepath: Path to the file.
    :type filepath: str
    :return: Mimetype string.
    :rtype: str
    """
    return mimetypes.guess_type(filepath)[0]

def file_to_base64(filepath):
    """
    Returns the content of a file as a Base64 encoded string.
    :param filepath: Path to the file.
    :type filepath: str
    :return: The file content, Base64 encoded.
    :rtype: str
    """
    with open(filepath, 'rb') as f:
        encoded_str = base64.b64encode(f.read())
    return encoded_str.decode('utf-8')

def isUrl(path):
    return urllib.parse.urlparse(path).scheme != ""

def make_html_images_inline(in_filepath, out_filepath):
    """
    Takes an HTML file and writes a new version with inline Base64 encoded
    images.
    :param in_filepath: Input file path (HTML)
    :type in_filepath: str
    :param out_filepath: Output file path (HTML)
    :type out_filepath: str
    """
    # HTMLFile = open("2023-07.html", "r", encoding='utf8')
    basepath = os.path.split(in_filepath.rstrip(os.path.sep))[0]
    soup = BeautifulSoup(open(in_filepath, 'r',encoding='utf8'), 'html.parser')
    elems = soup.find_all('img') + soup.find_all('iframe')
    for elem in elems:
        path = elem.attrs['src']
        if path.startswith("data"):
            print("path is already data uri scheme")
            continue
        elif isUrl(path):
            print("path is url")
            data = requests.get(path).content
        else:
            print("path is filepath")
            filepath = os.path.join(basepath, elem.attrs['src'])
            with open(filepath, 'rb') as f:
                data = f.read()

        mimetype = guess_type(path)
        print("path is " + path + " mimetype is " + mimetype)
        encoded_data = base64.b64encode(data).decode("utf-8")
        elem.attrs['src'] = "data:%s;base64,%s" % (mimetype, encoded_data)
        # print(elem.attrs['src'])

    with open(out_filepath, 'w', encoding='utf8') as of:
        of.write(str(soup))

if __name__ == '__main__':
    import sys
    make_html_images_inline(sys.argv[1], sys.argv[2])
