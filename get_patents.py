import os
import sys
from google.cloud import bigquery
from google.oauth2 import service_account
"""
Author: Murt Bahr 20200723
This Python script is used through the command line to retrieve the patents data, both body and front,
without the need to hard-code anything. Just follow the instruction the technical documentation.
Any successful retrieval will be logged into the data_tracker.txt. And will be used later to raise
an error if the range has been already downloaded. 
Command structure: python get_patents_dev.py [cred] [front,body] [a] [b]
"""

# Input parameters from user
cred = sys.argv[1]
pos = sys.argv[2]  # [front,body]
a = sys.argv[3]  # included
b = sys.argv[4]  # excluded

# creating directories
if not os.path.exists("./data/"):
    os.mkdir("./data/")
    os.mkdir("./data/raw/")
    os.mkdir("./data/raw/body/")
    os.mkdir("./data/raw/front/")
    os.mkdir("./data/processed/")
    os.mkdir("./data/processed/body/")
    os.mkdir("./data/processed/front/")
    os.system("touch ./data/data_tracker.txt")

if pos in ['front', 'body'] and int(a) in range(10000000, 99999999) and int(b) in range(10000000, 99999999):
    pass
else:
    print("Error: one of the entered parameters is not valid.")
    sys.exit()

# Open data_tracker.text and check whether this range of years has been populated
data_tracker_file = open("./data/data_tracker.txt", "r")
for line in data_tracker_file.readlines():
    currentline = line.split(",")
    if currentline[0] == pos:
        if int(a) in range(int(currentline[1]), int(currentline[2])) or int(b)-1 in range(int(currentline[1]),
                                                                                        int(currentline[2])):
            print("Error: The entered range overlaps with another range in the data_tracker.txt:")
            print(line)
            sys.exit()
        elif int(a) < int(currentline[1]) and int(b) > int(currentline[2]):
            print("Error: The entered range includes another range in the data_tracker.txt:")
            print(line)
            sys.exit()

# Get Google Cloud credentials. [documentation: https://cloud.google.com/bigquery/docs/reference/libraries#client-libraries-usage-python]
path = './' + cred
credentials = service_account.Credentials.from_service_account_file(
    path,
    scopes=["https://www.googleapis.com/auth/cloud-platform"],
)

# Construct a BigQuery client object.
client = bigquery.Client(
    credentials=credentials,
    project=credentials.project_id,
)

if pos == 'front':
    query = """
        SELECT pub.publication_number, citations.npl_text 
        FROM `patents-public-data.patents.publications` as pub
        CROSS JOIN UNNEST(citation) as citations
        WHERE citations.npl_text <> "" 
        AND grant_date >= {} AND grant_date < {}
    """.format(a, b)
elif pos == 'body':
    query = """
        SELECT pub.publication_number, description.text 
        FROM `patents-public-data.patents.publications` as pub
        CROSS JOIN UNNEST(description_localized) as description 
        WHERE description.text <> "" 
        AND grant_date >= {} AND grant_date < {}
    """.format(a, b)

#create empty string
results = ""
#Try: send query, populate string, write to file, and update the tracker.
try:
    # querying
    print("Sending query to Google Cloud..")
    query_job = client.query(query)  # Make an API request.
    i = 0
    # print(len(query_job))
    for row in query_job:
        # Row values can be accessed by field name or index.
        # Sometimes a row is empty having no data, so use TRY to catch that. This is an error due to GoogleQuery
        try:
            # for first column, that's the ID, type double underscores before and after
            new_line = "__" + row[0] + "__" + "\t" + row[1] + '\n'
        except IndexError:
            new_line = ""
        results += new_line
        i += 1

    # Open a new text file to store the queried years, name the file as a range
    output_file_name = "./data/raw/" + pos + "/" + a + '-' + b + '.txt'
    output_file = open(output_file_name, "w")
    output_file.write(results)

    # If no error, then update the data_tracker file with the queried years range
    data_tracker_file = open("./data/data_tracker.txt", "a")
    data_tracker_file.write('\n' + pos + ',' + a + ',' + b)

    data_tracker_file.close()
    output_file.close()
    print("Done! {} rows were downloaded to {}.".format(i, output_file_name))
#If this TRY is interrupter, then print ERROR
except Exception as e:
    # print error message
    print("ERROR! ", e)
