---
layout: page
title: 02. Back-of-the-envelope estimation
---

# Back-of-the-envelope estimation


# Table of Contents

1.  [Power of two](#org5419cbe)
2.  [Latency numbers](#org3cb16d4)
3.  [Availability numbers](#orgd02e4d3)
4.  [Example: Estimate Twitter QPS and Storage Requirements](#org3ca7c5e)
5.  [Tips](#orgd1534c6)

According to Jeff Dean,

> Back-of-the-envelope calculations are estimates you create using a combination of thought experiments and common performance numbers to get a good feel for which designs will meet your requirements.


<a id="org5419cbe"></a>

# Power of two

It is critical to know the data volume unit using the power of 2.
A byte is a sequence of 8 bits. An ASCII character uses one byte of memory.

-   $2^{10}$ = 1,000 (Thousand, 1KB)
-   $2^{20}$ = 1,000,000 (Million, 1MB)
-   $2^{30}$ = 1,000,000,000 (Billion, 1GB)
-   $2^{40}$ = 1,000,000,000,000 (Trillion, 1TB)
-   $2^{50}$ = 1,000,000,000,000,000 (Quadrillion, 1PB)


<a id="org3cb16d4"></a>

# Latency numbers

-   L1 Cache reference: 0.5 ns
-   Branch mispredict: 5 ns
-   L2 Cache reference: 7 ns
-   Mutex lock/unlock: 100 ns
-   Main memory reference: 100 ns
-   Compress 1KB with Zippy: 10,000 ns = 10 us
-   Send 2KB over 1GBPS network: 20,000 ns = 20 us
-   Read 1MB sequentially from memory: 250,000 ns = 250 us
-   Round trip within the same datacentre: 500,000 ns = 500 us
-   Disk seek: 10,000,000 ns = 10 ms
-   Read 1MB sequentially from the network: 10,000,000 ns = 10 ms
-   Read 1MB sequentially from disk: 30,000,000 ns = 30 ms
-   Send packet from California to Netherlands and back to California: 150,000,000 ns = 150 ms

Legend:

-   1 ns (nano second) = $10^{-9}$ seconds
-   1 us (micro second) = $10^{-6}$ seconds = 1,000 ns
-   1 ms (milli second) = $10^{-3}$ seconds = 1,000 us = 1,000,000 ns

Some insights are:

-   Memory is fast, but disk is horribly slow.
    -   Avoid disk seeks if possible.
-   Simple compression algorithms are quite fast.
    -   Thus, compress data before sending it over the network if possible.
-   Data centres are usually in different regions, and it takes time to send data between them.


<a id="orgd02e4d3"></a>

# Availability numbers

High availability is the ability of a system to be continuously operational for a desirably long period of time. High availability is measured as a percentage, with 100% means a service that has 0 downtime. Most services fall between 99% and 100%.

A Service Level Agreement (SLA) is a commonly used term for service providers. This is an agreement between you (the service provider) and your customer, and this agreement formally defines the level of uptime your service will deliver. Amazon, Google, Microsoft set their SLAs at 99.9% or above. Uptime is traditionally measured in nines. The more the nines, the better.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-right" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">Availability %</th>
<th scope="col" class="org-left">Downtime per day</th>
<th scope="col" class="org-left">Downtime per year</th>
</tr>
</thead>
<tbody>
<tr>
<td class="org-right">99%</td>
<td class="org-left">14.40 minutes</td>
<td class="org-left">3.65 days</td>
</tr>

<tr>
<td class="org-right">99.9%</td>
<td class="org-left">1.44 minutes</td>
<td class="org-left">8.77 hours</td>
</tr>

<tr>
<td class="org-right">99.99%</td>
<td class="org-left">8.62 seconds</td>
<td class="org-left">52.60 minutes</td>
</tr>

<tr>
<td class="org-right">99.999%</td>
<td class="org-left">864.00 ms</td>
<td class="org-left">5.26 minutes</td>
</tr>

<tr>
<td class="org-right">99.9999%</td>
<td class="org-left">86.40 ms</td>
<td class="org-left">31.56 seconds</td>
</tr>
</tbody>
</table>


<a id="org3ca7c5e"></a>

# Example: Estimate Twitter QPS and Storage Requirements

Please note the following numbers are for this exercise only as they are not real numbers from Twitter.

-   Assumptions:
    -   300 million monthly active users. (300M MAU)
    -   50% of users use Twitter daily.
    -   Users post 2 tweets per day on average.
    -   10% of tweets contain media.
    -   Data is stored for 5 years.
-   Estimations:
    -   QPS(Query per second)
        -   Daily active users (DAU) = 300 M \* 50% = 150 M
        -   Tweets QPS = 150 M \* 2 tweets / 24 hours / 2600 seconds = ~3500
        -   Peek QPS = 2 \* QPS = ~7,000
    -   Storage
        -   Average tweet size
            -   tweet id: 64B
            -   text: 140B
            -   media: 1MB
        -   Media storage: 150 M \* 2 \* 10% \* 1 MB = 30 TB per day
        -   5-year media storage: 30 TB \* 365 \* 5 = ~55 PB


<a id="orgd1534c6"></a>

# Tips

Back-of-the-envelope estimation is all about the process. Solving the problem is more important than obtaining correct results. Interviewers may test your problem-solving skills.

-   **Rounding and approximation**. It is difficult to perform complicated math operations during the interview. E.g., 99987 / 9.1? There is no need to spend valuable time to solve complicated math problems. Precision is not expected. Use round numbers and approximation to your advantage. -> 10000 / 10
-   **Write down your assumptions**. For reference later.
-   **Label your units**. You might confuse yourself with this.
-   **Be prepared for the commonly asked questions**: QPS, peak QPS, storage, cache, number of servers, etc.
