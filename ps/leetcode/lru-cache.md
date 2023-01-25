---
layout: page
tags: [problem-solving, leetcode, python, lru-cache]
title: LRU Cache
---

# [LRU Cache](https://leetcode.com/problems/lru-cache/)

 말 그대로 LRU Cache를 만드는 문제다.

 LRU 캐시는 아래 성질을 만족한다:
  - `capacity` 만큼의 캐시 사이즈를 유지한다.
  - `get(key)`, `put(key, value)` 메소드가 호출될 때 마다 `key` 값에
    해당하는 캐시는 가장 최근에 사용한 친구로 기록된다.
  - `put`이 호출될 때 캐시 사이즈가 넘치게 되면, 가장 안쓰이는 친구가
    방출되어야 한다.

## 접근
 - LRU 캐시의 기능(Functionality)을 구현하려면 아래 세 가지가
   필요하다:
   - 키-밸류 맵핑: 일반적인 해시맵, 딕셔너리와 같다.
   - 키에 접근한 순서를 유지: 키에 접근한 순서를 관리하기 위한
     자료구조가 추가적으로 필요하다. 보통은 더블 링크드 리스트를
     사용한다. 이유는 어떤 노드를 리스트의 가장 앞(헤드) 또는 가장
     마지막(테일)에 옮기는 연산을 O(1) 만에 할 수 있기 때문이다.
   - 키에 접근한 순서를 *빠르게* 연산: 키에 접근 순서를 위해서 그냥
     더블 링크드 리스트만 쓰면 어떤 키(노드)인지를 찾는데 O(N)의
     복잡도가 필요하다. 이를 해결하기 위해서 추가적인 키-노드 맵핑이
     필요하다. 역시 해시맵을 쓴다.
 - 이 기능을 구현한 파이썬 라이브러리 `OrderedDict`를 가져다 쓰면
   된다:
   - `move_to_end(key, last=False)`를 이용해서 접근 순서를 앞/뒤로
     움직일 수 있다.
   - `popitem(last=True)`를 이용해서 가장 최근/마지막에 접근한
     아이템을 버릴 수 있다.

```python
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity: int):
        self.cap = capacity
        self.cache = OrderedDict()

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key, last=False)
        return self.cache[key]

    def put(self, key: int, value: int) -> None:
        self.cache[key] = value
        self.cache.move_to_end(key, last=False)
        if len(self.cache) > self.cap:
            self.cache.popitem(last=True)
```
