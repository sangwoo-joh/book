---
layout: page
title: 10. Design a notification system
---

# Design a notification system

# Table of Contents

1.  [Step 1 - Understand the problem and establish design scope](#org1735cf4)
2.  [Step 2 - Propose high-level design and get buy-in](#orga46d63f)
    1.  [Different types of notifications](#org232ec20)
    2.  [Contact info gathering flow](#org8ca488c)
    3.  [Notification sending/receiving flow](#orgecc6e9a)
3.  [Step 3 - Design deep dive](#org4a32b59)
    1.  [Reliability](#orgc906707)
    2.  [Additional components and considerations](#org0f4bfeb)
    3.  [Updated design](#org8c7ee19)
4.  [Step 4 - Wrap up](#orgf3894ef)

Three types of notification formats are available:

-   mobile push notification
-   SMS message
-   Email


<a id="org1735cf4"></a>

# Step 1 - Understand the problem and establish design scope

Some questions:

-   &ldquo;What types of notifications does the system support?&rdquo;
-   &ldquo;Is it a real-time system?&rdquo;
-   &ldquo;What are the supported devices?&rdquo;
-   &ldquo;What triggers notifications?&rdquo;
-   &ldquo;Will users be able to opt-out?&rdquo;
-   &ldquo;How many notifications are sent out each day?&rdquo;

Requirements

-   Push notification, SMS, email.
-   Soft real-time system: receive notifications as soon as possible, but if the system is under a high workload, a slight delay is acceptable.
-   iOS, android, laptop, desktop.
-   Triggered by client applications, or scheduled on the server side.
-   Opt-out.
-   10 million mobile push notifications per day.
-   1 million SMS messages per day.
-   5 million emails per day.


<a id="orga46d63f"></a>

# Step 2 - Propose high-level design and get buy-in


<a id="org232ec20"></a>

## Different types of notifications

-   **iOS**
    -   Provider: builds and sends notification requests to APNS
    -   APNS (Apple Push Notification Service): remote service by Apple, propagate push notifications to iOS devices.
        -   Device token: a unique identifier for sending notifications.
        -   Payload: notification contents.
    -   iOS device: end user client.
-   **Android**
    -   FCM (Firebase Cloud Messaging): remote service by Google, propagate push notifications to android devices.
-   **SMS message**
    -   Third party SMS services like Twilio, Nexmon, etc.
-   **Email**
    -   Opt for commercial email services like Sendgrid, Mailchimp, etc., which offer a better delivery rate and data analytics.


<a id="org8ca488c"></a>

## Contact info gathering flow

-   Need to gather mobile device tokens, phone numbers, or email addresses.
-   Email, phone numbers are stored in user table.
-   Device tokens are stored in device table.
    -   A user can have multiple devices.


<a id="orgecc6e9a"></a>

## Notification sending/receiving flow

![img](/assets/img/noti-high-level.png "high level design")

-   **Service 1 to N**
    -   Can be anything: a micro-service, a cron job, a distributed system, etc. that can triggers notification sending events.
    -   e.g., a billing service
-   **Notification system**
    -   Sending/receiving notifications.
    -   Provides API for services.
-   **Third-party services**
    -   Responsible for delivering notifications to users.
    -   &ldquo;Extensibility&rdquo;
    -   Some services might be unavailable in new markets, or in the future. e.g., FCM is not available in China -> alternatives like Jpush, PushY, etc. are used.
-   **iOS, Android, SMS, Email**
    -   User devices.

There are three main problems in this first design.

-   SPoF: single notification system.
-   Hard to scale: handles everything related to push notifications in one server -> challenging to scale databases, caches, different notification processing components independently.
-   Performance bottleneck: processing/sending notifications can be resource intensive. e.g., constructing HTML pages and waiting for responses from third party services could take time. Handling everything in one system can result in the system overload.

Improved version of high-level design.

-   Move the database and cache out of the notification servers.
-   Add more notification servers and set up automatic horizontal scaling.
-   Introduce message queues to decouple the system components.

![img](/assets/img/noti-improved.png "Improved design")

-   **Notification servers**
    -   Provide APIs for services to send notifications. Only accessible internally or by verified clients.
    -   Carry out basic validations to verify emails, phone numbers, etc.
    -   Query the cache/database to fetch data needed to render a notification.
    -   Put notification data to message queues for parallel processing.
    -   Request body could be like:

            {
                "to": [
                    {
                        "user_id": 123456
                    }
                ],
                "from": {
                    "email": "from@address.com"
                },
                "subject": "title",
                "content": [
                    {
                        "type": "text/plain",
                        "value": "hi"
                    }
                ]
            }
-   **Cache**
    -   User info, device info, notification templates, etc.
-   **DB**
    -   User data, notification log, settings, etc.
-   **Message queues**
    -   Remove dependencies between components.
    -   It serves as buffers when high volumes of notifications are to be sent out.
    -   Each notification type is assigned with a distinct message queue, so an outage in one third-party service will not affect other notification types.
-   **Workers**
    -   A list of servers that pull notification events from message queues, and send them to the corresponding third-party services.

The components work like this:

1.  A service calls APIs provided by notification servers to send notifications.
2.  Notification servers fetch metadata such as user info, device token, and notification settings and templates from the cache/database.
3.  A notification event is sent to the corresponding message queue for processing.
4.  Workers pull notification events from message queues periodically.
5.  Workers send notifications to third party services.
6.  Third-party service send notifications to user devices.


<a id="org4a32b59"></a>

# Step 3 - Design deep dive


<a id="orgc906707"></a>

## Reliability

-   **How to prevent data loss?**: One of the most important requirements in a notification system is that it cannot lose data. Notifications can usually be delayed or re-ordered, but never lost. To satisfy this requirement, the notification system persists notification data in a database and implements a retry mechanism. The notification log database is included for data persistence.
-   **Will recipients receive a notification exactly once?**: The short answer is *[no](20250804160521-you_cannot_have_exactly_once_delivery.md)*. Although notification is delivered exactly once most of the time, the distributed nature could result in *duplicate notifications*. To reduce the duplication occurrence, we introduce a dedupe mechanism and handle each failure case carefully. A simple dedupe logic looks like this: When a notification event first arrives, we check if it is seen before by checking the event ID. If it is seen before, it is discarded. Otherwise, we will send out the notification.


<a id="org0f4bfeb"></a>

## Additional components and considerations

-   **Notification template**
    -   Many notifications follow a similar format.
    -   Templates are introduced to avoid building every notification from scratch.
    -   Customise parameters, styles, tracking links, etc.
    -   Maintain consistent format, reduce the margin error, save time, etc.
-   **Notification setting**
    -   Fine-grained control over notification settings.
    -   Before any noti is sent, system must check if a user is opted-in to receive this type of notification.
-   **Rate limiting**
-   **Retry mechanism**
    -   When a third-party service fails to send noti, the noti will be added to the message queue for retrying.
    -   If the issue persists, an alert will be sent to the developers.
-   **Security in push notifications**
    -   For iOS/Android, appKey and appSecret are used to secure push notification APIs.
    -   Only authenticated or verified clients are allowed to send push notifications using our APIs.
-   **Monitor queued notifications**
    -   One of the key metrics is the total number of queued notifications.
    -   Scale properly based on this.
-   **Events tracking**
    -   Notifications metrics like open rate, click rate, engagement are important in understanding customer behaviours.
    -   Integration between the notification system and the analytics service is usually required.

![img](/assets/img/noti-event-analytics.png "events analytics")


<a id="org8c7ee19"></a>

## Updated design

![img](/assets/img/improved-noti-design.png "improved notification systems design")

-   The notification servers are equipped with two more critical features: authentication and rate limiting.
-   A retry mechanism to handle notification failures
    -   Put failed message back in the queue, workers will retry for a pre-defined number of times.
-   Templates provide a consistent and efficient notification creation process.
-   Monitoring and tracking systems.


<a id="orgf3894ef"></a>

# Step 4 - Wrap up

-   Reliability: a robust retry mechanism to minimise the failure rate.
-   Security: AppKey/appSecret pair is used.
-   Tracking and monitoring: notification flow (state diagram) to capture important stats.
-   Respect user settings: opt-out.
-   Rate limiting
