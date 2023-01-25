---
layout: page
tags: [problem-solving, leetcode, python, tips]
title: Rotate Image
---

# [Rotate Image](https://leetcode.com/problems/rotate-image/)

 n x n 2D 매트릭스를 시계 방향으로 90도 회전할껀데,
 *제자리에서(in-place)* 회전해야 한다.

```python
# input
[[1, 2, 3],
 [4, 5, 6],
 [7, 8, 9]]

# output
[[7, 4, 1],
 [8, 5, 2],
 [9, 6, 3]]
```

## O(N) Space의 경우
 *제자리에서* 라는 제약이 없는 경우에는 어떻게 할 수 있을까? 다음 한
 줄로 가능하다:

```python
matrix = list(zip(*matrix[::-1]))
```

 - `matrix[::-1]`: 원래 2차원 배열의 순서를 뒤집는다. 즉, `[[1,2,3],
   [4,5,6], [7,8,9]]` 가 `[[7,8,9], [4,5,6], [1,2,3]]`이 된다.
 - `*`: 리스트를 풀어서 다른 함수에 넘길 수 있게 한다. 즉 `[7,8,9]`,
   `[4,5,6]`, `[1,2,3]` 이렇게 풀려버린다.
 - `zip()`: 여러개의 리스트를 같은 인덱스에 있는 것끼리 묶어준다. 즉
   `(7, 4, 1)`, `(8, 5, 2)`, `(9, 6, 3)`으로 묶이게 되고 이게 곧 90도
   회전한 결과와 같다.

## O(1) Space의 경우
 - O(N) 연산을 쪼개서 차근차근하면 된다.
 - `matrix[::-1]`는 행렬의 행(Row)을 뒤집는 연산이다. 따라서 다음과
   같이 하면 된다.

```python
def reverse(matrix):
  n = len(matrix)
  for i in range(n // 2):
    matrix[i], matrix[n-1-i] = matrix[n-1-i], matrix[i]
```

 - 중요한 건 **절반**만 Iterate 해야 한다는 것이다. 끝까지 다
   바꿔버리면 원래 행렬이랑 똑같다.

 - `zip(*)` 연산은 전치 행렬(Transpose)을 구하는 연산이다.
 - 대각선을 기준으로 바꾼다. `(i, i)` 위치가 대각선임을 기억하자.
 - 그러면 `i`번째 Row에서는 `i`부터 Column을 살펴보면 된다.
 - 그 외엔 단순히 `(x, y)`를 `(y, x)`로 스왑하는 연산이다.

```python
def transpose(matrix):
  n = len(matrix)
  for i in range(n):
    for j in range(i, n):
      matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]
```

 - 이 두 가지를 조합한 O(1) 공간 복잡도의 회전 연산은 다음과
   같다. **순서**에 주의하자.

```python
def rotate(matrix):
  reverse(matrix)
  transpose(matrix)
```
