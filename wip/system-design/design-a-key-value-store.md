---
layout: page
title: 06. Design a key-value store
---

# Design a key-value store

# Table of Contents

1.  [Understand the problem and establish design scope](#orga097e2d)
2.  [Single server key-value store](#orgc2021e3)
3.  [Distributed key-value store](#orgc889da3)
4.  [System components](#orgdc164ec)
    1.  [Data partition](#org106d8c3)
    2.  [Data replication](#org6f94780)
    3.  [Consistency](#org961b154)
        1.  [Consistency models](#org6940664)
    4.  [Inconsistency resolution](#org84a6ef4)
    5.  [Handling failures](#orgaa631b1)
        1.  [Failure detection](#orgdbc639e)
        2.  [Handling temporary failures](#orgfe16d1d)
        3.  [Handling permanent failures](#org6fa2ea3)
        4.  [Handling data centre outage](#org9dcdb62)
    6.  [System architecture diagram](#orge11b778)
    7.  [Write path](#orge39376d)
    8.  [Read path](#orgc55ada8)
5.  [Summary](#org71c4789)

A key-value store is a non-relational database. Each unique identifier is stored as a key with its associated value.

The key must be unique, and the value associated with the key can be accessed through the key. Keys can be plain text or hashed values. For performance reasons, a short key works better.

-   put(key, value): insert &ldquo;value&rdquo; associated with the &ldquo;key&rdquo;
-   get(key): get &ldquo;value&rdquo; associated with the &ldquo;key&rdquo;


<a id="orga097e2d"></a>

# Understand the problem and establish design scope

-   Trade-offs:
    -   Read, write, and memory usage
    -   Consistency vs. availability
-   Characteristics to be considered:
    -   The size of a key-value pair is small: less than 10KB.
    -   Ability to store big data.
    -   High availability: the system responds quickly, even during failures.
    -   High scalability: the system can be scaled to support large data set.
    -   Automatic scaling: the addition/deletion of servers should be automatic based on traffic.
    -   Tunable consistency.
    -   Low latency.


<a id="orgc2021e3"></a>

# Single server key-value store

-   An easy, intuitive approach is to store key-value pairs in a hash table which keeps everything in memory.
-   Fitting everything memory may be impossible due to the space constraint.
-   Two optimisations can be done:
    -   Data compression
    -   Store only frequently used data in memory, and the rest on disk.
-   A single server can reach its capacity very quickly. A distributed key-value store is required to support big data.


<a id="orgc889da3"></a>

# Distributed key-value store

-   [CAP Theorem](20250723141603-cap_theorem.md)


<a id="orgdc164ec"></a>

# System components

-   Based on three popular key-value store systems: Dynamo, Cassandra, and BigTable.


<a id="org106d8c3"></a>

## Data partition

-   It is infeasible to fit the complete data set in a single server.
-   Split the data into smaller partitions, and store them in multiple server.
-   Two challenges while partitioning the data:
    -   Distribute data across multiple servers evenly.
    -   Minimise data movement when nodes are added or removed.
-   [Consistent hashing](20250709143432-design_consistent_hashing.md) is a great technique to solve these problems.
    -   **Automatic scaling**: servers could be added or removed automatically depending on the load.
    -   **Heterogeneity(이질성)**: the number of virtual nodes for a server is proportional to the server capacity.
        -   서로 다른 서버 (Heterogeneous servers)의 성능 차이를 인정하고 그에 맞게 부하를 차등 분배하는 기법 (Dynamo paper에서 처음 나옴)


<a id="org6f94780"></a>

## Data replication

-   To achieve high availability and reliability, data must be replicated asynchronously over n servers. (n is configurable)
-   After a key is mapped to a position on the hash ring, walk clockwise from that position and choose the first N servers on the ring to store data copies.
-   With virtual nodes, the first n nodes on the ring may be owned by the fewer than n physical servers. To avoid this issue, we only choose **unique servers** while performing the clockwise walk logic.
-   For better reliability, replicas are placed in **distinct data centres**


<a id="org961b154"></a>

## Consistency

-   Data is replicated at multiple nodes, so it must be synchronised across replicas.
-   [Quorum Consensus](20250723145217-quorum_consensus.md) can guarantee consistency for both read and write operations.

![img](/assets/img/quorum.png "Quorum consensus example")

-   N = The number of replicas.
-   W = A write quorum of size W. For a write operation to be considered as successful, write operation must be acknowledged from W replicas.
-   R = A read quorum of size R. For a read operation to be considered as successful, read operation must be acknowledged from at least R replicas.

The example is when N = 3.

-   If W=1, the coordinator must receive at least one acknowledgement before the write operation is considered as successful. If we get an ack from s1, we no longer need to wait for ack from s0 and s2. A coordinator acts as a proxy between the client and the nodes.

How to configure N, R, W?

-   R=1 and W=N: the system is optimised for **fast reads**.
-   W=1 and R=N: the system is optimised for **fast writes**.
-   W+R > N: strong consistency.
    -   There must be **at least one** overlapping node that has the latest data to ensure consistency.
-   W+R $\le$ N: strong consistency is not guaranteed.


<a id="org6940664"></a>

### Consistency models

Defines the degree of data consistency

-   **Strong consistency**: **any read operation** returns a value corresponding to the result of the most updated write data item. A client never sees out-of-date data.
    -   Forcing a replica not to accept new reads/writes until *every replica has agreed on current write*.
    -   Not ideal for highly available systems.
-   **Weak consistency**: subsequent read operations **may not** see the most updated value.
-   **Eventual consistency**: a specific form of weak consistency, which is, given enough time, all updates are **propagated**, and all replicas become consistent.
    -   Dynamo, Cassandra
    -   Allows inconsistent values to enter the system, and force the client to read the value to **reconcile**.


<a id="org84a6ef4"></a>

## Inconsistency resolution

-   A vector clock: [server, version] pair associated with a data item.

Assume a vector clock is represented by D([s1,v1], [s2,v2], &#x2026;, [sn,vn]), where D is a data item, vn is a version counter, and sn is a server number. If data item D is written to server si, the system must perform one of the following tasks:

-   increment vi if [si, vi] exists
-   otherwise, create a new entry [si, 1].

![img](/assets/img/vector-clock-reconcile.png "an example of vector clock versioning")

1.  A client writes a data item D1 to the system, and the write is handled by server s1, which now has the vector clock D1([s1, 1]).
2.  Another client reads the latest D1, updates it to D2, and writes it back. D2 descends from D1 so it overwrites D1. The write is handled by the same server s1, which now has vector clock D1([s1, 2]).
3.  Another client reads the latest D2, updates it to D3, and writes it back. The write is handled by s2, which now has vector clock D3([s1,2], [s2,1]).
4.  Another client reads the latest D2, updates it to D4, and writes it back. The write is handled by s3, which now has vector clock D4([s1,2], [s3,1]).
5.  When another client reads D3 and D4, it discovers a conflict, which is caused by data item D2 being modified by both s2 and s3. The conflict is resolved by the client and updated data is sent to the server. The write is handled by s1, which now has D5([s1,3], [s2,1], [s3,1]).

---

Using vector clocks, it is easy to tell that a version X is an **ancestor** (i.e., no conflict) of version Y if the version counters for each participant in the vector clock of Y is greater than or equal to the ones in version X.

-   D1([s1,1]) is an ancestor of D2([s1,2])
-   D2[s1,2] is an ancestor of D3([s1,2], [s2,1])

(서버가 없으면 0으로 치면 되는듯)

You can tell that a version X is a **sibling** (i.e., a conflict) of Y if there is any participant in Y&rsquo;s vector clock who has a counter that is less than its corresponding counter in X.

-   D3([s1,2], [s2,1]) and D4([s1,2], [s3,1]) have conflict.
-   D([s0,1], [s1,2]) and D([s0,2], [s1,1]) have conflict.

Two notable downsides.

1.  Add complexity to client. (conflict resolution)
2.  Space complexity - the [server:version] pairs in the vector clock can grow rapidly.
    1.  Set threshold for the length, and if exceeds the limit, the oldest pairs are dropped. -> could lead to inefficiencies in reconciliation due to the inaccurate descendant relationship. -> Dynamo experiments show that this is acceptable solution.


<a id="orgaa631b1"></a>

## Handling failures

As with any large system at scale, failures are not only inevitable, but **common**. Handling failure scenario is very important.


<a id="orgdbc639e"></a>

### Failure detection

In a distributed system, it is insufficient to believe that a server is down because another server says so. Usually, it requires at least two independent sources of information to mark a server down.

A [Gossip protocol](20250723165330-gossip_protocol.md) is better solution.

-   Each node maintains a node membership list. It contains member IDs and heartbeat counters.
-   Each node periodically increments its heartbeat counter.
-   Each node periodically sends heartbeats to a set of random nodes, which in turn propagate to another set of nodes.
-   Once nodes receive heartbeats, membership list is updated to the latest info.
-   If the heartbeat has not increased for more than pre-defined periods, the member is considered as offline.


<a id="orgfe16d1d"></a>

### Handling temporary failures

After failures have been detected through the gossip protocol, read/write operations could be blocked.

-   **Sloppy quorum**: used to improve availability; instead of enforcing the quorum requirement, the system chooses the first W healthy servers for writes and first R healthy servers for reads on the hash ring. Offline servers are ignored.
-   **Hinted hand-off**: a server becomes unavailable, another server will process requests temporarily. When the down server is up, changes will be pushed back to achieve data consistency.


<a id="org6fa2ea3"></a>

### Handling permanent failures

-   **Anti-entropy protocol**
    -   keep replicas in sync.
    -   comparing each piece of data on replicas and updating each replica to the newest version.
    -   **Merkle tree** is used for inconsistency detection and minimising the amount of data transferred: a tree in which every non-leaf node is labelled with the hash of the labels or values (in case of leaves) of its child nodes. Hash trees allow efficient and secure verification of the contents of large data structures.
    -   Using Merkle tree, the amount of data needed to be synchronised is proportional to the differences between the two replicas, and not the amount of data they contain. In real-world systems, the bucket size is quite big (e.g., 1,000 keys).


<a id="org9dcdb62"></a>

### Handling data centre outage

-   Replicate data across multiple data centres.


<a id="orge11b778"></a>

## System architecture diagram

![img](/assets/img/key-value-arch.png "key-value store architecture")

-   Client communicate with the key-value store through simple APIs: get(key) and put(key, value).
-   A *coordinator* is a node that acts as a proxy between the client and the key-value store.
-   Nodes are distributed on a consistent hash ring.
-   The system is completely decentralised; adding and moving nodes can be automatic.
-   Data is replicated at multiple nodes.
-   There is no single point of failure, as every node has the same set of responsibilities.

![img](/assets/img/key-value-node.png "key-value store&rsquo;s node responsibilities")


<a id="orge39376d"></a>

## Write path

![img](/assets/img/key-value-write-path.png)

1.  The write request is persisted on a commit log.
2.  Data is saved in the memory cache.
3.  When the memory cache is full or reaches a threshold, data is flushed to SSTable on disk.

Note that a sorted-string table ([SSTable](20250724164021-sstable.md)) is a sorted list of <key, value> pairs.


<a id="orgc55ada8"></a>

## Read path

![img](/assets/img/key-value-read-path-0.png)

-   If data is in the memory cache, it is returned to the client directly.

![img](/assets/img/key-value-read-path-1.png)

Otherwise,

1.  The system first checks if data is in memory. If not, go to step (2).
2.  The system checks the bloom filter.
3.  The bloom filter is used to figure out which SSTables might contain the key.
4.  SSTables return the result of the data set.
5.  The result is returned to the client.


<a id="org71c4789"></a>

# Summary

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Goal or Problems</th>
<th scope="col" class="org-left">Technique</th>
</tr>
</thead>
<tbody>
<tr>
<td class="org-left">Ability to store big data</td>
<td class="org-left">Use consistent hashing to spread the load across servers</td>
</tr>

<tr>
<td class="org-left">High availability (reads)</td>
<td class="org-left">Data replication, Multi data centres</td>
</tr>

<tr>
<td class="org-left">High availability (writes)</td>
<td class="org-left">Versioning and conflict resolution with vector clocks</td>
</tr>

<tr>
<td class="org-left">Dataset partition</td>
<td class="org-left">Consistent hashing</td>
</tr>

<tr>
<td class="org-left">Incremental scalability</td>
<td class="org-left">Consistent hashing</td>
</tr>

<tr>
<td class="org-left">Heterogeneity</td>
<td class="org-left">Consistent hashing with server capacities</td>
</tr>

<tr>
<td class="org-left">Tunable consistency</td>
<td class="org-left">Quorum consensus</td>
</tr>

<tr>
<td class="org-left">Handling temporary failures</td>
<td class="org-left">Sloppy quorum and hinted hand-off</td>
</tr>

<tr>
<td class="org-left">Handling permanent failures</td>
<td class="org-left">Merkle tree</td>
</tr>

<tr>
<td class="org-left">Handling data centre outage</td>
<td class="org-left">Multi data centres, replication across data centres</td>
</tr>
</tbody>
</table>
