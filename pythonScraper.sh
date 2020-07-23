#!/usr/bin/env python3
import re
import requests
from urllib.parse import urlsplit
from collections import deque
from bs4 import BeautifulSoup
import pandas as pd
import csv
import time
import datetime
from os import listdir
from os.path import isfile, join



def checkCsv(csvName):
  try:
    csvNamelocation = 'PlaceCsvHere/'+csvName
    with open(csvNamelocation, newline='') as csvfile:
      reader = csv.reader(csvfile, delimiter=',', quotechar="'")
      original_urls = []
      for row in reader:
        if row[0] != 'Sites':
          original_urls.append(row[0])
          # print(row[0])
      print('detected Urls From Csv:\n')
      new_csv_to_create = "scraped_"+ csvName
      scrape(original_urls,new_csv_to_create )
  except:
    print('CSV doesnt exist in directory, either mispelled or not in directory\n')
    print('Files Found in Folder that were detected:\n')
    onlyfiles = [f for f in listdir('PlaceCsvHere') if isfile(join('PlaceCsvHere', f))]
    print(str(onlyfiles).strip('[]'))
    time.sleep(1)
    print('.')
    time.sleep(1)
    print('..')
    time.sleep(1)
    print('...')
    print('Please double Check File name and try again\n')

    csvMode();



def pasteMode():
  print('Paste Mode:\n')
  original_url = input("Enter the website url: ") 
  today = datetime.datetime.now().strftime("%c")

  scrape(original_url,str(today)+'.csv')

def csvMode():
  print('Csv Mode:')
  csvName = input('enter the name of the Csv, make sure its in the same folder as this program\n')
  print('you entered: \n'+ str(csvName))
  checkCsv(csvName);

def start():
  choice = int(input("Enter the Mode: \n 1 for paste Mode \n 2 for Csv Mode \n 9 to quit program \n"))

  if choice == 1:
    pasteMode();

  elif choice == 2:
    csvMode();
    
  elif choice == 9:
    print('Closing Program')
    exit()

  elif choice != 1 and choice != 2 and choice != 'exit':
    print('    Choice entered ' + str(choice) + ' Invalid')
    start()


def scrape(original_url, csvName = "email.csv"):

  if(isinstance(original_url, (list))):
    unscraped = deque(original_url)
    print(unscraped)  
  else:
    unscraped = deque([original_url])  


  scraped = set()  
  emails = []  
  while len(unscraped):
      url = unscraped.popleft()  
      scraped.add(url)
      parts = urlsplit(url)
      base_url = "{0.scheme}://{0.netloc}".format(parts)
      if '/' in parts.path:
        path = url[:url.rfind('/')+1]
      else:
        path = url
      print("Crawling URL %s" % url)
      try:
          response = requests.get(url)
      except (requests.exceptions.MissingSchema, requests.exceptions.ConnectionError):
        continue
      new_emails = set(re.findall(r"[a-z0-9\.\-+_]+@[a-z0-9\.\-+_]+\.com", response.text, re.I))
      if new_emails:
        emails.append({"Sites": url,"emails":str(list(new_emails)).strip('[]')})
      else:
        emails.append({"Sites": url,"emails":" "})
      soup = BeautifulSoup(response.text,  "html.parser")

      for anchor in soup.find_all("a"):
        if "href" in anchor.attrs:
          link = anchor.attrs["href"]
        else:
          link = ''
          if link.startswith('/'):
              link = base_url + link

          elif not link.startswith('http'):
              link = path + link

          if not link.endswith(".gz"):
            if not link in unscraped and not link in scraped:
                unscraped.append(link)
  d =  emails
  df = pd.DataFrame(data = d)
  resultLocation = 'Results/'+csvName
  df.to_csv(resultLocation, index=False)
  print('Completed Scraping, New Csv File is added to Results Folder, Thank you!')

start();
