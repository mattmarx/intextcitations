# Start up a Grobid server on the same node that runs this Python script.

# Copying the input file to $TMPDIR is a good idea.

# module load python3/3.6.9
# python multi_proc.py  nplwindowsoneperpat.tsv patent_info.txt


import os
import argparse
 
from multiprocessing import Pool

import requests
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

import time
import tqdm
 
url = 'http://localhost:8070/api/processCitationPatentTXT'

# Set of lines handed to each worker
CHUNKSIZE=24

def get_nslots():
    ''' Get the number of assigned CPUs from the
        SCC environment '''
    nslots=1
    if 'NSLOTS' in os.environ:
        nslots= int(os.environ['NSLOTS']) - 4
        # Save a few processors for Java, hence subtraction of 4
        # if this is an illegal value, don't.
        if nslots < 1:
            nslots= int(os.environ['NSLOTS']) 
    return nslots

 
    
def grobid_line(line):
    ''' map each line of the file to the Grobid service '''
    try:
        myobj = {'input': line}
        # Set up the URL request to handle many retries with a 
        # backoff factor
        sess = requests.Session()
        retries = Retry(total=64,
                    backoff_factor=0.05)
        sess.mount('http://', HTTPAdapter(max_retries=retries))
        result = sess.post(url, data = myobj)
        #soup = BeautifulSoup(result.text,'lxml')
        #out_str=''
        #for t in soup.find_all('biblstruct'):  
            # for each biblstruct get all tags
            # t.find_all('author')...etc...
            # build a return string 
        if result.status_code == 200:
            return result.text
    except Exception as e:
        # Something terrible happened.  Print and carry on. 
        print(e.msg)
        pass
    return None
    
def read_and_process(in_file, out_file):
    ''' Read the requested accounting file(s) and compute stats using Spark.
        The in_file can be in the format that Spark accepts for its textFile function
        so wildcard characters are accepted.'''
    print("** Processing patent file %s" % in_file)
    with open(in_file) as f:
        # Load the file into memory. Not the most elegant way to do this
        # but it's easy.
        flines = f.readlines()
        with Pool(get_nslots()) as workers:
            output=[]
            with tqdm.tqdm(total=len(flines)) as prog_bar:   
                for i, result in tqdm.tqdm(enumerate(workers.imap_unordered(grobid_line, flines,CHUNKSIZE))): 
                    output.append(result)
                    prog_bar.update()
            n_xml = len(output)
            workers.close()
    print("** Writing XML to output file %s" % out_file)
    with open(out_file,'w') as f:
        for o in output:
            # This will skip any None values returned from a bad 
            # call to GROBID
            if o:
                f.write('%s\n' % o) 
    return n_xml
    
if __name__=='__main__':
    # When run as a script create a command line parser
    parser = argparse.ArgumentParser()
    parser.add_argument("in_file", help="One patent per line input file",type=str)
    parser.add_argument("out_file", help="Output file.",type=str)

    # Process the command line
    args = parser.parse_args()
    # Send the filename off to be processed....
    start = time.time()
    n_xml = read_and_process(args.in_file, args.out_file)
    end = time.time()
    print("%s XML records written to file %s in %s seconds." % (n_xml,args.out_file,end-start))
    
 

 
