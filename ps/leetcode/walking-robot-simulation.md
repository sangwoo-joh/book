---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Walking Robot Simulation
---

# [Walking Robot Simulation](https://leetcode.com/problems/walking-robot-simulation/)

 무한한 XY 좌표평면 공간의 (0, 0)에서 북쪽을 향하고 있는 로봇이
 있다. 로봇은 세 종류의 `commands`가 가능하고, 이런 커맨드의 시퀀스를
 받을 수 있다:
 - `-2`: 왼쪽으로 90도 회전
 - `-1`: 오른쪽으로 90도 회전
 - `1 <= k <= 9`: `k` 만큼 앞으로 이동, 한 번에 한 칸씩 이동

 공간에는 장애물도 있다. 장애물 정보는 `obstacles`에 담겨 있고,
 `obstacles[i] = (x, y)` 위치에는 장애물이 있다. 로봇이 장애물을
 만나면 더 이상 앞으로 나아갈 수 없고, 그 다음 커맨드를 수행한다.

 로봇이 (0, 0)에서 출발해서 갈 수 있는 **유클리드 거리의 최대값의
 제곱**을 구하자. 즉, 만약 거리가 5이면 25가 답이다.

 참고로:
 - 북쪽은 +y
 - 동쪽은 +x
 - 남쪽은 -y
 - 서쪽은 -x

 커맨드 시퀀스 길이는 1~10,000 이고 -2, -1, 또는 1~9 사이의 값만 담겨
 있음이 보장된다. 장애물 배열의 크기는 0~10,000 이다. 정답은 32비트
 정수로 담을 수 있는 범위임이 보장된다.

## 시뮬레이션

 그냥 주어진 조건대로 잘 구현해서 시뮬레이션을 하면 된다. 단, 구해야
 할 값이 시뮬레이션을 완료한 로봇 위치의 유클리드 거리 제곱이 아니라,
 모든 시뮬레이션 단계 중 가능한 **최대값**임을 유의하자.

 이런 문제에서는 보통 4방향의 가속도 배열을 유지하고, 회전 시에 모듈로
 연산을 이용해서 다음 방향을 구하면 된다. 여기서는 문제의 설명에 나온
 순서대로 `북 -> 동 -> 남 -> 서` 방향의 가속도 배열을 만들면, 90도
 왼쪽 회전은 `(curdir - 1) % 4`, 90도 오른쪽 회전은 `(curdir + 1) %
 4`로 쉽게 계산할 수 있다.

```python
def robotSim(commands, obstacles):
    x, y = 0, 0
    acc = [(0,1), (1,0), (0,-1), (-1,0)]
    curdir = 0
    obstacles = set([(o[0], o[1]) for o in obstacles])
    maxdis = 0
    for cmd in commands:
        if cmd == -2:
            curdir = (curdir - 1) % 4
            continue
        if cmd == -1:
            curdir = (curdir + 1) % 4
            continue

        for _ in range(cmd):
            nx = x + acc[curdir][0]
            ny = y + acc[curdir][1]
            if (nx, ny) in obstacles:
                break
            x, y = nx, ny
            maxdis = max(maxdis, x**2 + y**2)
    return maxdis
```

 - 장애물 여부를 빠르게 체크하기 위해서 해시셋을 이용했다. 파이썬에서
   리스트는 해싱이 불가능하므로, 장애물 좌표를 튜플로 만든 후 `set()`
   연산을 이용해 해시셋으로 바꾼다.
 - 전진 커맨드의 경우 `k` 만큼 껑충 뛰면 장애물에 부딪히는지 여부를
   알기 힘들기 때문에, 여기서는 단순히 한 칸씩 전진하면서 매번 장애물
   충돌 체크를 했다.

---

 여기서 최적화할 여지가 있는 부분은 장애물 충돌 체크 부분일
 것이다. `k`가 최대 9이기 때문에, 로봇이 `k`만큼 전진할 수 있는 거리
 안에 장애물이 있는지를 확인한다면 매번 for 반복문을 돌지 않고 한번에
 껑충 뛸 수 있을 것 같다. 하지만 이건 귀찮아서 나중에...
