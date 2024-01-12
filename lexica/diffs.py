nwl20 = open('NWL20.txt').read().strip().split('\n')
nwl18 = open('NWL18.txt').read().strip().split('\n')
nwl24 = open('NWL24.txt').read().strip().split('\n')

nwl20s = set([w.split()[0].upper() for w in nwl20])
nwl18s = set([w.split()[0].upper() for w in nwl18])
nwl24s = set([w.split()[0].upper() for w in nwl24])

deleted = nwl18s - nwl20s 

readded = deleted.intersection(nwl24s)
for i in sorted(list(readded)):
    print(i)



