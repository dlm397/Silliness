import requests
import json
import prettytable

# Format and Examples for Hashes passed to API
'''
For API hashes, see https://www.bls.gov/help/hlpforma.htm

Consumer Price Index - Seasonally Ajusted
  All Urban Consumers, excluding food and energy - CUSR0000SA0L1E

Producer Price Index - Not adjusted
  Selected Healthcare - PCUASHC--ASHC--
  Services less trades, transportation, and warehousing - PCUATTDSVATTDSV
'''

# Default folder to save data
folder = 'BLS_Data/'

# Headers to pass to API
headers = {'Content-type': 'application/json'}

# Hashes to pass to API
data_type = ['NOT_AN_API_HASH',
             'CUSR0000SA0L1E',
             'PCUATTDSVATTDSV',
             'PCUASHC--ASHC--'
             ]

# Puts together packet for API call
data = json.dumps({
                "seriesid": data_type,
                "startyear":"2015", 
                "endyear":"2025"
                }) 

# Sends API call
packet = requests.post(
                'https://api.bls.gov/publicAPI/v2/timeseries/data/', 
                data=data, 
                headers=headers
                )

# Loads text for JSON packet returned by API call
json_data = json.loads(packet.text)

if json_data['status'] == 'REQUEST_NOT_PROCESSED':
    raise Exception(json_data['message'])
    
# Extracts data from text for each series requested
for series in json_data['Results']['series']:
    # Initializes array like to be saved to text document later, PrettyTable is used to make the text document more readable
    x=prettytable.PrettyTable(["series id","year","period","value","footnotes"])
    seriesId = series['seriesID']
    # Checks that series has data, prints an error if it does
    if len(series['data']) == 0:
        print(f'Series ID: "{seriesId}" has no data, likely incorrect API hash')
        continue
    else:
        print(f'Series ID: "{seriesId}" successfully loaded')
    # Loads data from current series by variable
    for item in series['data']:
        year = item['year']
        period = item['period']
        value = item['value']
        footnotes=""
        for footnote in item['footnotes']:
            if footnote:
                footnotes = footnotes + footnote['text'] + ','
        if 'M01' <= period <= 'M12':
            x.add_row([seriesId,year,period,value,footnotes[0:-1]])
    # Opens a text document
    if folder != '':
        if folder[-1] != '/':
            folder = folder + '/'
    output = open(folder + seriesId + '.txt','w')
    # Loads array like into text document
    output.write (x.get_string())
    # Exits opened text document
    output.close()