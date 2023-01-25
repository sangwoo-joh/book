---
layout: page
tags: [problem-solving, leetcode, python, heap]
title: Find Median from Data Stream
---

# [Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/)

 배열에서 **중앙값(median)**이란 정렬된 배열의 중간에 위치한
 값이다. 배열 사이즈가 홀수면 정중앙의 값이고, 짝수이면 중간의 두 값의
 평균값이다.
 - `[2,3,4]`의 중앙값은 `3`
 - `[2,3]`의 중앙값은 `(2+3)/2 = 2.5`

 데이터가 스트림처럼 계속 들어오는 상황에서 중앙값을 찾는 쿼리를
 처리해주는 `MedianFinder` 클래스를 구현하자.
 - `MedianFinder()` 생성자는 오브젝트를 초기화한다.
 - `void addNum(int num)`은 정수 `num`을 데이터 스트림에 추가한다.
 - `double findMedian()`은 지금까지 추가된 스트림에서 중앙값을
   계산한다. 오차 범위 $$10^{-5}$$ 까지는 허용된다.

 `num`의 값은 -100,000~100,000 사이이고, `findMedian()` 함수가 불리기
 전에 최소 한번의 `addNum` 함수가 호출됨이 보장된다. 최대 $$ 5 \times
 10^4 $$ 만큼의 함수 호출이 이뤄진다.


## 정렬

 가장 먼저 떠오르는 방법은 AVL트리나 레드블랙트리 같은 BST에 데이터
 스트림을 계속 보관하고 중앙값 쿼리가 올 때마다 이 트리로부터 중간
 위치의 원소를 가져오는 방법이다. 하지만, 아쉽게도 파이썬의 표준
 라이브러리에는 이런 Self-Adjusting 트리가 없다.

 그럼 다음으로 생각할 수 있는 방법은, 그냥 무작정 배열에 넣다가 중앙값
 쿼리 요청이 올 때마다 매번 정렬하는 것이다. 파이썬의 정렬은 [팀
 정렬](https://d2.naver.com/helloworld/0315536)로 구현되어 있는데,
 삽입 정렬과 병합 정렬을 합친 하이브리드 정렬이다. 실제로는 [더 복잡한
 구현](https://github.com/python/cpython/blob/976dec9b3b35fddbaa893c99297e0c54731451b5/Objects/listsort.txt)이
 되어있지만, 아무튼 리얼 월드 데이터를 정렬하는데 엄청나기 최적화되어
 있어서, 이렇게 매번 정렬하면 이론적인 복잡도는 O(KNlogN) (K는 함수
 호출 횟수)이겠지만 생각보다는 괜찮을지도 모른다.

```python
class MedianFinder:
    def __init__(self):
        self.data = []

    def addNum(self, num):
        self.data.append(num)

    def findMedian():
        self.data.sort()
        n = len(self.data)
        if n % 2 == 0:
            return (self.data[n//2] + self.data[n//2 - 1]) / 2
        else:
            return self.data[n//2]
```

 실제로 매우 느리긴 하지만 통과하긴 한다.

## 힙

 그러면 더 최적화된 방법은 뭘까? 정확히는 어떤 데이터 구조를 쓰면 이걸
 최적화할 수 있을까? 한 가지 방법은 들어오는 데이터 스트림, 즉 정수의
 배열을 두 묶음으로 나눠 생각하는 것이다. 우리는 정렬된 배열의 중간
 원소에만 관심이 있다. 그러면 이 중간 원소를 기준으로 왼쪽 절반과
 오른쪽 절반을 따로 관리하면 어떨까? 구체적으로는, 힙을 이용해서, 왼쪽
 절반은 죄다 최대힙에 넣고, 오른쪽 절반은 최소힙에다 넣으면, 양쪽 힙의
 Top에 있는 값을 이용해서 중앙값을 구할 수 있을 것 같다.

 이 아이디어를 좀더 구체화해서, 정확한 Invariant를 이끌어내보자.
 1. 최소힙의 크기는 최대힙과 같거나, 정확히 하나 더 크다. (반대여도
    상관없다)
 2. 최대힙의 최대원소는 최소힙의 최소원소보다 작거나 같다. 즉, Top의
    원소끼리 순서가 보장된다.

 이렇게 하면 (정렬된) 배열의 중간값은 이 두 힙으로부터 구할 수
 있다. 만약 배열의 크기가 홀수라면 최소힙에(최대힙을 더 크게한 경우는
 최대힙에), 짝수라면 최소힙과 최대힙의 Top원소의 평균값을 구하면
 된다. O(logN)의 복잡도가 든다.

 추가하는 작업은 조금 까다롭다. 두 Invariant를 유지하도록 해야하기
 때문이다. 단순하게 하려면 먼저 둘 중 한 곳에 원소를 추가하고 1을
 확인한 후에 2를 확인하면 된다. 만약 2가 깨졌다면, 두 힙의 Top 값을
 서로 뒤바꿔준다. 숫자를 하나씩 힙에 추가하기 때문에, 한 번만 숫자를
 바꿔도 2의 Invariant가 유지된다. 이 역시 O(logN)의 복잡도가 드므로,
 총 함수 횟수에 대해서 O(KlogN)의 복잡도가 든다. 정렬 방법과 비교해
 N이 빠진 만큼 아주 빠를 것으로 기대한다.

 이 아이디어를 구현해보자. 파이썬의 `heapq` 라이브러리는 기본적으로는
 배열을 기준으로 동작하며, 최소힙만을 구현하기 때문에 최대힙의 경우
 부호를 뒤집어서 키 값으로 주면 된다.

```python
import heapq
class MedianFinder:
    def __init__(self):
        self.left = []
        self.right = []

    def addNum(self, num):
        # invariant 1
        if len(self.left) == len(self.right):
            heapq.heappush(self.left, (-num, num))
        else:
            heapq.heappush(self.right, (num, num))

        # invariant 2
        if self.left and self.right and not (self.left[0][1] < self.right[0][1]):
            topl, topr = heapq.heappop(self.left), heapq.heappop(self.right)
            heapq.heappush(self.left, (-topr[0], topr[1]))
            heapq.heappush(self.right, (-topl[0], topl[1]))

    def findMedian(self):
        if len(self.left) == len(self.right):
            return (self.left[0][1] + self.right[0][1]) / 2
        else:
            return self.left[0][1]
```

 - `left`는 최대힙, `right`는 최소힙이다. `heapq`는 기본적으로
   최소힙이므로 `left`에 값을 넣을 때 키 값으로 `-num`을 줬다. 힙에
   들어가는 데이터의 타입을 맞추기 위해서 `right`에도 튜플을 추가한다.
 - 한 가지 주의할 점은 Invariant 2를 확인할 때 최대힙과 최소힙이
   비어있는지를 같이 확인해야 한다는 점이다. 문제의 조건에
   `findMedian`이 호출되기 전에 최소 1번의 `addNum`이 호출된다고
   나와있기 때문에 둘 중 하나는 비어있을 수도 있다.
 - 왼쪽 절반을 하나 더 크게 유지하고 있기 때문에 배열이 홀수인 경우는
   왼쪽의 Top이 중앙값이다.
