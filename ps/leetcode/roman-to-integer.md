---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Roman to Integer
---

# [Roman to Integer](https://leetcode.com/problems/roman-to-integer/)

 로마 숫자는 다음 일곱 개의 심볼을 가지고 표현한다:

| Symbol | Value |
| --- | --- |
| `I` | 1 |
| `V` | 5 |
| `X` | 10 |
| `L` | 50 |
| `C` | 100 |
| `D` | 500 |
| `M` | 1000 |

 예를 들어 `II`는 2다. 보통 왼쪽에서 오른쪽으로 큰 순서대로
 표현된다. 하지만 아닌 경우도 있는데, 예를 들어 4의 경우 `IIII`가
 아니라 `IV`로 표시하고 "5에서 1을 뺀 값"으로 해석한다. 이렇게 뺀
 값으로 표시하는 것은 여섯 가지의 경우가 있다.

 - `I`는 `V`앞에 와서 4(5-1), `X`앞에 와서 9(10-1)
 - `X`는 `L`앞에 와서 40(50-10), `C`앞에 와서 90(100-10)
 - `C`는 `D`앞에 와서 400(500-100), `M`앞에 와서 900(1000-100)

 로마 숫자 표기가 주어졌을 때 정수로 바꾸는 함수를 구현하자.

 표기 길이는 1 ~ 15 사이이고 유효한 로마 숫자 심볼만 포함한다. 입력
 표기는 1 ~ 3999 사이의 유효한 정수를 표현한 로마 숫자 표기임이
 보장된다.


## 접근

 1. 해시 테이블: 기본 심볼에서 정수로 가는 해시 테이블은 반드시 필요하다.
 2. 빼는 경우 처리: 주어진 6가지 경우를 일일이 처리해도 무방하다. 좀더
    일반적인 케이스를 생각해보면, 어떤 인덱스 `i`에서의 값과 그 다음
    인덱스 `i+1`의 값이 감소하는 경우에 빼는 케이스가 된다. 이 사실을
    이용하면 6가지 케이스를 다 구현하지 않아도 된다.

```python
def romanToInt(s):
    mapping = {
        'I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500, 'M': 1000
    }
    res = 0
    i = 0
    while i < len(s):
        if (i+1) < len(s) and mapping[s[i]] < mapping[s[i+1]]:
            # subtract case
            res += (mapping[s[i+1]] - mapping[s[i]])
            i += 2
        else:
            res += mapping[s[i]]
            i += 1

    return res
```
