from bs4 import BeautifulSoup
import requests
import csv

source = requests.get("https://www.youtube.com/feed/trending").text
soup = BeautifulSoup(source, "lxml")  # .text.encode("utf-8")

csv_file = open("YouTube Trending Titles on 12-30-18.csv", "w")
csv_writer = csv.writer(csv_file)
csv_writer.writerow(["Title", "Description"])

for content in soup.findAll("div", class_="yt-lockup-content"):
    # print (content)
    try:
        title = content.h3.a.text
        print(title)

        description = content.find(
            "div", class_="yt-lockup-description yt-ui-ellipsis yt-ui-ellipsis-2"
        ).text
        print(description)

    except Exception as e:
        description = None

    print("\n")
    csv_writer.writerow([title.encode("utf8"), description.encode("utf8")])

csv_file.close()
