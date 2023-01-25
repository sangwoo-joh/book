---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Valid Anagram
---

# [Valid Anagram](https://leetcode.com/problems/valid-anagram/)

 두 문자열이 주어졌을 때, 한 쪽이 다른 한 쪽의 애너그램인지를
 확인하자.

 **애너그램**이란 원래 문자열에 있는 글자를 딱 한번씩만 쓰되 순서를
 재배치해서 다른 문자열을 만드는 것이다.

 문자열의 길이는 $$ 1 \sim 5 \times 10^4 $$이고 소문자 알파벳만 담고
 있다.

## 걍..센다

 별 거 없다. 그냥 각 문자열에 나온 글자 수를 세서 동일한지만 확인하면
 된다. 마침 파이썬에는 카운터라는 걸출한 녀석이 있고 이걸 그대로 쓰면
 된다.

```python
from collections import Counter
def isAnagram(s, t):
    return Counter(s) == Counter(t)
```

---

 만약 카운터를 쓰지 않고 일일이 세겠다면 말리진 않겠지만 다음과 같이
 하면 된다.

```python
from collections import defaultdict
def isAnagram(s, t):
    if len(s) != len(t):
        return False

    sc, tc = defaultdict(int), defaultdict(int)
    for c in s:
        sc[c] += 1
    for c in t:
        tc[c] += 1
    for c in sc:
        if sc[c] != tc[c]:
            return False
    return True
```

 - 문자열의 글자 수를 일일이 세어서 비교한다. 이때, 마지막 루프문에서
   `sc`에 없는 키 값이 `tc`에 있을 수도 있는데, 그런 경우를 미리
   걸러내기 위해서 함수 진입 초기에 길이가 다르면 `False`를 리턴하도록
   했다.
