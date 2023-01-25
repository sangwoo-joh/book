---
layout: page
tags: [problem-solving, leetcode, python, interval]
title: Merge Intervals
last_update: 2023-01-25 18:33:30
---

# [Merge Intervals](https://leetcode.com/problems/merge-intervals/)

 범위 `interval`이 `(startg, end)`로 정의되고 이 범위의 배열이
 입력으로 들어올 때, 배열 안의 범위 중 서로 겹치는 모든 범위를 합쳐서
 원래 입력의 범위를 모두 커버하면서 겹치는 부분이 없는 범위의 배열을
 만들자.

 예를 들어서, `[(1,3), (2,6), (8,10), (15,18)]` 이 있으면 `(1,3)`과
 `(2,6)`의 범위가 겹치기 때문에 최종 출력은 `[(1,6), (8,10),
 (15,18)]`이 된다.

 범위의 범위는 0~10000이고 입력 배열의 크기는 최소 1, 최대 10000이다.


## O(NlogN)

 입력 배열이 정렬되어 있다는 말이 없기 때문에, 합칠 범위를 찾으려면
 정렬이 필수적이다. 따라서 복잡도는 잘해봐야 O(N*logN)일 수 밖에 없다.

 범위의 시작 지점을 기준으로 정렬한 배열 `ordered`를 만든다. 그리고
 범위를 합쳐둘 `merged` 배열에 `ordered`의 첫 번째 원소를 일단
 넣어둔다. 문제에서 길이가 최소 1이 보장되기 때문에 특별히 널 체크는
 하지 않아도 된다.

 그 후 `ordered`의 두 번째 원소부터 꺼내가면서 `merged` 배열의 제일
 마지막 원소와 비교하면서 범위가 합쳐지는지를 확인하면서 `merged`를
 업데이트 해 나간다. 이때 가능한 케이스는 크게 두 가지이다.
 1. `merged`의 마지막 범위와 겹치지 않는 경우: 이 때는 그냥 범위를
    추가하면 된다.
 2. `merged`의 마지막 범위와 겹치는 경우: 즉, 이 경우는 `merged`의
    마지막 범위의 끝 값과 추가하려는 범위의 시작 값이 겹치는
    경우이다. 이 때는 `merged` 마지막 범위의 끝 값을 확장해줘야
    하는데, 여기서도 두 가지 경우가 있다.
    1. `merged`의 끝 범위가 더 큰 경우
    2. `merged`의 끝 범위가 더 작은 경우

 위의 아이디어를 구현하면 다음과 같다.

```python
def merge(intervals):
    ordered = sorted(intervals, key=lambda x: x[0])
    merged = [ordered[0]]

    for itv in ordered[1:]:
        top = merged[-1]
        if itv[0] <= top[1]:  # overlapping
            merged[-1][1] = max(itv[1], merged[-1][1])
        else:
            merged.append(itv)

    return merged
```

  - 추가할 범위가 겹칠 때, 끝 값을 업데이트 하는 방법은 두 케이스 중
    그냥 더 큰 값으로 덮어버리면 되므로 `max` 연산을 쓰면 된다.
