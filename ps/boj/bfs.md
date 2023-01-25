---
layout: page
tags: [problem-solving, boj, python, graph]
title: Breadth First Search
---

{: .no_toc }
## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

# BFS
## Deque
 파이썬에는 `collections` 패키지 안에 `deque`가 있으므로 다음
 인터페이스를 숙지해야 한다.
 - `deque()`: 생성자
 - `deque.append(x)`: 끝
 - `deque.appendleft(x)`: 앞
 - `deque.pop()`: 끝
 - `deque.popleft()`: 앞

 따라서, "큐"의 Functionality를 얻으려면 `append()`와 **popleft()**를
 써야한다. `pop()`을 써버리면 스택과 다름없다.

## 연관 키워드
 길 찾기, 최소 경로 찾기,

## 정석
 1. 큐, 집합 초기화
 2. 시작 지점을 하나 잡아서, 큐와 집합에 둘다 넣는다.
 3. 큐가 빌 때까지 다음을 반복한다:
    1. 앞에서 하나 pop 한다.
    2. pop한 원소에서 갈 수 있는 다음 지점을 전부 훑어본다.
    3. 다음 지점이 *집합에 없으면* (즉, 방문하지 않았으면), 큐와
       집합에 둘다 넣는다.

 BFS에서 주의해야 할 부분은 루프 안에서 큐에 다음 지점을 **넣기 전에**
 방문 체크를 해야한다는 점이다. 꺼내서 방문 체크 해도 말은 되지만
 이러면 시간 복잡도가 터진다.

## [1926번: 그림](https://www.acmicpc.net/problem/1926)

```python
import sys
from collections import deque
line = sys.stdin.readline

n, m = map(int, line().rstrip().split())
graph = []
for _ in range(n):
    graph.append(line().rstrip().split())

visited, max_area, total_count = set(), 0, 0
def bfs(y, x):
    q = deque()
    visited.add((y, x))
    q.append((y, x))
    area = 1
    while q:
        y, x = q.popleft()
        for ny, nx in ((y+1, x), (y-1, x), (y, x+1), (y, x-1)):
            if 0 <= ny < n and 0 <= nx < m and graph[ny][nx] == '1' and (ny, nx) not in visited:
                visited.add((ny, nx))
                q.append((ny, nx))
                area += 1
    return area

# check all
for y in range(n):
    for x in range(m):
        if graph[y][x] == '1' and (y, x) not in visited:
            total_count += 1
            max_area = max(max_area, bfs(y, x))

print(total_count)
print(max_area)
```

 위의 클래식을 잘 고려해서 bfs를 짜면 된다. 파이써닉하게 짠 부분은 (1)
 방문 체크할 때 내장 해쉬셋과 내장 튜플을 곧바로 이용한 점, (2) 다음
 지점을 구할 때 상하좌우 다음 좌표를 곧바로 튜플로 계산한 것, 그리고
 (3) 다음 지점의 바운드 체크를 할 때 체인 비교 연산자를 쓴 것이다.

 한 그림의 어느 지점에서 시작하던지 간에 `bfs`가 호출되고 나면 그
 그림의 모든 좌표를 방문하게 되므로 처음 방문할 때 `total_count`를
 늘리면 된다.

 그림의 크기는 `bfs`에서 큐에 넣을 때마다, 혹은 방문했다고 기록할
 때마다 크기가 1씩 증가하므로 이 사실을 이용해서 계속 누적해 나아가면
 된다.

## [2178번: 미로 탐색](https://www.acmicpc.net/problem/2178)

