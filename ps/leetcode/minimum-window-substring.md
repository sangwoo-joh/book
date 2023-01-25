---
layout: page
tags: [problem-solving, leetcode, python, string, two-pointers]
title: Minimum Window Substring
---

# [Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/)
 두 문자열 `s`랑 `t`가 주어졌을 때, `t`에 있는 모든 문자를 담은 `s`의
 부분 문자열(window) 중 가장 짧은 것을 구하는 문제다. 없으면 ""를
 리턴.

 최소 길이의 윈도우는 항상 1개만 존재하도록 보장된다. `t`에는 중복이
 있을 수도 있기 때문에 `t`의 글자 수도 맞아야 한다.

 - `s`, `t`의 길이는 1~100,000
 - `s`, `t` 모두 대소문자 알파벳만 포함한다.

## 슬라이딩 윈도우
 암튼 어떻게 슬라이딩 윈도우를 적용해야 할지 고민해보자. `end`
 인덱스를 계속 늘려가면서 윈도우를 키운다. 윈도우가 조건인 `t`의 모든
 문자를 담게 되면, 그 다음 "더 잘 할 수 있나?" 를 확인해 가면서 윈도우
 크기를 줄여나가면 (shrink) 될 것 같다. 중간 중간 가장 작은 값을
 누적하면 되겠지.

 슬라이딩 윈도우의 어려운 점은, 이렇게 말은 쉬운데 코드로 한번에 오류
 없는 구현을 해내기가 힘든 부분인 것 같다. 차근차근 구현한 코드는
 다음과 같다.

```python
from collections import Counter

def min_window(s, t):
    # requirements
    requirement = Counter(t)
    required_alphas = len(requirement)

    # for sliding window
    start, end = 0, 0
    window = {}  # contains window's alphabet count
    formed_alphas = 0

    # for answer
    min_len = float('inf')
    answer = ""

    for end in range(len(s)):
        cur = s[end]
        window[cur] = window.get(cur, 0) + 1

        if cur in requirement and window[cur] == requirement[cur]:
            # this is the condition
            formed_alphas += 1

        # Can I do better? part
        # shrink window while
        # (1) it is a valid window and
        # (2) it contains all required alphabets
        while start <= end and formed_alphas == required_alphas:
            # update answer
            shrinked_len = end - start + 1
            if shrinked_len < min_len:
                min_len = shrinked_len
                min_substring = s[start:end + 1]

            # update current state
            char = s[start]
            window[char] -= 1
            if char in requirement and window[char] < requirement[char]:
                formed_alphas -= 1

            start += 1

    return answer
```
 - 먼저 만족해야 하는 조건인 `requirement`를 `Counter` 모듈로
   만들어둔다. 그리고 미리 조건의 알파벳 개수를 계산해둔다.
 - 슬라이딩 윈도우는 `start`, `end` 정보 외에도 윈도우 안의 알파벳
   개수를 위한 `window` 해시 테이블과, `requirement`를 만족하는 알파벳
   개수를 위한 `formed_alphas`를 갖는다. 여기서 `requirement`를
   만족한다는 의미는, `requirement`에 있는 알파벳의 개수와 `window`의
   알파벳의 개수가 같다는 의미이다.
 - 정답은 최소 길이 *문자열* 이므로 길이와 문자열을 다 갖고 있는다.
 - `end`를 늘려가면서 window 정보를 계속 업데이트 한다. 현재 커서가
   조건에 필요한 문자이면서, 조건과 개수까지 같을 때,
   `formed_alphas`를 업데이트 한다. `Counter`와 윈도우를 직접 비교하지
   않고 이렇게 하는 이유는, 윈도우 안에는 `requirement` 에 있는 알파벳
   외에 다른 알파벳이 있을 수 있기 때문이다.
 - 중요한 것은 "Can I do better?" 부분이다. *최소 길이*의 윈도우를
   구하는 것이 목표이기 때문에, 조건을 만족하는 동안 계속 윈도우
   크기를 줄이는 시도를 해야하므로 루프를 돈다. 이때 그 "조건"이란
   주석에도 나와있듯이,
    1. 유효한 Window여야 하므로 `start <= end` 이고,
    2. 알파벳 조건을 모두 만족해야 하므로 `formed_alphas`를 비교해야 한다.
 - 그 후 루프 안에서 `start`를 하나씩 증가시켜야 하는데, 증가시키기
   전에 윈도우와 관련된 상태를 업데이트해줘야 한다. 일단 `window` 해시
   테이블 값을 업데이트하고, 만약 `start`에 있던 문자가 조건을
   만족시키지 못하게 한다면 이 부분도 같이 업데이트해줘야 한다.
 - 여기까지 하고 나야 비로소 윈도우 크기를 줄일 수 있다.
