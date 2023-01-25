---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Pascal's Triangle
---

# [Pascal's Triangle](https://leetcode.com/problems/pascals-triangle/)

 `numRows`가 주어졌을 때 파스칼의 삼각형을 그리자.

![tri](https://upload.wikimedia.org/wikipedia/commons/0/0d/PascalTriangleAnimated2.gif)

 1~30 사이의 값이 들어온다.

## 기초적인 디피

 아주 기초적인 디피이다. 잘 보면 다음 사실을 알 수 있다.
 - `row` 줄에는 `row`개의 원소가 있다. (1-indexed)
 - `row` 줄의 양 끝 원소는 항상 1이다.
 - `(row, i)` 원소는 `(row - 1, i - 1)` 원소와 `(row - 1, i)` 원소의
   합이다.

 정직하게 구현해보자.

```python
def generate(numRows: int) -> List[List[int]]:
    pascal = []
    for row in range(numRows):
        line = [None] * (row + 1)
        line[0], line[-1] = 1, 1
        for i in range(1, len(line) - 1):
            line[i] = pascal[row-1][i-1] + pascal[row-1][i]
        pascal.append(line)
    return pascal
```
