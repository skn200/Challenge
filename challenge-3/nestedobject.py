from operator import getitem
from functools import reduce
import json

def get_key_value(dataset, keys):
    try:
        return reduce(getitem, keys, dataset)
    except (KeyError, IndexError):
        return None

dataobject1 = {"a":{"b":{"c":"d"}}}
dataobject2 = {"x":{"y":{"z":"a"}}}

key1 = "a/b/c"
key2 = "x/y/z"

keyobject = (list(key1.split("/")))
keyobject = (list(key2.split("/")))


print("Value for dataobject1 and key1 - :",get_key_value(dataset=dataobject, keys=keyobject))

print("Value for dataobject2 and key2 - :",get_key_value(dataset=dataobject, keys=keyobject))