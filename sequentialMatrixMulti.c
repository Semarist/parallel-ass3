#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// to compile: gcc -o sequential sequential_matrix_mult.c
// to run: ./sequential width_M Length_M Length_N

void main(int argc, char *argv[]) {
  if (argc != 4) {
    fprintf(stderr, "%s requires 3 arguments\n", argv[0]);
  } else {
    float time;
    clock_t start, end;

    start = clock();

    int row_m = atoi(argv[1]);
    int col_m = atoi(argv[2]);
    int col_n = atoi(argv[3]);

    int **matrix_a = malloc(row_m * sizeof(int *));
    for (int i = 0; i < row_m; i++) {
      matrix_a[i] = malloc(col_m * sizeof(int));
    }

    int **matrix_b = malloc(col_m * sizeof(int *));
    for (int i = 0; i < col_m; i++) {
      matrix_b[i] = malloc(col_n * sizeof(int));
    }

    int **matrix_c = malloc(row_m * sizeof(int *));
    for (int i = 0; i < row_m; i++) {
      matrix_c[i] = malloc(col_n * sizeof(int));
    }

    for (int i = 0; i < row_m; i++) {
      for (int j = 0; j < col_m; j++) {
        matrix_a[i][j] = rand() % 100 + 1;
      }
    }

    for (int i = 0; i < col_m; i++) {
      for (int j = 0; j < col_n; j++) {
        matrix_b[i][j] = rand() % 100 + 1;
      }
    }

    for (int i = 0; i < row_m; i++) {
      for (int j = 0; j < col_n; j++) {
        matrix_c[i][j] = 0;
        for (int k = 0; k < col_m; k++) {
          matrix_c[i][j] += matrix_a[i][k] * matrix_b[k][j];
        }
      }
    }

    end = clock();

    time = ((float)(end - start)) / CLOCKS_PER_SEC;
    printf("Time of execution: %.8lf\n", time);

    for (int i = 0; i < row_m; i++) {
      free(matrix_a[i]);
    }
    free(matrix_a);

    for (int i = 0; i < col_m; i++) {
      free(matrix_b[i]);
    }
    free(matrix_b);

    for (int i = 0; i < row_m; i++) {
      free(matrix_c[i]);
    }
    free(matrix_c);
  }
}