import 'package:route_finder_app/models/graph.dart';
import 'dart:collection';

class DijkstraResult {
  final double distance;
  final List<String> path;
  
  DijkstraResult(this.distance, this.path);
}

DijkstraResult dijkstra(Graph graph, String startVertex, String endVertex) {
  // Check if start and end vertices exist in the graph
  if (!graph.vertices.containsKey(startVertex) || !graph.vertices.containsKey(endVertex)) {
    return DijkstraResult(double.infinity, []);
  }
  
  // Initialize distances with infinity for all vertices except the start vertex
  Map<String, double> distances = {};
  for (var vertex in graph.getVertices()) {
    distances[vertex] = double.infinity;
  }
  distances[startVertex] = 0;
  
  // Priority queue to store vertices to visit
  // We'll use a SplayTreeMap as a priority queue
  SplayTreeMap<double, List<String>> priorityQueue = SplayTreeMap<double, List<String>>();
  priorityQueue[0] = [startVertex];
  
  // Dictionary to store the previous vertex in the optimal path
  Map<String, String?> previous = {};
  for (var vertex in graph.getVertices()) {
    previous[vertex] = null;
  }
  
  while (priorityQueue.isNotEmpty) {
    // Get the vertex with the smallest distance
    double currentDistance = priorityQueue.firstKey()!;
    String currentVertex = priorityQueue[currentDistance]!.removeAt(0);
    
    // If the list becomes empty, remove the key
    if (priorityQueue[currentDistance]!.isEmpty) {
      priorityQueue.remove(currentDistance);
    }
    
    // If we've reached the end vertex, we can stop
    if (currentVertex == endVertex) {
      break;
    }
    
    // If we've found a longer path to the current vertex, skip it
    if (currentDistance > distances[currentVertex]!) {
      continue;
    }
    
    // Check all neighbors of the current vertex
    for (var neighbor in graph.getNeighbors(currentVertex).keys) {
      double weight = graph.getNeighbors(currentVertex)[neighbor]!;
      double distance = currentDistance + weight;
      
      // If we've found a shorter path to the neighbor
      if (distance < distances[neighbor]!) {
        distances[neighbor] = distance;
        previous[neighbor] = currentVertex;
        
        // Add to priority queue
        if (!priorityQueue.containsKey(distance)) {
          priorityQueue[distance] = [];
        }
        priorityQueue[distance]!.add(neighbor);
      }
    }
  }
  
  // Reconstruct the path from end to start
  List<String> path = [];
  String? current = endVertex;
  
  while (current != null) {
    path.add(current);
    current = previous[current];
  }
  
  // Reverse the path to get it from start to end
  path = path.reversed.toList();
  
  // If the end vertex is not reachable
  if (distances[endVertex] == double.infinity) {
    return DijkstraResult(double.infinity, []);
  }
  
  return DijkstraResult(distances[endVertex]!, path);
}