---
layout: page
title: 01. Scale from zero to millions of users
---

# Scale from zero to millions of users


# Table of Contents

1.  [Single server setup](#org5dff10e)
2.  [Database](#org1383a1b)
    1.  [Which database to use?](#org610bc68)
3.  [Vertical vs. Horizontal Scaling](#org5236169)
4.  [Load Balancer](#org0a5eba6)
5.  [Database Replication](#orgb86136e)
6.  [Cache](#org1af5624)
    1.  [Cache Tier](#org5ecd7b4)
    2.  [Considerations for Using Cache](#orge0cf685)
7.  [Content Delivery Network (CDN)](#orgea02771)
    1.  [Considerations for Using a CDN](#org05a7a28)
8.  [Stateless Web Tier](#org3881415)
    1.  [Stateful Architecture](#orgdd0c3c5)
    2.  [Stateless Architecture](#org3e42a81)
9.  [Data centre](#org8ef9c3d)
    1.  [Technical Challenges](#org3429257)
10. [Message Queue](#org53cf982)
11. [Logging, Metrics, Automation](#org75f7d3b)
12. [Database Scaling](#orgc2a7bfe)
    1.  [Considerations for Sharding](#org8e8d90d)
13. [Millions and beyond](#org02fad6d)



<a id="org5dff10e"></a>

# Single server setup

Everything is running on a single server.

![img](/assets/img/1.single-server.png "Single Server Setup")

1.  Users access websites through domain names. DNS (Domain Name System) is a paid service provided by 3rd parties and not hosted by our servers.
2.  IP address is returned to the browser or mobile app.
3.  Once the IP address is obtained, HTTP requests are sent directly to the web server.
4.  The web server returns HTML pages or JSON response for rendering.

The traffic comes from two sources: web application and mobile application.

-   Web application: uses combination of server-side languages (Java, Python, etc.) to handle business logic, storage, etc., and client-side languages (HTML, JavaScript, etc.) for presentation.
-   Mobile application: HTTP protocol is the communication protocol between the app and the server. JSON (JavaScript Object Notation) is commonly used API response format to transfer data due to its simplicity.


<a id="org1383a1b"></a>

# Database

With the growth of the user base, one server is not enough. We need more servers. one for web/mobile traffic, and the other for the database.

Separating web/mobile traffic (web tier) and database (data tier) servers allows them to be scaled independently.

![img](/assets/img/1.database.png "+ Database")


<a id="org610bc68"></a>

## [Which database to use](20250711090424-should_you_go_beyond_relational_databases.md)?

-   Relational databases (RDBMS)
    -   MySQL, Oracle database, PostgreSQL, etc.
    -   Join operations using SQL across different tables.
-   Non-Relational databases (NoSQL)
    -   CouchDB, Neo4j, Cassandra, HBase, Amazon DynamoDB, etc.
    -   Four categories
        -   Key-value stores
        -   Graph stores
        -   Column stores
        -   Document stores
    -   Join operations are not supported

For most cases, relation databases are the best option, because they have been around for over 40 years and historically they have worked well (boring, stable). However, if relation databases are not suitable for specific use cases, it is critical to explore beyond relation database. Non-relational databases might be the right choice if:

-   Application requires **super-low latency**.
-   Data are **unstructured**, or do not have any **relation data**.
-   Only need to **serialise/deserialise** data (JSON, XML, YAML, etc.)
-   Need to store a **massive amount** of data


<a id="org5236169"></a>

# Vertical vs. Horizontal Scaling

-   Vertical (scale up)
    -   Adding more power (CPU, RAM, etc.)
    -   When low traffic
    -   Hard limit: impossible to add unlimited CPU/RAM to a single server
    -   **Impossible to have failover and redundancy**. If one server goes down, the whole web/app goes down with it completely.
-   Horizontal (scale out)
    -   Adding more servers into resource pool
    -   More desirable for large scale applications

In the previous design, users are connected to the web server directly. Users will unable to access the website if the web server is offline. In another scenario, if many users access the web server simultaneously and it reaches the web server&rsquo;s load limit, users generally experience slower response or fail to connect to the server. A **load balancer** is the best technique to address these problems.


<a id="org0a5eba6"></a>

# Load Balancer

A load balancer evenly distributes incoming traffic among web servers that are defined in a load-balanced set.

![img](/assets/img/1.load-balancer.png "Load balancer")

1.  Users connect to DNS.
2.  DNS will return the public IP of the load balancer.
3.  Users connect to the load balancer directly. (Web servers are unreachable directly by clients anymore)
4.  The load balancer communicates with web servers through private IPs.

After a load balancer and a second web server are added, we successfully solved no failover issue and improved the availability of the web tier.

-   If one server goes offline, all the traffic will be routed to another server. This prevents the website from going offline. We will also add a new healthy web server to the server pool to balance the load.
-   If the website traffic grows rapidly, and two servers are not enough to handle the traffic, the load balancer can handle this problem **gracefully**. We only need to add more servers to the web server pool, and the load balancer will automatically starts to send requests to them.

However, the current design has one database, so it does not support failover and redundancy for the data tier. **Database replication** is a common technique to address these problems.


<a id="orgb86136e"></a>

# Database Replication

Database replication can be used in many database management systems, usually with a master/slave relationship between the original (master) and the copies (slaves).

-   A master database
    -   Only support write operations
    -   All the data-modifying operations (insert, delete, update) must be sent to the master
-   A slave database
    -   Get copies of the data from the master
    -   Only support read operations

Most applications require a much higher ratio of reads to writes; thus, the number of slave databases in a system is usually larger than the number of master.

![img](/assets/img/1.db-replication.png "Replication")

-   **Better performance**: All writes and updates happen in master nodes; whereas, read operations are distributed across slave nodes. This allows more queries to be processed in parallel.
-   **Reliability**: If one of the database servers is destroyed by a natural disaster such as typhoon or an earthquake, data is still preserved. Do not need to worry about data loss because data is replicated across multiple locations.
-   **High availability**: By replicating data across different locations, website remains in operation even if a database is offline as we can access data stored in another database server.

After data replication, we successfully solved the failover and redundancy issues for the data tier.

-   If only one slave database is available and it goes offline, read operations will be directed to the master database temporarily. As soon as the issue is found, a new slave database will replace the old one. In case multiple slave databases are available, read operations are redirected to other healthy slave database. A new database server will replace the old one.
-   If the master database goes offline, a slave database will be **promoted** to be the new master. All the database operations will be temporarily executed on the new master. A new slave will replace the old one for data replication immediately. In production systems, promoting a new master is more complicated, *as the data in slave might not be up to date*. This missing data needs to be updated by running **data recovery scripts**. Although some other replication methods like multi-masters and circular replication could help, those setups are more complicated.

Now the design is like below.

![img](/assets/img/1.with-replication.png "Design with data replication")

1.  A user gets the public IP address of the load balancer from DNS.
2.  A user connects to the load balancer with this IP address.
3.  The HTTP request is routed to either server 1 or server 2.
4.  A web server reads user data from a slave database.
5.  A web server routes any data-modifying operations (write, update, delete) to the master database.

Now, we have a solid understanding of the web and data tiers.

It is time to improve the load/response time. This can be done by adding a cache layer, and shifting static content (JavaScript/CSS/image/video files) to the content delivery network (CDN).


<a id="org1af5624"></a>

# Cache

A cache is a temporary storage area that stores the result of expensive responses or frequently accessed data in memory so that subsequent requests are served more quickly.

Every time a new web page loads, one or more database calls are executed to fetch data. Thus, the application performance is greatly affected by calling the database repeatedly. The cache can mitigate this problem.


<a id="org5ecd7b4"></a>

## Cache Tier

-   Better system performance
-   Ability to reduce database workloads
-   Ability to scale the cache tier independently

After receiving a request, (read-through cache)

1.  Checks if the cache has the available response.
2.  If it has, it sends data back to the client.
3.  If not, it queries the database, stores the response in cache, and sends it back to the client.

Other cache strategies are available depending on the data type, size, and access patterns.


<a id="orge0cf685"></a>

## Considerations for Using Cache

-   **Decide when to use cache**.
    -   Data is read frequently, but modified infrequently.
    -   Cached data is stored in volatile memory -> not ideal for persisting data.
    -   Important data should be saved in persistent data stores.
    -   [Caching Strategies and How to Choose the Right One](20250711100232-caching_strategies_and_how_to_choose_the_right_one.md)
-   **Expiration policy**.
    -   If there is no expiration policy, cached data will be stored in memory permanently -> cause problems.
    -   Too short -> cause the system to reload data from the database too frequently.
    -   Too long -> data can become stale.
-   **Consistency**.
    -   Keep data store and ache in sync.
    -   Inconsistency can happen because data-modifying operations on the data store and cache are not in single transaction.
    -   When scaling across multiple regions, maintaining consistency between the data store and cache is challenging!
    -   [Scaling Memcache at Facebook](20250710143856-scaling_memcache_at_facebook.md)
-   **Mitigating failures**.
    -   A single cache = SPOF (Single Point of Failure)
    -   Multiple cache servers across different data centres are recommended to avoid SPOF.
    -   overprovision the required memory by certain percentages -> provides a buffer as the memory usage increases.
-   **Eviction policy**.
    -   Once the cache got full, any requests to add items to the cache might cause existing items to be removed.
    -   LRU (Least-recently-used) is the most popular eviction policy.
    -   LFU (Least-frequently used)
    -   FIFO (First in First out)


<a id="orgea02771"></a>

# Content Delivery Network (CDN)

A CDN is a network of **geographically dispersed** servers used to deliver static content.

When a user visits a website, a CDN server closest to the user will deliver static content.

1.  User A tries to get `image.png` by using an image URL (provided by the CDN provider), e.g., ![img](https://mysite.cloudfront.net/logo.jpg), or ![img](https:/mysite.akamai.com/image-manager/img/logo.jpg).
2.  If the CDN server does not have the image in the cache, the CDN server requests the file from the origin, which can be a web server or online storage like Amazon S3.
3.  The origin returns `image.png` to the CDN server, which includes optional HTTP header TTL(Time-to-Live) which describes how long the image is cached.
4.  The CDN server caches the image and returns it to User A. The image remains cached in the CDN until the TTL expires.
5.  User B sends a request to get the same image.
6.  The image is returned from the cache as long as the TTL has not expired.


<a id="org05a7a28"></a>

## Considerations for Using a CDN

-   **Cost**
    -   CDN is third party service.
    -   It will be charged fro data transfers in/out of the CDN.
    -   Caching infrequently used assets costs meaninglessly, so careful consideration is needed.
-   **Setting an appropriate cache expiry**
    -   For time-sensitive content, setting a cache expiry time is important.
    -   Neither too long nor too short.
-   **CDN fallback**
    -   Decide how website copes with CDN failure. e.g., temporary CDN outage.
    -   Client should detect the problem and request resources from the origin.
-   **Invalidating files**
    -   Invalidate the CDN object using APIs provided by CDN vendors.
    -   Use object versioning to serve a different version of the object. To version an object, you can add a parameter to the URL, such as a version number.

![img](/assets/img/1.cache-and-cdn.png "Cache and CDN")


<a id="org3881415"></a>

# Stateless Web Tier

Now it is time to consider scaling the web tier horizontally.
We need to move state (e.g., user session data) out of the web tier.
A good practice is to store state data in the persistent storage or NoSQL. Each web server ni the cluster can access state data from databases.


<a id="orgdd0c3c5"></a>

## Stateful Architecture

Stateful: remembers client data (state) from one request to the next.

-   Every request from the same client **must be routed to the same server**.
-   Can be done with sticky sessions in most load balancers, with overhead.
-   Adding or removing servers is much more difficult.
-   Challenging to handle failures.


<a id="org3e42a81"></a>

## Stateless Architecture

Stateless: keeps no state information.

-   HTTP requests from users can be sent to **any** web servers.
-   Web servers fetch state data from a shared data store.
-   State data is stored in shared data store and kept out of web servers.
-   Simpler, more robust, scalable.

![img](/assets/img/1.stateless.png "stateless")

-   Moved session data out of the web tier, and store them in the persistent data store.
-   The shared data store could be a relational database, Memcached/Redis, NoSQL, etc.
-   NoSQL is chosen, because it is easy to scale.
-   Auto-scaling means adding or removing web servers automatically based on the traffic load.


<a id="org8ef9c3d"></a>

# Data centre

Now the service grows rapidly and attracts a significant number of users **internationally**. To improve availability and provides a better user experience across wider geographical areas, supporting multiple data centres is crucial.

-   Users are geoDNS-routed, or geo-routed, to the closest data centre, with a split traffic of x% in US-East and (100-x)% in US-West.
-   geoDNS is a DNS service that allows domain names to be resolved to IP addresses based on the location of the user.

![img](/assets/img/1.geo-routed.png "geo-routed")

In the event of any significant data centre outage, we direct all traffic to a healthy data centre.


<a id="org3429257"></a>

## Technical Challenges

-   **Traffic redirection**.
    -   Effective tools are needed to direct traffic to the correct data centre.
    -   GenDNS can be used to direct traffic to the nearest data centre depending on where a user is located.
-   **Data synchronisation**.
    -   Users from different regions could use different local databases or caches.
    -   In failover cases, traffic might be routed to a data centre where data is unavailable or stale.
    -   A common strategy is to replicate data across multiple data centres.
-   **Test and deployment**.
    -   It is important to test productions at different locations.
    -   Automated deployment tools are vital to keep services consistent through all the data centres.


<a id="org53cf982"></a>

# Message Queue

To further scale our system, we need to decouple different components of the system so they can be scaled independently.

A message queue is a durable component, stored in memory, that supports asynchronous communication. It serves as a buffer and distributes asynchronous requests. The basic architecture of a message queue is simple. Input services, called producers/publishers, create messages, and publish them to a message queue. Other services or servers, called consumers/subscribers, connect to the queue, and perform actions defined by the messages.

![img](/assets/img/1.message-queue.png "message queue")

Decoupling makes the message queue a preferred architecture for building a scalable and reliable application. With the message queue, the producer can post a message to the queue when the consumer is unavailable to process it. The consumer can read messages from the queue even when the producer is unavailable.

The producer and the consumer can be scaled independently. When the size of the queue becomes larger, more workers are added to reduce the processing time. If the queue is empty most of the time, the number of workers can be reduced.


<a id="org75f7d3b"></a>

# Logging, Metrics, Automation

When working with a small website that runs on a few servers, logging, metrics, and automation support are good practices but not a necessity. However, now that your site has grown to serve a large business, investing in those tools is essential.

-   **Logging**
    -   Monitoring error logs.
    -   Helps to identify errors and problems in the system.
    -   Per sever level, or use tools to aggregate them to a centralised service for easy search and viewing.
-   **Metrics**
    -   Collecting different types of metrics helps us to gain business insights and understand the health status of the system.
    -   Host level: CPU, memory, I/O, etc.
    -   Aggregated level: The entire performance of each tier, especially data tier or cache tier, etc.
    -   Key business metrics: daily/monthly active users (DAU/MAU), retention, revenue, etc.
-   **Automation**
    -   Improve productivity.
    -   Continuous integration is a good practice, in which each node check-in is verified through automation allowing teams to detect problems early.
    -   Automating the build, test, deployment process, etc. could improve productivity significantly.

![img](/assets/img/1.message-queue-and-tools.png "message queue and tools")


<a id="orgc2a7bfe"></a>

# Database Scaling

As the **data** grows every day, databases get more overloaded. It is time to scale the data tier.

**Sharding** separates large databases into smaller, more easily managed parts called **shards**. Each shard shares the same schema, though the actual data on each shard is unique to the shard.


<a id="org8e8d90d"></a>

## Considerations for Sharding

-   **Sharding strategy**.
    -   The most important factor is the choice of the sharding key (partition key).
    -   A sharding key consists of one or more columns that determine how data is distributed.
    -   A sharding key allows you to retrieve and modify data efficiently by routing database queries to the correct database.
    -   **Choose a key that evenly distribute data**
-   **Resharding data**.
    -   Resharding is needed when
        -   A single shard could no longer hold more data, due the rapid growth
        -   Certain shards might experience shard exhaustion faster than others, due to uneven data distribution.
    -   It requires updating the sharding function and moving data around.
    -   [Consistent hashing](20250709143432-design_consistent_hashing.md) is a commonly used technique to solve this problem.
-   **Celebrity problem**.
    -   Also called a hotspot key problem.
    -   Excessive access to a specific shard could cause server overload. e.g., Justin Bieber.
    -   May need to allocate a shard for each celebrity, and this each shard might even require further partitions.
-   **Join and de-normalisation**.
    -   Once a database has been sharded across multiple databases, it is hard to perform join operations across database shards.
    -   A common workaround is to de-normalise the database so that queries can be performed in a single table.

![img](/assets/img/1.shard.png "sharded")


<a id="org02fad6d"></a>

# Millions and beyond

Scaling a system is an iterative process. More fine-tuning and new strategies are needed to scale beyond millions of users. We might need to optimise the system and decouple the system to even smaller services.

In summary, how we scale our system to support millions of users:

-   Keep web tier stateless.
-   Build redundancy at every tier.
-   Cache data as much as you can.
-   Support multiple data centres.
-   Host static assets in CDN.
-   Scale your data tier by sharding.
-   Split tiers into individual services.
-   Monitor the system, and use automation tools.

