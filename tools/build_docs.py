
#%%

import sys
import os
import re

import pandas as pd


BASE_PATH="~/projects/thirdparty/OpenComputers/"

TOP_PATH=    "src/main/scala/li/cil/oc/server"
MODS_PATH=   "src/main/scala/li/cil/oc/integration"


class Item():
    name: str=""
    stype: str=""
    base: str=""
    traits= []
    methods={}
    component: str=""

#%%

items=[]

def parse_item(f):
    data=f.read()

    item=Item()
    item.name=os.path.basename(f.name).removesuffix(".scala")

    match= re.search(f"(class|trait)(?: {item.name})(.*)", data)
    if not match:
        return None
    
    item.stype=match.group(1)
    fields=match.group(2)

    base=re.findall(r"(?<=extends )(?:\w+\.)?(\S+)", fields)
    # base=re.findall(r"(?<=extends )(\S+)", fields)
    if len(base)>0:
        item.base= base[0]

    traits= re.findall(r"(?<=with )(?:\w+\.)?(\S+)", fields)
    # traits= re.findall(r"(?<=with )(\S+)", fields)
    if len(traits)>0:
        item.traits= traits

    component=re.findall(r"(?<=withComponent\(\")\w+", data)
    if len(component)>0:
        item.component= component[0]

    methods=re.findall(r"(?:@Callback.*?doc\s*=\s*\"+)([^\"]+)(?:.+\s*def\W)(\w+)", data)
    item.methods= {x[1]: x[0] for x in methods}

    return item


for path in [BASE_PATH+TOP_PATH, BASE_PATH+MODS_PATH]:
    for dirpath, dirnames, filenames in os.walk(path):
        for filename in filenames:
            with open(dirpath+"/"+filename) as f:
                item = parse_item(f)
                if item != None:
                    items.append(item)


#%% Get all

def get_item(name: str):
    # Prefer exact
    for item in items:
        if name == item.name:
            return item
    
    for item in items:
        if name.split(".")[-1] == item.name:
            return item
        
    return None

def print_methods(name, prefix, tree):
    if name in tree:
        return
    
    tree+=[name]
    item=get_item(name)
    if item==None:
        return

    # top level
    print(prefix+"component: "+item.component)
    for function, doc in item.methods.items():
        print(prefix+function+"="+doc)

    # Base
    print(prefix+"base: "+item.base)
    print_methods(item.base, prefix+"  ", tree)
    
    # Traits
    for trait in item.traits:
        if trait in tree: continue
        print(prefix+"trait: "+trait)
        print_methods(trait, prefix+"  ", tree)

print_methods("UpgradeInventoryController", "", [])
