#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

typedef struct EDGE {
  uint8_t e_from;
  uint8_t e_to;
} EDGE;

#define END_OF_LIST 0xff, 0xff

extern bool t_sort(EDGE *p_edge_list, uint8_t *p_sorted_list, uint8_t n_nodes);

#define N_NODES 4

int main(int argc, char **argv)
{
  uint8_t sorted_list[N_NODES];
  EDGE edge_list[] = {
    0, 2,
    2, 1,
    2, 3,
    1, 3,
    3, 0,
    END_OF_LIST
  };
  for (int i = 0; i < N_NODES; ++i) {
    sorted_list[i] = 0xab;
  }
  if (t_sort(edge_list, sorted_list, N_NODES)) {
    for (int i = 0; i < N_NODES; ++i) {
      printf("%d\n", sorted_list[i]);
    }
  } else {
    printf("tsort failed.\n");
  }
  return 0;
}
