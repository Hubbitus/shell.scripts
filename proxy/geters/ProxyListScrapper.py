import os
import pathlib

import requests
from bs4 import BeautifulSoup, Tag


class Proxy:
    def __init__(self, ip, port, proxy_type):
        self.ip = ip
        self.port = port
        self.proxy_type = proxy_type

    def __str__(self):
        return f'{self.proxy_type}://{self.ip}:{self.port}'


ProxyList = set[Proxy]


class ProxyListScrapper:
    def __init__(self, name: str, urls: dict[str,str], basedir: str = os.environ.get('DIR', 'lists')):
        """
        Class for easy parsing remote HTML resources to extract a proxy list from them
        In most cases you will need to override get_table_trs and parse_table_tr_to_proxy

        :param basedir: Base directory for save files. Most probably should be taken from env of script parameters
        :param name: Name of scrapper, like 'cyber-gateway.net', 'freeproxyupdate.com' and so on
        :param basedir: Base directory for save files. Most probably should be taken from env of script parameters
        :param urls:
        """
        self.name = name
        self.basedir = pathlib.Path(basedir)
        self.urls = urls

        self.parse()

    def filename(self, suffix: str) -> str:
        return os.path.join(self.basedir, f'{self.name}.{suffix}.txt')

    def parse(self) -> None:
        """
        Main method to start parsing
        :return:
        """
        for file_type, url in self.urls.items():
            soup = self._download_page(url)
            proxy_list: ProxyList = self.get_proxy_list(soup)

            with open(self.filename(file_type), 'w') as file:
                for proxy in proxy_list:
                    file.write(str(proxy) + '\n')


    @staticmethod
    def _download_page(url: str) -> BeautifulSoup:
        doc = requests.get(url)
        if 200 != doc.status_code:
            exit(f'Document [{url}] get failed with code {doc.status_code}')

        html = doc.content
        # https://www.crummy.com/software/BeautifulSoup/bs4/doc/
        soup = BeautifulSoup(html, 'html.parser')

        return soup


    def get_proxy_list(self, soup: BeautifulSoup) -> ProxyList:
        """
        Parse proxy list from HTML source
        """
        proxy_list = ProxyList()

        for tr in self.get_table_trs(soup):
            if tr.td is None or tr.td.get('colspan', False):  # <thead>
                continue

            proxy = self.parse_table_tr_to_proxy(tr)
            proxy_list.add(proxy)

        return proxy_list


    @staticmethod
    def get_table_trs(soup: BeautifulSoup) -> Tag:
        """
        Method to provide table rows of proxies from HTML source.
        Good candidate for the overriding.

        :see parse_table_tr_to_proxy
        """
        return soup.body.find('table', attrs={'class':'list-proxy'}).find_all('tr')


    def parse_table_tr_to_proxy(self, tr: Tag) -> Proxy:
        """
        Method to parse table row to Proxy.
        Good candidate for the overriding.
        :param tr: Table row
        """
        tds = tr.find_all('td')
        return Proxy(tds[0].text, tds[1].text, tds[2].text.lower())