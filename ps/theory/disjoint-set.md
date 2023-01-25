---
layout: page
tags: [problem-solving, theory, disjoint-set]
title: Disjoint Set
---

# 서로소 집합

 위키피디아 구현은 다음과 같다.

```
function MakeSet(x)
  x.parent := x

function Find(x)
  if x.parent == x
    return x
  else
    return Find(x.parent)

function Union(x, y)
  xRoot := Find(x)
  yRoot := Find(y)
  xRoot.parent := yRoot
```

## 최적화
 1. Union by Rank: Rank를 기록해서, `Union` 연산을 할 때 항상 더 작은
    길이의 트리를 더 큰 길이의 트리에 합치는 방법이다.
 2. Path Compression: `Find` 연산을 할 때마다, 모든 속한 원소의 부모를
    하나의 대표 원소를 가리키게 하는 방법이다.

 문제 풀이 수준에서 Union by Rank는 큰 효과가 없고, Path Compression만
 해줘도 충분하다. 물론 프로덕션 레벨에서 서로소 집합을 엄청 오래
 유지하는 거라면 두 최적화 모두 필요하다.

## 구현

```python
class DisjointSet:
    def __init__(self):
        self._reps = dict()
        self._count = 0
        self._elts = defaultdict(list)

    def __len__(self):
        return self._count

    def make_set(self, x):
        if x not in self._reps:
            self._reps[x] = x
            self._count += 1
            self._elts[x].append(x)

    def find(self, x):
        if x != self._reps[x]:
            self._reps[x] = self.find(self._reps[x])

        return self._reps[x]

    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        # always merge smaller one into larger one
        if len(self._elts[px]) > len(self._elts[py]):
            px, py = py, px
        self._reps[px] = py
        self._elts[py].extend(self._elts[px])
        self._elts[px] = []
        self._count -= 1
        return True
```

 위의 구현은 서로소 집합의 개수 `_count`와 각 집합의 원소 정보
 `_elts_`도 같이
 추적한다([출처](https://pstopia.github.io/notes/data-structure/disjoint-set/)). 이
 두 가지를 추적하지 않는 경우 `find`와 `union`의 시간 복잡도는 아커만
 함수로 거의 선형 시간이다. `_count`는 복잡도에 영향을 주지
 않는다. `_elts`를 추적하는 경우는 항상 작은 쪽에 합치는 구현을 하면
 `union`의 복잡도는 `O(n*logn)`이 된다.

 `union`의 리턴 값은 두 원소가 합쳐졌는지 아닌지 여부다.
