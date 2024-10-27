import os
import pathlib

import requests
from bs4 import BeautifulSoup, Tag, PageElement


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

        self.run()

    def run(self):
        self.parse_pages(self.urls)
        self.finalize()

    def filename(self, suffix: str) -> str:
        return os.path.join(self.basedir, f'{self.name}.{suffix}.txt')


    def parse_pages(self, urls: dict[str,str]) -> None:
        """
        Main method to start parsing
        :return:
        """
        # for idx,(file_type, url) in enumerate(urls.items()):
        #     print(f'{idx}/{len(urls)-1}) Processing page parsing {file_type} from {url}')
        #     self.process_page(file_type, url)



        from multiprocessing.pool import ThreadPool

        lst = [(idx, file_type, url) for idx, (file_type, url) in enumerate(urls.items())]

        with ThreadPool(os.cpu_count() * 5) as pool:
            list(pool.map_async(lambda tpl: print(f'{tpl[0]}/{len(urls)-1}) Processing page parsing {tpl[1]} from {tpl[2]}') or self.process_page(tpl[1], tpl[2]), lst).get())


    def process_page(self, file_type, url) -> str:
        soup = self._download_page(url)
        proxy_list: ProxyList = self.get_proxy_list(soup)
        with open(self.filename(file_type), 'w') as file:
            for proxy in proxy_list:
                file.write(str(proxy) + '\n')

        # Recursively parse links if so
        self.parse_pages(self.get_other_page_links(soup, file_type, url))
        return url


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
            if self.is_skip_tr(tr):
                continue

            proxy = self.parse_table_tr_to_proxy(tr)
            proxy_list.add(proxy)

        return proxy_list


    def get_other_page_links(self, soup: BeautifulSoup, file_type: str, url: str) -> dict[str,str]:
        """
        Possibly a useful method to get other links from HTML source. For example, walk by pages if there present a navigation
        Good candidate for the overriding.
        """
        return {}


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


    @staticmethod
    def is_skip_tr(tr: Tag) -> bool:
        return tr.td is None or tr.td.get('colspan', False)

    def finalize(self):
        """
        Method called after all parsing done. For example for temporary files cleanup
        Good candidate for the overriding.
        :return:
        """
        print('Done')