const int QMAX = 8'000'000;

struct Queue {
  int x, y, cnt;
}Q[QMAX];

int dx[] = { 1, 0, -1, 0 };
int dy[] = { 0, 1, 0, -1 };

int run(char map[][]) {
  int head = 0, tail = 0;
  Q[tail++] = {0, 0, 1};
  map[0][0] |= 0b001;
  while (head != tail) {
    auto [x, y, cnt] = Q[head++];
    if (head == QMAX) head = 0;
    for (int d = 0; d < 4; d++) {
      int nx = x + dx[d], ny = y + dy[d];
      if (nx < 0 || nx > 99 || ny < 0 || ny > 99) continue;
      if (check(ny, nx)) continue;
      if (map[nx][ny] & 0b001) continue;

      Q[tail++] = { nx, ny, cnt + 1 };
      if (tail == QMAX) tail = 0;
      if (arrived(ny, nx)) return cnt + 1;
      map[nx][ny] |= 0b001;
    }
  }
}
