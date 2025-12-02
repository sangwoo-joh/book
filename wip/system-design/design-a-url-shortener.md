---
layout: page
title: 08. Design a URL shortener
---

# Design a URL shortener


# Table of Contents

1.  [Step 1 - Understand the problem and establish design scope](#org333599a)
2.  [Step 2 - Propose high-level design and get buy-in](#org3ee0006)
    1.  [API Endpoints](#orgd970feb)
    2.  [URL redirecting](#org6e66732)
    3.  [URL shortening](#orgeb6f0b2)
3.  [Step 3 - Design deep dive](#orgb1cf1de)
    1.  [Data model](#orgd4ddff7)
    2.  [Hash function](#org86dc930)
        1.  [Hash value length](#org528475e)
        2.  [Hash + collision resolution](#org452c86a)
        3.  [Base 62 conversion](#orgcc54e72)
        4.  [URL shortening deep dive](#org2a8108d)
        5.  [URL redirecting deep dive](#orgf485558)
4.  [Step 4 - Wrap up](#org079149c)



<a id="org333599a"></a>

# Step 1 - Understand the problem and establish design scope

-   Creates an alias with shorter length, and redirects to the original URL.
-   100 million URLs per day -> 1160 write operation per second.
-   As short as possible.
-   alpha-numeric
-   Shortened URLs cannot be deleted or updated.
-   Assuming ratio of read operation to write operation is 10:1, 11660 read operation per second.
-   Assuming the URL shortener service will run for 10 years, this means we must support 100 million \* 365 \* 10 = 365 billion records.
-   Assuming average URL length is 100.
-   Storage requirement over 10 years: 365 billion \* 100 bytes \* 10 years = 365 TB.

Some questions:

-   &ldquo;Can you give an example of how a URL shortener work?&rdquo;
-   &ldquo;What is the traffic volume?&rdquo;
-   &ldquo;How long is the shortened URL?&rdquo;
-   &ldquo;What characters are allowed in the shortened URL?&rdquo;
-   &ldquo;Can shortened URLs be deleted or updated?&rdquo;


<a id="org3ee0006"></a>

# Step 2 - Propose high-level design and get buy-in


<a id="orgd970feb"></a>

## API Endpoints

-   API endpoints facilitates (가능하게 하다, 용이하게 하다) the communication between clients and servers.
-   POST `api/v1/data/shorten`
    -   parameter: `{longURL: long URL String}`
    -   return: `shortURL`
-   GET `api/v1/shortURL`
    -   return: `longURL` for HTTP redirection


<a id="org6e66732"></a>

## URL redirecting

-   Redirection methods depend on the priority.
-   **HTTP 301 redirect**
    -   Permanently moved. The browser caches the response.
    -   Reduce the server load.
-   **HTTP 302 redirect**
    -   Temporarily moved. Not cached.
    -   Analytics is important.


<a id="orgeb6f0b2"></a>

## URL shortening

-   Everything is stored in a hash table.
-   To find out the most proper hash function.


<a id="orgb1cf1de"></a>

# Step 3 - Design deep dive


<a id="orgd4ddff7"></a>

## Data model

A hash table that stores everything is not feasible, as memory resources are limited.
A better option is to store `<shortURL, longURL>` mapping in a relational database.


<a id="org86dc930"></a>

## Hash function


<a id="org528475e"></a>

### Hash value length

-   Alpha-numeric, [0-9|a-z|A-Z], thus 10+26+26=62 possible characters.
-   To find out n that satisfies $62^n \ge 365B$, n is around 7.


<a id="org452c86a"></a>

### Hash + collision resolution

-   A straightforward solution is to use well-known hash functions like CRC32, MD5, or SHA-1.
-   To resolve collision, the first approach is to collect the first 7 characters of a hash value, and then recursively append a new pre-defined string until no more collision is discovered.
-   It is expensive to query the database to check if a `shortURL` exists for every request.
    -   Bloom filter can improve performance.


<a id="orgcc54e72"></a>

### Base 62 conversion

-   Base conversion helps to convert the same number between its different **number representation systems**.
-   Base 62 conversion is used as there are 62 possible characters for hash value.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Hash + collision resolution</th>
<th scope="col" class="org-left">Base 62 conversion</th>
</tr>
</thead>
<tbody>
<tr>
<td class="org-left">Fixed short URL length.</td>
<td class="org-left">The short URL length is not fixed.</td>
</tr>

<tr>
<td class="org-left">Does not need a unique ID generator.</td>
<td class="org-left">This option depends on a unique ID generator.</td>
</tr>

<tr>
<td class="org-left">Collision is possible, and must be resolved.</td>
<td class="org-left">Collision is impossible. ID is unique.</td>
</tr>

<tr>
<td class="org-left">Impossible to expect the next available short URL.</td>
<td class="org-left">Easy to figure out, can be a security concern.</td>
</tr>
</tbody>
</table>


<a id="org2a8108d"></a>

### URL shortening deep dive

We choose Base 62 conversion for **unique ID** (not the longURL itself!)

1.  Get longURL as input.
2.  The system checks if the longURL is in the database.
3.  If it is, it means the longURL was converted to shortURL before, so fetch the shortURL from the database and return it to client.
4.  If not, the longURL is new; A new unique ID (primary key) is generated by the [unique ID generator](20250709143450-design_a_unique_id_generator_in_distributed_systems.md).
5.  Convert ID to shortURL with base 62 conversion.
6.  Create a new pair and save it into the database.

즉, 입력으로 들어온 longURL이랑 상관없이 이전 시스템 디자인으로 만든 유니크 아이디 생성기로 64비트 정수 아이디를 만든 다음에 이걸 베이스 62 변환으로 바꿔서 입력을 줄인다. 기발한 테크닉이다.


<a id="orgf485558"></a>

### URL redirecting deep dive

1.  A user clicks a short URL link.
2.  The load balancer forwards the request to web servers.
3.  If a shortURL is already in the cache, return the matching longURL directly.
4.  If a shortURL is not in the cache, fetch the longURL from the database and cache it. If the shortURL is not in the database, notice to the user that it is an invalid shortURL.
5.  The longURL is returned to the user.


<a id="org079149c"></a>

# Step 4 - Wrap up

Additional design topics:

-   Rate limiter: a potential security problem we could face is that malicious users send an overwhelmingly large number of URL shortening requests. Rate limiter helps to filter out requests based on IP addresses or other filtering rules.
-   Web server scaling: since the web tier is stateless, it is easy to scale the web tier by adding or removing servers.
-   Database scaling: database replication and sharding are common techniques.
-   Analytics: data is increasingly important for business success. Integrating an analytics solution to the URL shortener could help to answer important questions like how many people click on a link, when do they click, etc.
-   Availability, consistency, and reliability. These concepts are at the core of any large system&rsquo;s success.
