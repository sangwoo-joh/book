---
layout: page
tags: [problem-solving, leetcode, python, array, heap]
title: Maximum Units on a Truck
---

# [Maximum Units on a Truck](https://leetcode.com/problems/maximum-units-on-a-truck/)

 한 대의 트럭에 박스를 실으려고 한다. 박스 정보가 배열 `boxTypes`로
 주어지는데, `boxTypes[i] = (numberOfBoxes_i, numberOfUnitsPerBox_i)`
 이고 다음과 같다:

  - `numberOfBoxes_i`: `i` 타입 박스의 개수
  - `numberOfUnitsPerBox_i`: `i` 타입 박스 당 유닛의 개수

 트럭에 최대로 실을 수 있는 박스 개수인 `truckSize`도 함께
 주어진다. 이 사이즈만 넘지않으면 어떤 박스를 넣어도 상관없다.


 이때, 이 트럭에 실을 수 있는 **유닛의 최대 수**를 구하자.

 박스 정보 배열 크기는 1 ~ 1,000 사이이고 각 박스 타입 원소도 1 ~
 1,000 이다. 트럭 사이즈는 $$ 1 \sim 10^6 $$ 이다.

## 그리디하게 정렬

 트럭에 실을 수 있는 박스는 박스 안의 유닛과 상관없기 때문에, 여기서는
 그리디하게 가장 많은 유닛이 들어있는 박스부터 채워넣으면 된다. 그럼
 가장 먼저 떠올릴 수 있는 방법은 정렬하는 것이다.

```python
def maximumUnits(boxTypes, truckSize):
    units = 0
    for box, unit in sorted(boxTypes, key=lambda x: -x[1]):
        if truckSize - box >= 0:
            units += (unit * box)
            truckSize -= box
        else:
            units += (unit * truckSize)
            truckSize = 0
        if truckSize == 0:
            break
    return units
```

 정직한 문제 정직한 구현을 했다. 정렬할 때 키 값을 음수로 줘야 가장 큰
 유닛이 온다는 것 외에는 조심할 것이 없다. 정렬에 가장 많은 연산을 할
 것이므로 복잡도는 `O(NlogN)`이다.

## 그리디하게 힙

 좀더 힙한 방법은 힙을 쓰는 것이다. 가장 유닛이 많이 든 빢스부터 채워
 넣어야 하니 여기서는 최대 힙을 유지하자.

```python
import heapq
def maximumUnits(boxTypes, truckSize):
    maxheap = [(-bt[1], bt[0]) for bt in boxTypes]
    heapq.heapify(maxheap)
    units = 0
    while maxheap and truckSize:
        unit, box = heapq.heappop(maxheap)
        if truckSize - box >= 0:
            units += -unit * box
            truckSize -= box
        else:
            units += -unit * truckSize
            truckSize = 0
    return units
```

 파이썬에는 최대 힙이 없기 때문에 키 값으로 유닛의 음수 값을
 넘겨줬다. 따라서 힙에서 꺼냈을 때 다시 음수로 부호를 바꿔줘야 올바른
 유닛 값이 된다. 그리고 파이썬의 힙(`heapq`)은 원소가 튜플일 때 첫
 번째 원소를 가지고 우선순위를 비교하기 때문에 곧바로 `heapify`를 할
 수 있다.

---

 정직하게 구현했는데 좀더 간결하게 구현할 순 없을까? 잘 살펴보면
 다음과 같은 사실을 알 수 있다.
 - `truckSize >= box` 일 때 `unit * box`를, `truckSize < box`일 때
   `unit * truckSize`를 누적하고 있다. `unit`은 같고 곱하는 수만
   달라지고 있는데 잘 보면 `box`가 더 작을 때 `box`를, `truckSize`가
   더 작을 때 `truckSize`를 곱하고 있다. 따라서 이 둘 중 더 작은 값을
   곧바로 곱할 수 있다.
 - `truckSize`를 업데이트하는 것도 마찬가지 인데, `box`와 `truckSize`
   중 더 작은 값을 빼고 있다.

 따라서 다음과 같이 코드를 줄일 수 있다.

```python
def maximumUnits(boxTypes, truckSize):
    maxheap = [(-bt[1], bt[0]) for bt in boxTypes]
    heapq.heapify(maxheap)
    units = 0
    while maxheap and truckSize:
        unit, box = heapq.heappop(maxheap)
        unit = -unit
        units += unit * min(box, truckSize)
        truckSize -= min(box, truckSize)
    return units
```
