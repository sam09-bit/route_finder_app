class Graph {
  // Map to store vertices and their adjacent vertices with weights
  // {vertex: {adjacent_vertex: weight, ...}, ...}
  Map<String, Map<String, double>> vertices = {};
  
  void addVertex(String vertex) {
    // Add a vertex to the graph if it doesn't exist already
    if (!vertices.containsKey(vertex)) {
      vertices[vertex] = {};
    }
  }
  
  void addEdge(String fromVertex, String toVertex, double weight) {
    // Add vertices if they don't exist
    addVertex(fromVertex);
    addVertex(toVertex);
    
    // Add the edge (both directions for an undirected graph)
    vertices[fromVertex]![toVertex] = weight;
    vertices[toVertex]![fromVertex] = weight; // Remove this line for a directed graph
  }
  
  List<String> getVertices() {
    // Return all vertices in the graph
    return vertices.keys.toList();
  }
  
  Map<String, double> getNeighbors(String vertex) {
    // Return all neighbors of a vertex with their weights
    return vertices[vertex] ?? {};
  }
}