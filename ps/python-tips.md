---
layout: page
tags: [problem-solving, python, tips]
title: Python Tips
last_update: 2023-02-11 23:31:17
---

# `sum`

 `sum(iterable, /, start=0)` 타입인데, `start`에 `iterable`의 아이템을 하나씩
 더해서 리턴하는 함수이다.

 그래서 `start`에 뭘 넘겨주느냐에 따라서 다양한 `+` 연산을 활용할 수 있다.

 예를 들면 이중 리스트를 평평하게 할 때 (flatten 연산) 리스트 컴프리헨션으로
 헷갈리게 하는 것보다는 다음과 같이 할 수 있다:

```python
arr = [[1, 2], [3, 4], [4, 5]]
sum(arr, [])  # yields [1,2,3,4,4,5]
```

 이게 되는 이유는 `start`, 즉 accumulator로 쓸 초기값이 빈 리스트이기 때문에
 이후 `iterable`의 각 원소마다 적용하는 `+` 연산이 리스트의 concatenation 으로
 해석되기 때문이다.

 하지만 공식 문서에서는 다음과 같이

> For some uses cases, there are good alternatives to `sum()`.... To concatenate
> a series of iterables, consider using `itertools.chain()`.

 즉 `iterable`의 시리즈를 합칠거면 `sum()` 쓰지 말고 `itertools.chain()`을
 쓰는 것을 추천하고 있다.

# `itertools.chain`

 별 거 없고 아래 코드와 같다.

```python
def chain(*iterables):
    # chain('abc', 'def') --> a b c d e f
    for it in iterables:
        for elt in it:
            yield elt
```

# `map`, `filter`
 적용할 함수가 먼저 온다. 어떻게 생각하면 되냐면 `map(f, x) --> f(x)`
 라고 생각하면 된다.

```python
map(lambda x: x, seq)
filter(lambda x: return True, seq)
```

# `pow`
 세 번째 파라미터 `mod`를 넘겨주는게 직접 계산하는 것보다 효율적임.

```python
pow(base, exp, mod) == pow(base, exp) % mod
```

# `sorted`, `.sort()`
 `sorted`는 새로운 시퀀스를 만들어서 정렬하고, `sort`는 제자리
 정렬이다.

```python
seq.sort()
seq = sorted(seq)
```

 둘 다 정렬 비교에 쓰일 `key` 함수를 named parameter로 넘겨줄 수 있다.

# `all`, `any`
 모든 시퀀스 안의 원소를 **전부 다** 평가한 다음, $$ \forall $$ 또는
 $$ \exists $$ 를 계산한다. 문제는 모든 원소를 전부 다 평가하기 때문에
 Short-Circuit 최적화의 혜택을 받지 못해서 `any`는 대부분의 경우 훨씬
 느리다. `all`이 필요한게 아니거나 모든 원소가 평가될 게 아니라면
 `any`는 되도록 쓰지말자.

```python
all([True, True]) == True
all([]) == True

any([True, False]) == True
any([]) == False
```

# String
 별의 별 희한한 것까지 다 표준 라이브러리 함수로 들어있어서 구현하긴 편하다.

```python
str.isalpha(), str.isdecimal(), str.isdigit(), str.isalnum(), str.isnumeric()
str.islower(), str.isupper()
str.lower(), str.upper(), str.swapcase()
str.lstrip(), str.rstrip(), str.strip()
"abc d asdf".partition('d') == ("abc ", "q", " asdf")
str.count(substring)
str.find(substring)
```

# collections

## defaultdict

```python
from collections import defaultdict

dl = defaultdict(list)
dl[0].append(1)  # not exception!
print(dl[1])  # also not exception! shows []

di = defaultdict(int)
di[0] += 1  # not exception!
print(di[100])  # also not exception! shows 0
```

## Counter

```python
from collections import Counter
s = "aabbcacaa"
c = Counter(s)  # Counter({'a':5, 'b':2, 'c':2})
c.get('a')  # get count of the element, None if not exists -> 5
c.elements()  # ['a', ..., 'b', .. 'c']
c.keys()  # ['a', 'b', 'c']
c.values()  # [5, 2, 2]
c.items()  # [('a', 5), ('b', 2), ('c', 2)]
c.most_common()  # return a list of n most common elements and their counts
c.most_common(1)  # top most common elements as list, so [('a', 5)]
```

## Deque

```python
from collections import deque
dq = deque()
dq.append(x)
dq.appendleft(y)
dq.pop()
dq.popleft()
dq.reverse()  # in-place reverse
dq.rotate(n=1) == dq.appendleft(dq.pop())
dq.count(x)
```

## OrderedDict

 * 순서를 유지하는 딕셔너리인데, 키 값의 오더링이 아니라 **아이템이 추가된
   순서**를 보장한다.
 * 거의 모든 메소드는 딕셔너리와 같고 다음 두 가지 연산이 추가적으로 제공된다.
   * `popitem(last=True)`: `last` 불리언 값에 따라서 가장 마지막에 추가된 아이템
     또는 가장 처음에 추가된 아이템을 제거한다.
   * `move_to_end(key, last=True)`: `key`에 해당하는 맵핑의 순서를 `last` 불리언
     값에 따라 가장 마지막 또는 가장 처음으로 옮긴다.

 이런 성질을 이용하면 `OrderedDict`는 LRU 또는 LFU 캐시를 만드는데 쓰일 수 있다.

# Heapq

```python
import heapq
l = [ .... some list]
heapq.heapify(l)  # make l as heap in-place
heapq.heappush(l, item)
heapq.heappop(l)
heapq.nlargest(n, l, key=None) == sorted(l, key=None, reverse=True)[:n]
heapq.nsmallest(n, l, key=None) == sorted(l, key=None)[:n]
```

# Random

```python
import random

random.choice([1, 2, 3, ...])  # pick random item
random.shuffle(l)  # shuffle l in-place
random.uniform(a, b)  # pick random **float x** in a <= x <= b
```

# Bisect

```python
import bisect

bisect.bisect_left(l, x)
bisect.bisect_right(l, x) == bisect.bisect(l, x)
```

---

# 어떤 문자열의 길이 `k`인 모든 부분 문자열 생성하기

``` python
def all_substrings(text: str, k: int):
    return set(text[i:i + k] for i in range(0, len(text) - k + 1))
```

 - 파이썬의 슬라이스를 이용해서 특정 인덱스 `i`부터 길이 `k` 만큼의
   부분 문자열을 `str[i:i + k]`로 표현할 수 있다. 인터벌 `[i, i+k)`를
   의미하므로 `i+k` 인덱스는 포함하지 않는다.
 - 시작 인덱스 범위를 계산하기 위해서 `range`를 이용하는데 이때
   `range(start, end)` 역시 `[start, end)` 인터벌을 의미하기 때문에
   `end`를 포함하지 않는다. 따라서 `end`를 `len(text)-k+1`로 해야
   `len(text) - k` 까지의 인덱스를 생성해내고, 따라서 `str[i:i+k]`에서
   `str[len(text)-k:len(text)-k+k]`가 되고 슬라이스의 `end`가
   `len(text)`가 되어 오버플로우가 나지 않는다.
 - 이렇게 생성한 부분 문자열 시퀀스를 다시 집합으로 감싸서 중복을
   제거한다.
