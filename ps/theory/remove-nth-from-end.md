---
layout: page
tags: [problem-solving, python, tips, linked-list]
title: Remove n-th Node from End of a List
---

{: .no_toc }
## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

# Remove n-th from end

 Pioneer가 n 만큼 먼저 땅을 밝히고, 이후에 Follower와 Pioneer가
 발맞추어 리스트의 끝까지 도달하면 된다. 이때 Pioneer를 한 칸 덜
 보내야 Follower가 삭제할 노드 바로 직전에 위치하도록 만들 수 있다.

```python
def remove_nth_from_end(head, n):
    pioneer = head
    follower = head

    while n > 0:
        n -= 1
        pioneer = pioneer.next

    if pioneer is None:
        # remove head
        return head.next

    while pioneer.next:
        pioneer = pioneer.next
        follower = follower.next

    # now, follower is right before the node that needs be deleted
    follower.next = follower.next.next

    return head
```
