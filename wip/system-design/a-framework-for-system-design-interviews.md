---
layout: page
title: 03. A framework for system design interviews
---

# A framework for system design interviews

# Table of Contents

1.  [A 4-step process](#org1776a49)
    1.  [Step 1 - Understand the problem and establish design scope (3-10 min)](#orgbe99e24)
    2.  [Step 2 - Propose high-level design and get buy-in (agreement) (10-15 min)](#org8a22ec0)
    3.  [Step 3 - Design deep dive (10-25 min)](#orgfc5db01)
    4.  [Step 4 - Wrap up (3-5 min)](#org472b8e0)
2.  [Do](#org005cc3b)
3.  [Don&rsquo;t](#org0e4a718)

After all, how could anyone design a popular product in an hour that has taken hundreds if not thousands of engineers to build?

The good news is that no one expected you to. If no one expects you to design a real-world system in an hour, what is the benefit of a system design interview?

The system design interview simulates real-life problem solving where two co-workers collaborate on an ambiguous problem, and come up with a solution that meets their goals. The problem is open-ended, and there is no perfect answer. The final design is less important compared to the work you put in the design process. This allows you to demonstrate your design skill, defend your design choices, and respond to feedback in a constructive manner.

-   It is much more than about a person&rsquo;s technical design skills:
    -   Ability to collaborate
    -   Work under pressure
    -   Resolve ambiguity constructively
    -   Ask good questions
-   Also look for red flags:
    -   Over-engineering: only delight in design purity, and ignore tradeoffs
    -   Narrow mindedness
    -   Stubbornness


<a id="org1776a49"></a>

# A 4-step process


<a id="orgbe99e24"></a>

## Step 1 - Understand the problem and establish design scope (3-10 min)

-   Answering without a thorough understanding of requirements is a huge red flag.
-   Do not jump right in to give a solution. Slow down. Think deeply and ask questions to clarify requirements and assumptions.
-   Ask right questions, make the proper assumptions, gather all the information needed to build a system.
-   What kind of questions to ask? Examples:
    -   What specific features are we going to build?
    -   How many users does the product have?
    -   How fast does the company anticipate to scale up?
    -   What are the anticipated scales in 3/6/9 months/ a year?
    -   What is the company&rsquo;s technology stack?
    -   What existing services we might leverage to simplify the design?


<a id="org8a22ec0"></a>

## Step 2 - Propose high-level design and get buy-in (agreement) (10-15 min)

-   Aim to develop a high-level design, and reach an agreement with the interview on the design.
-   Come up with an initial blueprint for the design.
    -   Ask for feedback.
    -   Treat your interviewer as a teammate and work together.
-   Draw box diagrams with key components.
    -   Clients (mobile/web), APIs, servers, data stores, cache, CDN, message queues, etc.
-   Do back-of-the-envelope calculations to evaluate if your blueprint fits the scale constraints.
    -   Think out loud.
    -   Communicate with your interviewer if back-of-the-envelope is necessary before diving into it.
-   If possible, go through a few **concrete use cases**.
    -   This will help you frame the high-level design.
    -   Use cases would help you discover edge cases you have not considered yet.


<a id="orgfc5db01"></a>

## Step 3 - Design deep dive (10-25 min)

-   At this step, you and your interviewer should have already achieved the following objective:
    -   Agreed on the **overall goals and feature scope**.
    -   Sketched out a **high-level blueprint** for the overall design.
    -   Obtained feedback from your interviewer on the high-level design.
    -   Had some initial ideas about **areas to focus on** in deep dive based on feedback.

It is worth stressing that every interview is different.

-   Sometimes, the interviewer may give off hints that they like focusing on high-level design,
-   Or, for a senior candidate, the discussion could be on the system performance characteristics, like focusing on the bottlenecks and resource estimations,
-   Or, in most cases, the interviewer may want you to dig into details for some system components, like
    -   For URL shortener, the hash function design that converts a long URL to a short one,
    -   For a chat system, how to reduce latency, and how to support online/offline status,
    -   &#x2026;


<a id="org472b8e0"></a>

## Step 4 - Wrap up (3-5 min)

-   Identify the system bottlenecks, and discuss potential improvements.
-   It could be useful to give the interviewer a recap of your design.
-   Error cases (server failures, network loss, etc.)
-   Operational issues (monitoring metrics, error logs, roll out)
-   Handle the next scale curve (1M -> 10M)
-   Other refinements

---


<a id="org005cc3b"></a>

# Do

-   Always ask for clarification. Don&rsquo;t assume your assumption is correct.
-   Understand the requirements of the problem. Make sure you understand the requirements.
-   There is neither the right answer nor the best answer.
-   Let the interviewer know what you&rsquo;re thinking. Communicate with your interview.
-   Suggest multiple approaches if possible.
-   Once you agree with your interviewer on  the blueprint, go into details on each component.
-   Design the most critical component first.
-   Bounce ideas off the interviewer.
-   Never give up.


<a id="org0e4a718"></a>

# Don&rsquo;t

-   Don&rsquo;t be unprepared for typical interview questions.
-   Don&rsquo;t jump into a solution without clarifying the requirements and assumptions.
-   Don&rsquo;t go into too much detail on a single component in the beginning. Give the high-level design first, then drills down.
-   Don&rsquo;t hesitate to ask for hints.
-   Don&rsquo;t think in silence.
-   Don&rsquo;t think your interview is done once you give the design. You&rsquo;re not done until your interviewer says you are done. Ask for feedback early and often.
