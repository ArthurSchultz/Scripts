#!/usr/bin/python

import subprocess
import os
import csv

sn = []
tag = []
task = subprocess.Popen(
    ['system_profiler', 'SPHardwareDataType'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)

out, err = task.communicate()

for l in out.split('\n'):
    if 'Serial Number (system)' in l:
        serial_line = l.strip()
        break
serial = serial_line.split(' ')[-1]

sn_e = len(sn)
tag_e = len(tag)

if sn_e == tag_e:
    print "Same number of elements"
else:
    print "Elements are wrong"
    quit()

if serial not in sn:
    print("Nope")
    quit()
if serial in sn:
    print("Yes, Serial Number Found")
    index = (sn.index(serial))
    assettag = (tag[index])
print assettag, serial

setasset = subprocess.Popen(
    ['jamf', 'recon', '-assetTag', assettag],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)

def rename_computer():
    cmd = ['/usr/local/bin/jamf', 'setComputerName', '-name', assettag]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, _ = proc.communicate()
    if proc.returncode == 0:
        # on success the jamf binary reports 'Set Computer Name to XXX'
        # so we split the phrase and return the last element
        return out.split(' ')[-1]
    else:
        return False
rename_computer()
task = subprocess.Popen(
    ['jamf', 'recon',],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)
