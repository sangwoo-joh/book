---
layout: page
tags: [problem-solving, leetcode, python, string, two-pointers]
title: Longest Substring Without Repeating Characters
---

# [Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/)
 문자열이 주어졌을 때, 반복되는 문자 없이 만들 수 있는 가장 긴 부분
 분자열의 길이를 구하자.

 예를 들면 "abchabcbb"가 주어지면, 가능한 부분 문자열 중 (1) 중복
 문자가 없고 (2) 가장 긴 것은 "abc" 이므로 답은 3이다.

## Brute Force
 극혐 문자열 문제다. 일단 Brute Force로는 어떻게 구현할 수 있을지
 생각해보자.

 문자열의 시작과 끝을 증가시키면서 가능한 모든 부분 문자열을 만들 수
 있다. 그렇게 한 후에 해당 문자열에 있는 문자 개수를 세어서, 개수가
 1이 넘어가는게 하나라도 있으면 `0`이고, 가능하다면 그 문자의 개수가
 될 것이다. 이를 코드로 짜면 다음과 같다.

```python
from collections import Counter
def longest_substring_without_repeating(s):
    def is_valid(start, end):
        c = Counter(s[start:end + 1])
        return all(num == 1 for num in c.values())

    n = len(s)
    answer = 0
    for start in range(n):
        for end in range(start, n):
            if is_valid(start, end):
                answer = max(answer, end - start + 1)

    return answer
```

 - `start`, `end`는 모두 인덱스이므로 리스트 슬라이싱을 할 때 `end +
   1`을 해줘야 한다.
 - 조건에 맞는지 검사하기 위해서 Counter 모듈로 문자의 개수를 센 후에,
   전부 개수가 `1`인지를 체크했다.
 - 조건에 맞으면 문자열의 길이는 `end - start + 1`로 구할 수 있고, 이
   중 최대 길이를 누적하면 된다.

 당연하지만 이렇게하면 `O(n^3)`이 되어서 무척 느리다.


## 슬라이딩 윈도우
 보통 이런 문제는 `start`와 `end` 포인터를 최대한 덜 움직여야
 한다. 그럼 어떻게 해야 덜 움직일 수 있을까?

 일단 `start`, `end` 모두 0부터 시작하자. `end`를 하나씩 움직이면서,
 문자가 나타난 위치(인덱스)를 기록해두자. 만약 이미 기록된 위치가
 있다면 (= `end` 위치에서 중복이 일어났다면), 그 **다음 위치**로
 `start`를 옮기면 된다. 즉, 각 문자가 나타나는 위치를 계속 업데이트해
 나아가면서, 동시에 반복되는 문자를 만나자마자 그 위치를 스킵해버리면
 된다.

 말은 쉽다. 이걸 코드로 짜면 다음과 같다.

```python
def longest_substring_without_repeating(s):
    occured_index = {}
    answer = 0
    start = 0

    for end, char in enumerate(s):
        if char in occured_index:
            start = max(start, occured_index[char] + 1)

        answer = max(answer, end - start + 1)
        occured_index[char] = end

    return answer
```
 - 문자가 나타난 인덱스를 해시 테이블 `occured_index`에 기록한다.
 - 문자열의 최대 길이를 구하는 로직은 같다.
 - 이전에 나타난 위치가 있으면, `start`를 그 다음 위치로
   빨리감기한다. 이때 지금 `start`보다 **큰 경우에만** 빨리감기
   해야한다. 왜냐하면, 예를 들어 "abba"의 경우,
     1. `a`, `b`를 거치면서 `occured_index = {'a': 0,
        'b': 1}`이 된다.
     2. 두번째 `b`를 만나면 `start = 2`이 된다.
     3. 두번째 `a`를 만나면 `start = 1`이 된다(??)

 이런 경우가 발생할 수 있기 때문이다.
