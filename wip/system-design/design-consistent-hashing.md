---
layout: page
title: 05. Design consistent hashing
---

# Design consistent hashing

# Table of Contents

1.  [The rehashing problem](#org5f0cb61)
2.  [Consistent hashing](#org34e9f43)
    1.  [Basic approach](#orgfdbafac)
    2.  [Virtual nodes](#orga4cc498)
3.  [Wrap up](#orgcabca43)

Consistent hashing is a commonly used technique to achieve horizontal scaling, to distribute requests/data efficiently and evenly *across servers*.


<a id="org5f0cb61"></a>

# The rehashing problem

해싱을 하면 제법 골고루 랜덤한 값이 나오긴 하지만, 일반적으로 이 값이 너무 크기 때문에 곧바로 쓸 수 없고 모듈러 연산으로 원하는 크기만큼 줄인다. 만약에 n개의 서버에 (across servers) 해싱을 하고 싶다면, 해싱한 값을 n으로 모듈러 하게 된다. 문제는 서버 수, 즉 n이 바뀌는 경우이다. 이때는 모든 모듈러 연산의 n이 바뀌기 때문에, 같은 서버라도 해시 값이 바뀌게 된다. 이를 리해싱 문제라고 한다.

Most keys are **redistributed**. This causes a storm of cache misses.


<a id="org34e9f43"></a>

# [Consistent hashing](20250722165217-introduction_and_consistent_hashing.md)

A special kind of hashing such that when a hash table is re-sized and consistent hashing is used, only k/n keys need to be remapped on average, where k is the number of keys, and n is the number of slots. In contrast, in most traditional hash tables, a change in the number of array slots causes nearly all keys to be remapped.


<a id="orgfdbafac"></a>

## Basic approach

-   Assume SHA1 is used as the hash function.
-   SHA1 space goes from 0 to $2^{160}-1$.
-   By collecting both ends, we get a hash ring.
-   We map **servers** based on server IP or name onto the ring.
-   One thing worth mentioning is that hash function used here is different from the one in &ldquo;the rehashing problem.&rdquo;, and there is no modular operation!
-   To determine which server a key is stored on, we go rightward/clockwise from the key position on the ring until a server is found.
-   Adding a new server will only require redistribution of a fraction of keys (usually 1/n).
-   When a server is removed, only a fraction of keys require redistribution with consistent hashing. The rest of the keys are unaffected.

There are two issues in this basic approach.

1.  It is impossible to keep the same size of partitions on the ring for all servers considering a server can be added or removed. A partition is the hash space between adjacent servers. It is possible that the size of the partitions on the ring assigned to each server is very small or fairly large.
2.  It is possible to have a non-uniform key distribution on the ring.


<a id="orga4cc498"></a>

## Virtual nodes

-   A virtual node refers to the real node, and each server is represented by multiple virtual nodes on the ring.
-   As the number of virtual nodes increases, the distribution of keys becomes more balanced.
    -   Because the standard deviation gets smaller with more virtual nodes, leading to balanced data distribution!
    -   With one or two hundred virtual nodes, the standard deviation is between 5-10% of the mean.


<a id="orgcabca43"></a>

# Wrap up

The benefits of consistent hashing include:

-   Minimised keys are redistributed when servers are added/removed.
-   Easy to scale horizontally because data are more evenly distributed.
-   Mitigate hotspot key problem. Excessive access to a specific shard could cause server overload.

Widely used:

-   Partitioning component of Amazon&rsquo;s Dynamo
-   Data partitioning across the cluster in Apache Cassandra
-   Discord chat application
-   Akamai content delivery network
-   Maglev network load balancer
