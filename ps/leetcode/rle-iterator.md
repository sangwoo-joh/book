---
layout: page
tags: [problem-solving, leetcode, python, math]
title: RLE Iterator
---

# [RLE Iterator](https://leetcode.com/problems/rle-iterator/)

 정수 배열을 인코딩하는 방법 중 하나로 RLE(Run Length Encoding)이라는
 것이 있다. RLE 인코딩 배열 `encoding`은 항상 짝수 길이의 배열이며
 모든 짝수 `i`에 대해서 `encoding[i]`는 0보다 큰 정수
 `encoding[i+1]`이 몇 번 나타나는지를 알려준다.

 예를 들어서 `[8,8,8,5,5]` 배열의 유효한 RLE는 `[3,8,2,5]`,
 `[3,8,0,9,2,5]`, 또는 `[2,8,1,8,2,5]`등이 될 수 있다.

 어떤 RLE 인코딩 배열이 주어졌을 때, 디코딩된 원래 배열 위를 탐색하는
 이터레이터를 구현하자.
 - `RLEIterator(int[] encoded)`: 생성자
 - `int next(int n)`: `n`개의 원래 원소를 소모하고 마지막에 소모된
   원소를 리턴한다. 소모할 원소가 더 이상 없는 경우 `-1`을 리턴한다.

 인코딩 배열은 항상 짝수 길이이며 2 ~ 1,000 사이의 길이이다. 각각의
 인코딩 값은 $$ 0 \sim 10^9$$ 사이이다. 최대 1,000번의 `next`가
 호출된다.

## 복구하기 - 메모리 아웃

 아주 간단한 아이디어로는 인코딩 배열을 직접 복원하는 방법이
 있다. 근데 이러면 당연하겠지만 엄청나게 큰 배열을 인코딩한 경우는
 메모리가 터진다.

```python
class RLEIterator:
    def __init__(self, encoding):
        self.restored = []
        i = 0
        while i < len(encoding):
            cnt, num = encoding[i], encoding[i + 1]
            self.restored += [num] * cnt
            i += 2
        self.cursor = 0

    def next(self, n):
        self.cursor += n
        if self.cursor >= len(self.restored):
            return -1
        return self.restored[self.cursor - 1]
```

## 인코딩한 채로 쿼리하기

 사실 인코딩을 굳이 풀 필요가 없다. 어차피 복잡한 인코딩도 아니고,
 그냥 *개수*를 유지하고 있기 때문에, 쿼리로 들어온 정수 `n`을 이용해서
 적절히 이 개수들을 소비하면 된다. 동형암호가 생각난다.

```python
class RLEIterator:
    def __init__(self, encoding):
        self.encoding = encoding
        self.cursor = 0

    def next(self, n):
        while self.cursor < len(self.encoding) and self.encoding[self.cursor] < n:
            n -= self.encoding[self.cursor]
            self.cursor += 2

        if self.cursor >= len(self.encoding):
            return -1

        self.encoding[self.cursor] -= n
        return self.encoding[self.cursor + 1]
```

 방법은 간단하다.
 1. 일단 `n`보다 지금 위치의 개수가 적으면 `n`에서 그 개수만큼 계속
    소모하면서 커서를 이동한다.
 2. 위의 반복문을 빠져나온 위치가 최종 소모 위치이다. 범위를
    벗어났는지 먼저 체크한다.
 3. 범위 안이라면, **지금 개수**를 적절히 소모해주고, 지금 위치의
    원소를 리턴한다.
