# t-sort
Topological sort (assembly-language exercise) .

Algorithm:
1. Look for node with no incoming edges.
2. If such a node is found:
2.1 Remove node and its outgoing edges from the graph, add node to end of sorted list, goto step 1.
3. If no node was found in step 1 and graph is empty, then terminate with success othwise terminate with failure.

