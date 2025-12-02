---
layout: page
title: 09. Design a web crawler
---
# Design a web crawler

# Table of Contents

1.  [Step 1 - Understand the problem and establish design scope](#orge1297fd)
2.  [Step 2 - Propose high-level design and get buy-in](#orgbf69b71)
    1.  [Web crawler workflow](#orgd68c9f5)
3.  [Step 3 - Design deep dive](#orgf95987a)
    1.  [DFS vs. BFS](#org008fee2)
    2.  [URL frontier](#org1652638)
        1.  [Politeness](#org7f7c38f)
        2.  [Priority](#org2f358ca)
        3.  [Freshness](#orgf3903ca)
        4.  [Storage for URL frontier](#orgc5f7e77)
    3.  [HTML downloader](#org0947a38)
        1.  [Robots.txt](#org4e17181)
        2.  [Performance optimisation](#orgc0e3b53)
    4.  [Robustness](#org827846b)
    5.  [Extensibility](#org3749506)
    6.  [Detect and avoid problematic content](#orga84869a)
4.  [Step 4 - Wrap Up](#org9941b7a)

A web crawler is known as a *robot* or *spider*. It is widely used by search engines to discover new or updated content on the web. Content can be a web page, an image, a video, a PDF file, etc. A web crawler starts by collecting a few web pages and then follows links on those pages to collect new content.

A crawler is used for many purposes:

-   **Search engine indexing**: This is the most common use case. A crawler collects web pages to create a local index for search engines.
-   **Web archiving**: This is the process of collecting information from the web to preserve data for future uses. For instance, many national libraries run crawlers to archive web sites. Notable examples are the US Library of Congress, and the EU web archive.
-   **Web mining**: The explosive growth of the web presents an unprecedented opportunity for data mining. Web mining helps to discover useful knowledge from the Internet. For example, top financial firms use crawlers to download shareholder meetings and annual reports to learn key company initiaitives.
-   **Web monitoring**: The crawlers help to monitor copyright and trademark infringements over the Internet. For example, Digimarc utilises crawlers to discover pirated works and reports.

The complexity of developing a web crawler depends on the scale we intend to support. It could be either a small school project, which takes only a few hours to complete or a gigantic project that requires continuous improvement from a dedicated engineering team.


<a id="orge1297fd"></a>

# Step 1 - Understand the problem and establish design scope

The basic algorithm is simple.

1.  Given a set of URLs, download all the web pages addressed by the URLs.
2.  Extract URLs from these web pages.
3.  Add new URLs to the list of URLs to be downloaded. Repeat.

Does a web crawler work truly as simple as this basic algorithm? Not really. Designing a vastly scalable web crawler is an extremely complex task. It is unlikely for anyone to design a massive web crawler within the interview duration.

Some useful questions are

-   &ldquo;What is the main purpose of the crawler?&rdquo;
-   &ldquo;How many web pages does the web crawler collect per month/day/hour?&rdquo;
-   &ldquo;What content types are included? HTML only or other content types such as PDFs and images as well?&rdquo;
-   &ldquo;Shall we consider  newly added or edited web pages?&rdquo;
-   &ldquo;Do we need to store HTML pages crawled from the web? If so, how long?&rdquo;
-   &ldquo;How do we handle web pages with duplicate content?&rdquo;

Our requirements are:

-   It is for search engine indexing.
-   1 billion pages per month.
    -   QPS: 1,000,000,000 / 30 days / 24 hours / 3600 seconds = ~400 pages per second.
    -   Peak QPS = 2 \* QPS = 800
    -   Assume the average web page size is 500KB, 1,000,000,000 x 500KB = 500 TB storage per month x 12 month x 5 years = 30 PB.
-   HTML only.
-   Should consider newly added or edited pages as well.
-   Store HTML up to 5 years.
-   Pages with duplicate content should be ignored.

It is important to note down the following characteristics of a good web crawler:

-   **Scalability**: The web is very large. There are billions of web pages out there. Web crawling should be extremely efficient using parallelisation.
-   **Robustness**: The web is full of traps. Bad HTML, unresponsive servers, crashes, malicious links, etc. are all common. The crawler must be handle all those edge cases.
-   **Politeness**: The crawler should not make too many requests to a website within a short time interval. (Could be perceived as DDoS attack)
-   **Extensiblity**: The system is flexible so that minimal changes are needed to support new content types, e.g., image files. We should not need to redesign the entire system.


<a id="orgbf69b71"></a>

# Step 2 - Propose high-level design and get buy-in

![img](/assets/img/web-crawler-high-level.png "Web crawler high level")

-   **Seed URLs**
    -   A web crawler uses seed URLs as a starting point for the crawl process.
    -   Need to be creative in selecting seed URLs. A good seed serves as a good starting point that a crawler can utilise to traverse as many links as possible.
    -   The general strategy is to dived the entire URL space into smaller ones.
        -   Locality: different countries may have different popular websites.
        -   Topics: shopping, sports, healthcare, etc.
    -   Open-ended question, so there is no perfect answer, just think out loud.
-   **URL Frontier**
    -   The component that stores URLs to be downloaded.
    -   FIFO.
-   **HTML Downloader**
    -   Download the target page.
    -   Need to handle the edge case - e.g., timeout
-   **DNS Resolver**
    -   A URL must be translated into an IP address.
    -   HTML Downloader calls the DNS Resolver to get the corresponding IP address for the URL.
-   **Content Parser**
    -   More like a content validator.
    -   Malformed web pages could provoke problems and waste storage space.
-   **Content Seen?**
    -   29% of the web pages are duplicate!
    -   Hash
-   **Content Storage**
    -   The choice of storage system depends on factors such as data type, data size, access frequency, life span, etc.
    -   Most of the content is stored on disk, because the data set is too big to fit in memory.
    -   Popular content is kept in memory to reduce latency.
-   **URL Extractor**
    -   Extract links from HTML pages.
-   **URL Filter**
    -   Exclude certain content types, file extensions, error links, and &ldquo;blacklisted&rdquo; sites.
-   **URL Seen?**
    -   Check whether it visited before or already in the Frontier.
    -   [Bloom filter](20250213210156-bloom_filters.md)
-   **URL Storage**
    -   Stores already visited URLs.


<a id="orgd68c9f5"></a>

## Web crawler workflow

1.  Add seed URLs to the URL frontier.
2.  HTML downloader fetches a list of URLs from frontier.
3.  Gets IP addresses of URLs from DNS resolver and starts downloading.
4.  Content parser validates HTML pages and checks if pages are malformed.
5.  After content is validated, it is passed to &ldquo;Content Seen?&rdquo; component.
6.  &ldquo;Content Seen?&rdquo; component checks if a HTML page is already in the storage.
    1.  If it is, current page is discarded.
    2.  If not, the content is passed to link extractor.
7.  Link extractor extracts links from the HTML page.
8.  Extracted links are passed to the URL filter.
9.  After links are filtered, they are passed to the &ldquo;URL Seen?&rdquo; component.
10. &ldquo;URL Seen?&rdquo; component checks if a URL is already in the storage.
    1.  If it is, then nothing needs to be done.
    2.  If not, it is added to the URL frontier.


<a id="orgf95987a"></a>

# Step 3 - Design deep dive


<a id="org008fee2"></a>

## DFS vs. BFS

-   Web = a directed graph where pages are nodes, and hyperlinks are edges.
-   The crawl process = traversing a directed graph.
-   We&rsquo;re not sure how deep is the edges, so DFS is not a good choice.
-   BFS!
    -   Most links from the same page are **linked back to the same host** -> could be very &ldquo;impolite,&rdquo; i.e., too many requests for the same host.
    -   Not every page has the same level of quality and importance; priority by e.g., page ranks, traffic, update frequency, etc.


<a id="org1652638"></a>

## URL frontier

-   Ensures politeness, prioritisation, and freshness.


<a id="org7f7c38f"></a>

### Politeness

-   Avoid sending too many requests to the same hosting server within a short period.
-   Maintaining a mapping from website host names to download worker threads. Each downloader thread has a separate FIFO queue and only downloads URLs obtained from that queue.

![img](/assets/img/web-crawler-frontier.png "Design that manages politeness")

-   Queue Router: ensures that each queue only contains URLs from the same host.
-   Mapping table: maps each host to a queue.
-   FIFO queues: each queue contains URLs from the same host.
-   (Back) Queue Selector: each worker thread is mapped to a FIFO queue, and it only downloads URLs from that queue.
-   Worker thread: downloads web pages one by one from the same host.


<a id="org2f358ca"></a>

### Priority

-   Usefulness measured by PageRank, traffic, update frequency, etc.
-   Prioritiser: takes URLs, and computes the priorities.
    -   Each queue has an assigned priority. Queues with high priority are selected with higher probability.
-   (Front) Queue Selector: randomly choose a queue with a bias towards queues with higher priority (probability).

![img](/assets/img/crawler-frontier-design.png "Frontier design")

Now, we have two modules:

-   Front queues: manage prioritisation
-   Back queues: manage politeness


<a id="orgf3903ca"></a>

### Freshness

-   Periodically re-crawl downloaded pages to keep data set fresh.
-   Re-crawl based on web page&rsquo;s update history (average update period)?
-   Re-crawl based on high priority URLs more frequently?


<a id="orgc5f7e77"></a>

### Storage for URL frontier

-   In real-world, the number of URLs in frontier could be hundreds of millions.
-   Everything in memory is impossible, nor everything in disk is slow.
-   Hybrid approach
    -   The majority are stored on disk.
    -   Keep buffers in memory for queue operations.


<a id="org0947a38"></a>

## HTML downloader


<a id="org4e17181"></a>

### Robots.txt

-   Robots Exclusion Protocol
-   A standard used by websites to communicate with crawlers.
    -   What pages are allowed
-   Before crawl the site, we should check this and follow the rules.

    User-agent: *
    Disallow: /dp/product-availability/
    Disallow: /dp/rate-this-item/
    Disallow: /exec/obidos/account-access-login
    Disallow: /exec/obidos/change-style
    ...
    Allow: /gp/dmusic/promotions/PrimeMusic
    Allow: /gp/dmusic/promotions/AmazonMusicUnlimited
    ...
    User-agent: GPTBot
    Disallow: /

    User-agent: CCBot
    Disallow: /

    User-Agent: PerplexityBot
    Disallow: /

    User-agent: Google-Extended
    Disallow: /

    User-agent: GoogleAgent-Mariner
    Disallow: /

    User-agent: GoogleAgent-Shopping
    Disallow: /

    User-agent: ClaudeBot
    Disallow: /


<a id="orgc0e3b53"></a>

### Performance optimisation

-   **Distributed crawl**
    -   Crawl jobs are distributed into multiple servers.
    -   Each server runs multiple threads.
-   **Cache DNS Resolver**
    -   DNS Resolver is a bottleneck for crawler, because DNS requests might take time due to the synchronous nature of many DNS interfaces.
    -   10-200ms
    -   Once a request to DNS is carried out by a crawler thread, other threads are *blocked* until the first request is completed.
    -   Keep our own DNS cache to avoid calling DNS frequently is an effective optimisation.
-   **Locality**
    -   Distribute crawl servers *geographically*.
    -   The closer the server is, the faster the speed.
    -   Locality can be applied to most of the system components, e.g., crawl servers, cache, queue, storage, etc.
-   **(Short) timeout**
    -   Some servers are slow or not respond at all.


<a id="org827846b"></a>

## Robustness

-   **Consistent hashing**
    -   This helps to distribute loads among downloaders.
    -   A new downloader server can be added/removed.
-   **Save states and data**
    -   To guard against failures, save states and data into a storage.
    -   A disrupted crawl can be restarted easily by loading these saved info.
-   **Exception handling**
    -   Graceful exception handling not to crash the whole system.
-   **Data validation**


<a id="org3749506"></a>

## Extensibility

-   Flexible enough to support new content types.

![img](/assets/img/extension-module.png "new modules")

-   PNG Downloader: plugged-in to download PNG files.
-   Web Monitor: monitor the web and prevent *copyright* and trademark infringements.


<a id="orga84869a"></a>

## Detect and avoid problematic content

-   **Redundant content**
    -   Hash, checksums
-   **Spider traps**
    -   A web page that causes a crawler in an infinite loop.
    -   Set a maximal length for URLs.
    -   Manually identify a spider trap and exclude them or create a new filter rule.
-   **Data noise**
    -   no/little value, e.g., advertisements, code snippets, spam, etc.


<a id="org9941b7a"></a>

# Step 4 - Wrap Up

Additional topics

-   **Server-side rendering**: Numerous websites use scripts like JavaScript, AJAX, React, etc. to generate links on the fly. Directly downloading and parsing pages not be able to retrieve these dynamically generated links. We can perform server-side rendering first before parsing a page.
-   **Filter out unwanted pages**: anti-spam component is beneficial in filtering out low quality and spam pages.
-   **Database replication and sharding**
-   **Horizontal scaling**: keep servers stateless
-   **Availability, consistency, reliability**
-   **Analytics**
