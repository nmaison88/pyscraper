#!/usr/bin/env python3
import re
import requests
from urllib.parse import urlsplit
from collections import deque
from bs4 import BeautifulSoup
import pandas as pd



def pasteMode():
  print('Paste Mode:\n')
  original_url = input("Enter the website url: ") 

  unscraped = deque([original_url])  

  scraped = set()  

  emails = set()  

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
      emails.update(new_emails) 

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
  d = {'Sites': scraped, 'Emails': emails}
  df = pd.DataFrame(data = d)
  df.to_csv('email.csv', index=False)
  print(df)

def csvMode():
  print('Csv Mode:')
  csvFile = input('enter the name of the Csv, make sure its in the same folder as this program\n')
  print('you entered: \n'+ str(csvFile))
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

start();
