---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Range Sum Query 2D Immutable
---

# [Range Sum Query 2D Immutable](https://leetcode.com/problems/range-sum-query-2d-immutable/)

 2차원 행렬 `matrix`가 주어질 때, 다음 쿼리를 여러 번 수행해야
 한다. 두 좌표 `(row1, col1)`, `(row2, col2)`가 주어졌을 때, `matrix`
 에서 이 두 좌표로 만들어지는 사각형 안의 원소의 합을 계산해야 한다.

 이때, 생성자와 쿼리 함수를 구현하자.

## DP

 부분 합의 2차원 버전이다. `(0, 0)`부터 `(x, y)`까지의 부분 합을 미리
 계산해두면, `(row1, col1)`과 `(row2, col2)`로 만들어지는 사각형 안의
 넓이는 다음과 같은 식을 통해서 구할 수 있다:

$$ Sum_{(row_1, col_1) \sim (row_2, col_2)} =  Partial_{(row_2, col_2)} - Partial_{(row_1 - 1, col_2)} - Partial_{(row_2, col_1 - 1)} + Partial_{(row_1 - 1, col_1 - 1)} $$

 이 식을 다음 그림과 같이 살펴보면 다음과 같다.

![partial-sum-2d](../images/partial-sum-2d.png)

 - `D`: 구하고자 하는 값 $$ Sum_{(row_1, col_1) \sim (row_2, col_b2)}
   $$
 - `A + B + C + D`: 캐싱해둔 부분 합 $$ Partial_{(row_2, col_2)} $$
 - `A + B`: 캐싱해둔 부분 합 $$ Partial_{(row_1 - 1, col_2)} $$
 - `A + C`: 캐싱해둔 부분 합 $$ Partial_{(row_2, col_1 - 1)} $$
 - `A`: 캐싱해둔 부분 합 $$ Partial_{(row_1 - 1, col_1 - 1)} $$

 즉, `D`의 구간 합을 구하기 위해서 `A + B + C + D - (A + B) - (A +
 C) + A`로 식을 바꾸고, 각각의 값을 캐싱해둔 부분 합에서 O(1) 만에
 구해서 쿼리 속도를 높이는 방식이다.

 이걸로 각 쿼리의 속도는 높일 수 있다. 그러면 이 캐싱할 부분 합은
 어떻게 구할 수 있을까? 보통 다이나믹 프로그래밍에서 메모이제이션은 탑
 다운 방식과 바텀 업 방식의 두 종류가 있는데, 문제의 조건에 따라
 적절한 것을 선택하면 된다. 이 문제에서, 2차원 행렬의 최대 크기는 `200
 x 200`이고, 쿼리는 최대 10,000 만큼 불리기 때문에, 탑 다운 방식 (온
 디맨드)로 구하면 테스트 케이스에 따라 시간 초과가 날 수 있다. 최대
 가능한 파라미터 수는 40,000인데 쿼리가 10,000 이기 때문이다. 따라서
 여기서는 바텀 업 방식으로 부분 합을 초기화 함수에서 직접 구하는게 더
 좋다.

 바텀 업 방식으로 부분 합을 캐싱하는 것은, 위의 식에서 `row2 = row1 +
 1`, `col2 = col1 + 1`로 생각하여, 즉 1씩 증가하는 경우에 대해서
 생각하면 쿼리를 구하는 방식과 거의 동일하게 쌓아나갈 수 있다. `row`와
 `col`만 가지고 이를 수식으로 적으면 다음과 같다.

$$ Partial_{(row + 1, col + 1)} =  Partial_{(row + 1, col)} + Partial_{(row, col + 1)} + Matrix_{(row, col)} - Partial_{(row, col)} $$

 역시 이 식을 아래 그림과 함께 보면 다음과 같다.

![partial-sum-init](../images/partial-sum-init.png)

 - 구하고자 하는 값 $$ Partial_{(row + 1, col + 1)} $$ 은 `A+B+C+D`의
   값이다. 이때, 한 칸씩 구하기 때문에 `D`는 곧 `matrix[row][col]` 한
   칸의 값과 같다.
 - `A+C`와 `A+B`, `A`의 식은 이전과 동일하다.
 - 여기서는 `D`가 아니라 `A+B+C+D`를 구하는 것이 목표이기 때문에 식이
   살짝 바뀌었다. 즉, `A+B+C+D = (A+C) + (A+B) + D - A`가 된다.

 이 아이디어를 종합하여 코드를 완성하면 다음과 같다.

```python
class NumMatrix:
    def __init__(self, matrix):
        m, n = len(matrix), len(matrix[0])
        self.partial = [[0] * (n+1) for _ in range(m+1)]
        for x in range(m):
            for y in range(n):
                self.partial[x+1][y+1] = self.partial[x+1][y] + self.partial[x][y+1] + matrix[x][y] - self.partial[x][y]

    def sumRegion(self, row1, col1, row2, col2):
        return self.partial[row2+1][col2+1] - self.partial[row1][col2+1] - self.partial[row2+1][col1] + self.partial[row1][col1]
```

 - 인덱스에 주의하자. 부분 합은 아무것도 포함하지 않은 베이스 케이스
   0이 필요하기 때문에, row와 column 모두 한 칸씩 더 필요하다. 따라서
   `self.partial[x][y]`의 의미는 `(0, 0)`부터 `(x-1, y-1)`의 사각형
   안의 부분합이 된다. 따라서, 쿼리에서 인덱스를 주의해야 한다.
