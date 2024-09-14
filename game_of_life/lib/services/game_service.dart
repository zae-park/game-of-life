// lib/services/game_service.dart

class GameService {
  static List<List<int>> nextGeneration(
      List<List<int>> current, int rows, int cols) {
    List<List<int>> newBoard = List.generate(
      rows,
      (_) => List.generate(cols, (_) => 0),
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int liveNeighbors = countLiveNeighbors(current, i, j, rows, cols);
        if (current[i][j] == 1) {
          if (liveNeighbors == 2 || liveNeighbors == 3) {
            newBoard[i][j] = 1; // 살아남음
          } else {
            newBoard[i][j] = 0; // 죽음
          }
        } else {
          if (liveNeighbors == 3) {
            newBoard[i][j] = 1; // 번식
          }
        }
      }
    }

    return newBoard;
  }

  static int countLiveNeighbors(
      List<List<int>> board, int row, int col, int rows, int cols) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue; // 자기 자신은 제외
        int newRow = row + i;
        int newCol = col + j;
        if (newRow >= 0 &&
            newRow < rows &&
            newCol >= 0 &&
            newCol < cols &&
            board[newRow][newCol] == 1) {
          count++;
        }
      }
    }
    return count;
  }
}
