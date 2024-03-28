#include <iostream>

static auto _ = []() {
  std::ios::sync_with_stdio(false);
  std::cin.tie(nullptr);
  return 0;
}();

char board[6][6];
char words[11][11];

const int d[8][2] = {{-1, -1}, {-1, 0}, {-1, 1}, {0, 1},
                     {1, 1},   {1, 0},  {1, -1}, {0, -1}};

inline bool in_range(int y, int x) {
  return 0 <= y && y < 5 && 0 <= x && x < 5;
}

bool has_word(int y, int x, const char *word) {
  if (*word == '\0')
    return true;
  if (!in_range(y, x))
    return false;
  if (board[y][x] != *word)
    return false;

  for (int dir = 0; dir < 8; dir++) {
    int ny = y + d[dir][0], nx = x + d[dir][1];
    if (has_word(ny, nx, word + 1))
      return true;
  }

  return false;
}

int main() {
  int C;
  std::cin >> C;
  while (C--) {
    for (int i = 0; i < 5; i++) {
      std::cin >> board[i];
    }
    int N;
    std::cin >> N;
    for (int i = 0; i < N; i++) {
      std::cin >> words[i];
    }

    for (int i = 0; i < N; i++) {
      bool found = false;
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          if (has_word(y, x, words[i])) {
            found = true;
            break;
          }
        }
        if (found)
          break;
      }
      std::cout << words[i] << " " << (found ? "YES" : "NO") << "\n";
    }
  }

  return 0;
}
