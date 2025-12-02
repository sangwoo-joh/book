---
layout: page
title: 04. Design a rate limiter
---

# Design a rate limiter

# Table of Contents

1.  [Rate Limiter](#orgc2600f3)
2.  [Step 1 - Understand the problem and establish design scope](#org2df1f79)
3.  [Step 2 - Propose high-level design and get buy-in](#orgd58a7af)
    1.  [Where to put rate limiter?](#org6123c2f)
        1.  [API Gateway](#org71f9bce)
        2.  [Few Guidelines to ask where should we put the rate limiter](#org2923b32)
    2.  [Algorithms for rate limiting](#orgf45136c)
        1.  [Token bucket](#org595eb1b)
        2.  [Leaking bucket](#org5ac4784)
        3.  [Fixed window counter](#orgc59d342)
        4.  [Sliding window log](#org532e7ca)
        5.  [Sliding window counter](#org4bce718)
    3.  [High-level architecture](#org0f52e57)
4.  [Step 3 - Design deep dive](#orgc7d16e5)
    1.  [Rate limiting rules](#orgf587998)
    2.  [Exceeding the rate limit](#orgf575375)
    3.  [Detailed design](#orgc7eb5a8)
    4.  [Rate limiter in a distributed environment](#orgf267d3c)
        1.  [Race condition](#org6e1bf94)
        2.  [Synchronisation issue](#org3031954)
    5.  [Performance Optimisation](#orgefc6a64)
        1.  [Multi data centre](#org78c752a)
        2.  [Eventual consistency](#orgba08ce0)
    6.  [Monitoring](#orgf81c7f2)
5.  [Step 4 - Wrap up](#org0f86ac7)



<a id="orgc2600f3"></a>

# Rate Limiter

-   Control the rate of traffic sent by a client/service.
-   Prevent resource starvation cause by DoS (Denial of Service) attack.
-   Reduce cost.
    -   Extremely important for companies that use paid third party APIs e.g., check credit, payment, retrieve health records, etc.
-   Prevent servers from being overloaded.
-   Examples:
    -   Twitter: 300 tweets per 3 hours
    -   Google docs: 300 per user per 60 seconds for read requests.


<a id="org2df1f79"></a>

# Step 1 - Understand the problem and establish design scope

-   Accurately limit excessive request.
-   Support flexible throttle rules.
-   Low latency. The rate limiter should not slow down HTTP response time.
-   Use as little memory as possible.
-   Distributed rate limiting. Can be shared across multiple servers or processes.
-   Exception handling. Show clear exceptions to users when their requests are throttled.
-   High fault tolerance. If there are any problems with the rate limiter, it does not affect the entire system.

Some questions that can ask for this:

-   &ldquo;What kind of rate limiter are we going to design? Is it a client-side or server-side API?&rdquo;
-   &ldquo;Does the rate limiter throttle API requests based on IP, the user ID, or other properties?&rdquo;
-   &ldquo;What is the scale of the system? Is it built for a startup or a big company with a large user base?&rdquo;
-   &ldquo;Will the system work in a distributed environment?&rdquo;
-   &ldquo;Is the rate limiter a separate service, or should it be implemented in application code?&rdquo;
-   &ldquo;Do we need to inform users who are throttled?&rdquo;


<a id="orgd58a7af"></a>

# Step 2 - Propose high-level design and get buy-in


<a id="org6123c2f"></a>

## Where to put rate limiter?

-   Client-side
    -   Client is generally unreliable.
    -   Do not have control over the client implementation.
-   Server-side (in the API server application)
-   Middle-ware
    -   Throttles request to the API server in-between.

The middle-ware approach is usually implemented within a component called API gateway.


<a id="org71f9bce"></a>

### API Gateway

-   fully managed service
-   rate limiting
-   SSL termination
-   authentication
-   IP whitelisting
-   servicing static content


<a id="org2923b32"></a>

### Few Guidelines to ask where should we put the rate limiter

-   Evaluate the current tech stack. e.g., programming language, cache service, etc.
-   Identify the rate limiting algorithm that fits your business needs.
    -   If we implement everything on the server-side, we have full control.
    -   If we choose a third-party gateway, we might be limited.
-   Already MSA and included an API gateway, then add a rate limiter could be trivial.
-   Building own rate limiting service takes time. If limited engineering resources, a commercial API gateway is a better option.


<a id="orgf45136c"></a>

## Algorithms for rate limiting


<a id="org595eb1b"></a>

### Token bucket

-   Algorithm
    -   A **token bucket** is a container with pre-defined capacity.
    -   A **refiller** puts tokens in the bucket at preset rates periodically.
    -   Once the bucket is full, no more tokens are added (extra tokens will overflow).
    -   **Each request consumes one token**.
        -   In case of enough tokens, it takes one token and the request goes through.
        -   If case of empty bucket, the request is dropped.
-   Used by: Amazon, Stripe
-   Simple, well understood
-   Parameters
    -   Bucket size: the maximum number of tokens allowed in the bucket.
    -   Refill rate: number tokens put into the bucket every second.
-   Notes
    -   It is usually necessary to have different buckets for different API endpoints.
    -   If we need to throttle requests based no IP addresses, each IP address requires a bucket.
    -   If the system allows a maximum of 10k requests per second, it makes sense to have a global bucket shared by all requests.
-   Pros
    -   The algorithm is simple, easy to implement.
    -   Memory efficient.
    -   Token bucket allows a burst of traffic for short periods. A request can go through as long as there are tokens available.
-   Cons
    -   It might be challenging to tune two parameters properly.


<a id="org5ac4784"></a>

### Leaking bucket

-   Similar to token bucket, except that requests are processed at a **fixed rate**, and usually implemented with a FIFO queue.
-   Algorithm
    -   When a request arrives, the system checks if the queue is full.
        -   Full -> dropped
        -   Otherwise -> added to the queue
    -   Requests are pulled from the queue and processed at regular intervals.
-   Parameters
    -   Bucket size: the queue size.
    -   Outflow rate: how many requests can be processed at a fixed rate.
-   Used by: Shopify
-   Pros:
    -   Memory efficient given the limited queue size.
    -   Requests are processed at a fixed rate therefore it is suitable for use cases that a stable outflow rate is needed.
-   Cons:
    -   A burst of traffic fills up the queue with old requests, and if they are not processed in time, recent requests will be rate limited.
    -   Parameter tuning.


<a id="orgc59d342"></a>

### Fixed window counter

-   Algorithm
    -   Divide timeline into fix-sized time windows, and assign a counter for each window.
    -   Each request increments the counter by one.
    -   Once the counter reaches the pre-defined threshold, new requests are dropped until a new time window starts.
-   Pros:
    -   Memory efficient.
    -   Easy to understand.
    -   Resetting available quota at the end of a unit time window fits certain use cases.
-   Cons:
    -   A burst of traffic at the edges of time windows could cause **more requests than allowed quota to go through**. (usually doubled)


<a id="org532e7ca"></a>

### Sliding window log

-   To address the burst traffic issue of the fixed window counter.
-   Algorithm
    -   Keep track of request timestamps. Timestamp data is usually kept in cache.
    -   When a new request comes in, remove all the outdated timestamps. Outdated timestamps are defined as those older than the start of the current time window.
    -   Add timestamp of the new request to the log.
    -   If the log size is the same or lower than the allowed count, a request is accepted. Otherwise rejected.
-   Pros:
    -   Very accurate. In any rolling window, requests will not exceed the rate limit.
-   Cons:
    -   Consume a lot of memory, because even if a request is rejected, its timestamp might still be stored in memory.


<a id="org4bce718"></a>

### Sliding window counter

-   Hybrid approach: the fixed window counter + sliding window log.
    -   The number of requests in the rolling window: Requests in current window + (requests in the previous window x overlap percentage of the rolling window and previous window).
-   Pros:
    -   Smooth out spikes in traffic because the rate is based on the average rate of the previous window.
    -   Memory efficient.
-   Cons:
    -   It only works for not-so-strict look back window. It is an approximation of the actual rate, because it assumes requests in the previous window are evenly distributed. However, this problem many not be as bad as it seems. According to experiments done by Cloudflare, only 0.003% of requests are wrongly allowed or rate limited among 400 million requests.


<a id="org0f52e57"></a>

## High-level architecture

-   Basic idea is simple: At the high-level, we need a counter to keep track of how many requests are sent from the same user, IP address, etc. If the counter is larger than the limit, the request is disallowed.
-   Where to store counter?
    -   DB: slow (disk access)
    -   In-memory cache: fast, time-based expiration strategy

![img](/assets/img/rate-limiter-hld.png "High level design")

1.  Client sends a request to rate limiter middleware.
2.  Rate limiter fetches the counter from the corresponding bucket in Redis and checks the limit.
3.  Accept or reject.


<a id="orgc7d16e5"></a>

# Step 3 - Design deep dive

Following up questions:

-   How are rate limiting rules created?
-   Where are the rules stored?
-   How to handle requests that are rate limited?


<a id="orgf587998"></a>

## Rate limiting rules

-   Lyft open-sourced their rate-limiting component.
-   Rules are generally written in configuration files, and saved on disk.

    domain: messaging
    descriptors:
      - key: message_type
        value: marketing
        rate_limit:
          unit: day
          requests_per_unit: 5

    domain: auth
    descriptors:
      - key: auth_type
        value: login
        rate_limit:
          unit: minute
          requests_per_unit: 5


<a id="orgf575375"></a>

## Exceeding the rate limit

-   HTTP 429 (Too Many Requests) with the following headers
    -   `X-Ratelimit-Remaining`: the remaining number of allowed requests within the window.
    -   `X-Ratelimit-Limit`: How many calls the client can make per time window.
    -   `X-Ratelimit-Retry-After`: The number of seconds to wait until you can make a request again without being throttled.


<a id="orgc7eb5a8"></a>

## Detailed design

![img](/assets/img/rate-limit-detailed.png "Detailed design")

-   Rules are stored on the disk. Workers frequently pull rules from the disk, and store them in the cache.
-   The request from the client is sent to the rate limiter middleware first.
-   Rate limiter middleware loads rules from the cache. It fetches counters and last request timestamp from Redis cache.
    -   If the request is not rate limited, it is forwarded to API servers.
    -   If the request is rate limited, the rate limiter returns 429 too many requests error to the client.
        -   The request is either dropped, or forward to the queue.


<a id="orgf267d3c"></a>

## Rate limiter in a distributed environment

Scaling the system to support multiple servers and concurrent threads has at least two challenges:

-   Race condition
-   Synchronisation issue


<a id="org6e1bf94"></a>

### Race condition

-   Situation:
    -   Read *counter* from Redis.
    -   Check if *counter + 1* exceeds the threshold.
    -   If not, increment the *counter* by 1 and stored back in Redis.
-   Solutions
    -   Locks: significant performance trade-off
    -   [Lua script](20250722110033-race_free_redis_how_lua_scripting_delivers_atomicity_and_performance.md)
    -   [Sorted set data structure in Redis](20250722094155-better_rate_limiting_with_redis_sorted_sets.md)


<a id="org3031954"></a>

### Synchronisation issue

-   One rate limiter might not enough to handle the traffic, so we need multiple.
-   But, multiple rate limiters need synchronisation (as the web tier is stateless).
-   Possible solutions
    -   Sticky sessions: neither scalable nor flexible.
    -   Centralised data stores (Redis): better


<a id="orgefc6a64"></a>

## Performance Optimisation


<a id="org78c752a"></a>

### Multi data centre

-   For lower latency.
-   E.g., Cloudflare has over 330 geographically distributed edge servers (2025)
-   Traffic is automatically routed to the closest edge servers to reduce latency.


<a id="orgba08ce0"></a>

### Eventual consistency

-   Synchronise data with an eventual consistency model.
-   [Design a key-value store](20250709143438-design_a_key_value_store.md)


<a id="orgf81c7f2"></a>

## Monitoring

-   It is important to gather analytics data to check whether the rate limiter is effective.
    -   The rate limiting algorithm is effective.
        -   We can notice the rate limiter becomes ineffective when there is a sudden increase in traffic (e.g. flash sales) -> replace the algorithm to support burst traffic (e.g., token bucket).
    -   The rate limiting rules are effective.
        -   If rules are too strict, many valid requests are dropped -> relax the rules a little bit.


<a id="org0f86ac7"></a>

# Step 4 - Wrap up

-   Discussed different algorithms of rate limiting, and their pros/cons.
-   Discussed the system architecture, even in distributed environment.
-   Discussed additional topics, performance and monitoring.
-   Additional talking points are:
    -   Hard (the number of requests cannot exceed the threshold) vs. soft (requests can be exceed the threshold for a short period).
    -   Rate limiting at different levels
        -   Only covered Application level (layer 7)
        -   It is possible to apply rate limiting at other layers, e.g., IP addresses using IP tables (layer 3).
    -   Avoid being rate limited in the client side:
        -   Use client cache to avoid making frequent API calls.
        -   Understand the limit and do not send too many requests in a short time frame.
        -   Include code to catch exceptions or errors so  your client can gracefully recover from exceptions.
        -   Add sufficient back off time to retry logic.
