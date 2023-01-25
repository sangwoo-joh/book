---
layout: page
tags: [problem-solving, leetcode, python, string, two-pointer]
title: Longest Repeating Character Replacement
---

# [Longest Repeating Character Replacement](https://leetcode.com/problems/longest-repeating-character-replacement/)

 문자열 `s`와 정수 `k`가 주어진다. 문자열은 모두 알파벳 대문자로만
 이뤄져 있다. 문자열에서 아무 글자나 하나 골라서 다른 대문자로 바꾸는
 연산을 최대 `k`번 할 수 있다.

 이때, *위의 연산을 통해 얻을 수 있는 같은 글자만으로 이뤄지는 부분
 문자열 중에서 가장 긴 것의 길이*를 구하자.

 문자열의 길이는 1 ~ 100,000 사이이고 $$ 0 \leq k \leq s.length
 $$이다.

 예를 들어 `s = "ABAB"` 이고 `k = 2` 일 때, `A`를 `B`로 바꾸는 연산을
 두 번 하면 `B`로만 이뤄진 최장 부분 문자열 `"BBBB"`를 얻을 수 있고
 길이는 4이다.

## 직관으로 이해가 잘 안되지만 아무튼 되는 솔루션

 타이틀 그대로 직관으로는 잘 이해가 안되지만 아무튼 되는 솔루션을
 설명해보겠다.

 일단 조건인 `k`가 없을 때, **최소의 횟수**로 글자를 다른 글자로
 바꿔서 같은 글자로만 이뤄진 문자열을 만들려고 해보자. 최소인 이유는
 나중에 조건 `k`가 추가되는 것을 염두에 둔 것이다. 아무튼 이때의 최소
 횟수 다음과 같을 것이다: `전체 문자열의 길이 - *가장 많이 나타나는*
 글자의 수`. 여기에 `k` 조건이 추가된다면, 우리는 다음 불변식을
 만족하는 슬라이딩 윈도우를 움직이면서 답을 찾을 수 있다: `(부분
 문자열의 길이 - 해당 부분 문자열에서 *가장 많이 나타나는* 글자의 수)
 <= k`.

 이 아이디어를 구현하면 다음과 같다.

```python
from collections import Counter
def characterReplacement(s, k):
    count = Counter()
    start = 0
    maxlen, maxcnt = 0, 0
    for end in range(len(s)):
        count[s[end]] += 1
        maxcnt = max(maxcnt, count[s[end]])
        while (end - start + 1 - maxcnt) > k:
            count[s[start]] -= 1
            start += 1
        maxlen = max(maxlen, end - start + 1)
    return maxlen
```

 - 여타 다른 문제들 처럼 `Counter`로 곧바로 글자 수를 세면
   안된다. 조건에 맞는 부분 문자열을 구해야 하므로 윈도우가 커질 때
   (`end` 포인터가 커질 때) 하나 씩 증가되야 한다.
 - 현재 부분 문자열에서 가장 많이 나타나는 글자의 수를 구하기 위해서
   특별하게 뭔가 할 필요는 없다. `end` 포인터가 이동하면서 `count`에
   글자 수를 하나 씩 추가하고, 이 값을 이전의 최대 글자수와 비교하기만
   하면 된다. `start` 포인터가 이동하면서 윈도우가 줄어들 때 부분
   문자열 안의 글자 수 `count`도 업데이트 (글자수가 빠짐) 되기 때문에
   올바른 값이 들어간다.
 - 앞에서 설명했듯 `end - start + 1 - maxcnt` 값이 곧 "현재 부분
   문자열을 모두 같은 글자로 바꾸기 위해 필요한 바꾸기 연산의 최소의
   횟수"이고 이 값이 `k`보다 큰 경우에만 `start` 포인터를 움직여서
   (=윈도우를 줄여서) 탐색할 수 있다.
 - 이 알고리즘은 **길이**를 구할 순 있지만 연산을 적용할 **부분
   문자열의 위치**는 올바르게 구하지 못한다. 예를 들어 `CCCCCXXX`와
   `k=2`에서, `end`가 마지막에 도달했을 때 최종적으로 구하게 되는 부분
   문자열은 `CCCCXXX`이 되는데, 이는 2번 이상 수정해야 하는 것이지만,
   우리는 길이만 원하기 때문에 크게 문제되진 않는다.
