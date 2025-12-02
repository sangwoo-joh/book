---
layout: page
title: 07. Design a unique id generator in distributed systems
---

# Design a unique id generator in distributed systems

# Table of Contents

1.  [Step 1 - Understand the problem and establish design scope](#org3fba7e3)
2.  [Step 2 - Propose high-level design and get buy-in](#org1d19aee)
    1.  [Multi-master replication](#org0781ec4)
    2.  [UUID (Universally Unique Identifier)](#orgf294d9b)
    3.  [Ticket server](#org5372f87)
    4.  [Twitter snowflake approach](#orgabee1e4)
3.  [Step 3 - Design deep dive](#orgb4a2713)
    1.  [Timestamp](#org5b53821)
    2.  [Sequence number](#org0fcaabd)
4.  [Step 4 - Wrap up](#org62b3c44)

`auto_increment` does not work in a distributed environment

-   a single database is not large enough
-   generating unique IDs across multiple databases with minimal delay is challenging


<a id="org3fba7e3"></a>

# Step 1 - Understand the problem and establish design scope

-   IDs must be unique.
-   IDs must be sortable.
    -   IDs created in the evening are larger than those created in the morning on the same day.
    -   The ID increments by time, but not necessarily only increments by 1.
-   IDs only contain numerical values.
-   IDs should fit into 64-bit.
-   The system should be able to generate 10k IDs per second.

Some useful questions to ask

-   &ldquo;What are the characteristics of unique IDs?&rdquo;
-   &ldquo;For each new record, does ID increment by 1?&rdquo;
-   &ldquo;Do IDs only contain numerical values?&rdquo;
-   &ldquo;What is the ID length requirement?&rdquo;
-   &ldquo;What is the scale of the system?&rdquo;


<a id="org1d19aee"></a>

# Step 2 - Propose high-level design and get buy-in


<a id="org0781ec4"></a>

## Multi-master replication

-   Uses DBMS&rsquo;s `auto_increment` feature.
    -   Increase by k, the number of database servers in use.
-   Drawbacks:
    -   Hard to scale with multiple data centres.
    -   IDs do not go up with time across multiple servers.
    -   It does not scale well when a server is added/removed.


<a id="orgf294d9b"></a>

## UUID (Universally Unique Identifier)

-   128-bit number, very low probability of getting collision
    -   &ldquo;&#x2026; after generating 1 billion UUIDs every second for approximately 100 years, would the probability of creating a single duplicate reach 50%.&rdquo;
-   Pros:
    -   Generating UUID is simple. No coordination (synchronisation) between servers is needed.
    -   The system is easy to scale; just add/remove servers.
-   Cons:
    -   128 bit is too long (requirement is 66 bit).
    -   Do not go up with time.
    -   non-numeric


<a id="org5372f87"></a>

## Ticket server

-   Uses a centralised `auto_increment` feature in a single database server (= the ticket server).
-   Pros:
    -   Numeric IDs.
    -   Easy to implement.
-   Cons:
    -   Single point of failure.


<a id="orgabee1e4"></a>

## Twitter snowflake approach

Instead of generating an ID directly, it divides an ID into different sections.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-right" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">1 bit</th>
<th scope="col" class="org-left">41 bits</th>
<th scope="col" class="org-left">5 bits</th>
<th scope="col" class="org-left">5 bits</th>
<th scope="col" class="org-left">12 bits</th>
</tr>
</thead>
<tbody>
<tr>
<td class="org-right">0</td>
<td class="org-left">timestamp</td>
<td class="org-left">data centre ID</td>
<td class="org-left">machine ID</td>
<td class="org-left">sequence number</td>
</tr>
</tbody>
</table>

-   Sign bit: 1 bit. Always 0. Reserved for future uses.
-   Timestamp: 41 bits. Milliseconds since the epoch or custom epoch.
-   Data centre ID: 5 bits. Up to 32 data centres.
-   Machine ID: 5 bits. Up to 32 machines per data centre.
-   Sequence number: 12 bits. For every ID generated on the machine/process, the sequence number is incremented by 1, and is reset to 0 every millisecond.


<a id="orgb4a2713"></a>

# Step 3 - Design deep dive

-   Data centre ID and machine ID are chosen at the startup time (fixed).
-   Timestamp and sequence number are generated when the ID generator is running.


<a id="org5b53821"></a>

## Timestamp

-   As timestamps grow with time, IDs are sortable by time.
-   $2^{41}-1$ = 2199023255551 ms, around 69 years.
-   After 69 years, we will need a new epoch time or adopt  other techniques to migrate IDs.


<a id="org0fcaabd"></a>

## Sequence number

-   $2^{12}$ = 4096 combinations.
-   A machine can support a maximum of 4096 new IDs per ms.


<a id="org62b3c44"></a>

# Step 4 - Wrap up

Some additional topics.

-   Clock synchronisation.
    -   We assumed ID generation servers have the same clock. This assumption might not be true when a server is running on multiple cores. The same challenge exists in multi-machine scenarios. Refer to [Network Time Protocol](20250730182739-network_time_protocol.md).
-   Section length tuning.
    -   Fewer sequence numbers, but more timestamp bits are effective for low concurrency and long-term applications.
-   High availability.