```python
import sys
from collections import deque

n, m = map(int, sys.stdin.readline().rstrip().split())
board = []
for _ in range(n):
    board.append(sys.stdin.readline().rstrip())

path = [[0 for _ in range(m)] for _ in range(n)]
q = deque()

q.append((0, 0))
path[0][0] = 1

while q:
    cy, cx = q.popleft()
    for y, x in ((cy+1, cx), (cy-1, cx), (cy, cx+1), (cy, cx-1)):
        if y < 0 or y >= n or x < 0 or x >= m:
            continue
        if board[y][x] == '0' or path[y][x] != 0:
            continue
        path[y][x] = path[cy][cx] + 1
        q.append((y, x))

print(path[n-1][m-1])
```

 최단 경로를 구할 때 BFS를 활용할 수 있다. 방문 체크를 집합으로 하지
 않고, 원래의 맵과 똑같은 사이즈의 맵을 만든 뒤 여기에 경로를 기록하면
 된다. 이런 문제에서는 보통 시작점은 주어지기 때문에, 이 경로 맵에는
 시작점으로부터 해당 위치까지의 경로를 계속 기록하면 된다. 그러면
 BFS의 특성 상 경로 맵을 다 채우고 나면 시작점으로부터 모든 점까지의
 최단 경로를 알 수 있다.

 이를 위해서 `path`를 만들 때, 파이썬에서는 위와 같이 `range`를
 이용해서 만들어줘야 한다. 그냥 곱 연산으로 `[[0] * m] * n` 처럼
 만들면, 처음 `m` 만큼은 깊은 복사가 일어나지만 이후 이 리스트를
 `n`만큼 곱할 때에는 얕은 복사가 일어나기 때문에 제대로 된 경로를
 계산하지 못한다.

 이 점만 주의하면 나머지는 Trivial 하다.

## [7576번: 토마토](https://www.acmicpc.net/problem/7576)

```python
import sys
from collections import deque
load = lambda: sys.stdin.readline().rstrip().split()
n, m = map(int, load())
box = []
for _ in range(m):
    box.append(load())

ripes, total = 0, 0
path = [[-1 for _ in range(n)] for _ in range(m)]
q = deque()

for y in range(m):
    for x in range(n):
        if box[y][x] != '-1':
            total += 1
        if box[y][x] == '1':
            ripes += 1
            q.append((y, x))
            path[y][x] = 0

while q:
    y, x = q.popleft()
    for ny, nx in ((y+1,x), (y-1,x), (y,x+1), (y,x-1)):
        if 0 <= ny < m and 0 <= nx < n and box[ny][nx] == '0' and path[ny][nx] == -1:
            q.append((ny, nx))
            path[ny][nx] = path[y][x] + 1
            ripes += 1

if ripes != total:
    print(-1)
else:
    elapsed = 0
    for p in path:
        elapsed = max(elapsed, max(p))
    print(elapsed)
```

 문제를 잘 읽어보면 BFS로 시뮬레이션 할 수 있음을 알 수 있다. 익은
 토마토부터 시작해서 모든 경로의 최단 거리를 구하고 그 중 가장 큰 값이
 답이다. 마찬가지로 시작점이 여러 개일 수 있는데, 이것도 미리 구해서
 큐에 넣어두면 된다.

 주의해야 할 한 가지는, 익지 않는 토마토 체크(일종의 Reachability
 체크)를 따로 해줘야 한다는 점이다. 여기서는 그냥 손쉽게 전체 토마토
 개수랑 익은 토마토 개수를 구해서 비교했다.

## [4179번: 불!](https://www.acmicpc.net/problem/4179)
 지훈이가 옮겨다닐 때 불을 끌 수 없다는 강력한 제약 조건 덕분에 BFS 두
 번 돌려서 풀 수 있는 문제다. 즉, 시작 지점이 두 개인 BFS이면서 동시에
 서로 영향을 주지 않는다.

```python
import sys
from collections import deque
load = lambda: sys.stdin.readline().rstrip()
r, c = map(int, load().split())
labyrinth = []
for _ in range(r):
    labyrinth.append(load())

fire_q = deque()
fire_map = [[-1 for _ in range(c)] for _ in range(r)]
jihun_q = deque()
jihun_run = [[-1 for _ in range(c)] for _ in range(r)]

# 일단 불과 지훈이를 찾아야 한다.
for y in range(r):
    for x in range(c):
        if labyrinth[y][x] == 'J':
            jihun_q.append((y, x))
            jihun_run[y][x] = 0
        elif labyrinth[y][x] == 'F':
            fire_q.append((y, x))
            fire_map[y][x] = 0

# 먼저 불을 시뮬레이션 한다.
while fire_q:
    y, x = fire_q.popleft()
    for ny, nx in ((y+1,x), (y-1,x), (y,x+1), (y,x-1)):
        if 0 <= ny < r and 0 <= nx < c and labyrinth[ny][nx] != '#' and fire_map[ny][nx] == -1:
            fire_q.append((ny, nx))
            fire_map[ny][nx] = fire_map[y][x] + 1

# 지훈이를 달리게 하면서 시간을 기록한다.
escaped_time = None
while jihun_q:
    y, x = jihun_q.popleft()
    this_turn = jihun_run[y][x] + 1
    for ny, nx in ((y+1,x), (y-1,x), (y,x+1), (y,x-1)):
        if ny < 0 or ny >= r or nx < 0 or nx >= c:
            # 범위 밖으로 빠져나온 건 탈출에 성공했다는 얘기다.
            escaped_time = this_turn
            break
        if labyrinth[ny][nx] == '#' or jihun_run[ny][nx] != -1:
            # 갈 수 없는 길이거나, 이미 더 빨리 올 수 있으면 다음으로
            continue
        if fire_map[ny][nx] == -1 or this_turn < fire_map[ny][nx]:
            # case 1: 불이 아예 못오거나
            # case 2: 이번 턴에 불 보다 빨리 갈 수 있어야 갈 수 있다.
            jihun_run[ny][nx] = this_turn
            jihun_q.append((ny, nx))
    if escaped_time:
        break

print(escaped_time if escaped_time else "IMPOSSIBLE")
```

 따라서, 먼저 불을 BFS로 시뮬레이션해서 불이 퍼져나가는 시간을 전부
 기록한 다음, 지훈이를 조심스럽게 달리게 하면 된다. 불을 퍼뜨리는 것은
 일반적인 BFS라서 그냥 하면 되고, 지훈이는 다음 턴에 달릴 때 다음과
 같은 조건을 살펴봐야 한다.
 - 탈출 성공: 미로 범위 바깥으로 나가게 되면 탈출 성공이다.
 - 탈출 시간: 지훈이가 BFS로 옮겨다니는 시간을 기록해뒀다면,
   빠져나가는 순간의 시간은 `직전 위치의 시간 + 1`이다.
 - 옮겨갈 수 있는 위치: 불이 아예 못오는 경우도 고려해야 한다. 불과
   지훈이가 벽으로 분리되어 있는 경우가 해당한다.

## [1697번: 숨바꼭질](https://www.acmicpc.net/problem/1697)
 이게 BFS인가? 싶은데 문제를 잘 읽어보면 결국 시뮬레이션으로 최단
 거리를 구하는 문제로 환원할 수 있어서 BFS를 적용해볼 수 있다.

```python
import sys
from collections import deque
n, k = map(int, sys.stdin.readline().rstrip().split())

def bfs(n, k):
    if n == k:
        return 0
    q = deque()
    q.append(n)
    time = {n: 0}

    while q:
        now = q.popleft()
        for after in (now+1, now-1, 2*now):
            if after < 0 or after > 100000:
                continue
            if after == k:
                return time[now] + 1
            if after in time:
                continue
            time[after] = time[now] + 1
            q.append(after)

print(bfs(n,k))
```

 - 코너 케이스 하나를 잘 고려해야 한다. 시작부터 수빈이랑 동생이 같은
   지점에 있으면 0초만에 찾을 수 있다.
 - 움직일 수 있는 범위가 0과 100000 사이인데, 수빈이가 이 범위를
   벗어나도록 움직이면 최단 시간 안에 동생을 찾을 수 없으므로 제외해야
   한다. 그리고 이렇게 제외를 해야 수빈이가 움직이는 시간에 대한
   기록을 덜 해서 메모리 초과가 나지 않는다.
