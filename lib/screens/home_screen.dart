import 'package:flutter/material.dart';
import 'package:route_finder_app/models/graph.dart';
import 'package:route_finder_app/algorithms/dijkstra.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Graph _graph = Graph();
  String? _startLocation;
  String? _endLocation;
  String? _fromLocation;
  String? _toLocation;
  final TextEditingController _newLocationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  
  DijkstraResult? _result;
  
  @override
  void initState() {
    super.initState();
    _setupSampleGraph();
  }
  
  void _setupSampleGraph() {
    // Add some sample locations and routes
    List<String> locations = [
      "New York", "Boston", "Philadelphia", "Washington DC", 
      "Chicago", "Los Angeles", "San Francisco", "Seattle", 
      "Miami", "Denver"
    ];
    
    // Add all locations as vertices
    for (var location in locations) {
      _graph.addVertex(location);
    }
    
    // Add edges (connections between locations with distances)
    _graph.addEdge("New York", "Boston", 215);
    _graph.addEdge("New York", "Philadelphia", 95);
    _graph.addEdge("Philadelphia", "Washington DC", 140);
    _graph.addEdge("Boston", "Chicago", 983);
    _graph.addEdge("Chicago", "Denver", 1003);
    _graph.addEdge("Denver", "Los Angeles", 1015);
    _graph.addEdge("Los Angeles", "San Francisco", 383);
    _graph.addEdge("San Francisco", "Seattle", 807);
    _graph.addEdge("New York", "Miami", 1280);
    _graph.addEdge("Miami", "Washington DC", 1055);
    _graph.addEdge("Chicago", "Seattle", 2064);
  }
  
  void _findRoute() {
    if (_startLocation == null || _endLocation == null) {
      _showErrorDialog("Please select both start and end locations");
      return;
    }
    
    if (_startLocation == _endLocation) {
      setState(() {
        _result = DijkstraResult(0, [_startLocation!]);
      });
      return;
    }
    
    // Find the shortest path using Dijkstra's algorithm
    DijkstraResult result = dijkstra(_graph, _startLocation!, _endLocation!);
    
    setState(() {
      _result = result;
    });
  }
  
  void _addLocation() {
    String location = _newLocationController.text.trim();
    
    if (location.isEmpty) {
      _showErrorDialog("Please enter a location name");
      return;
    }
    
    if (_graph.getVertices().contains(location)) {
      _showErrorDialog("Location '$location' already exists");
      return;
    }
    
    // Add the location to the graph
    _graph.addVertex(location);
    
    // Clear the text field
    _newLocationController.clear();
    
    // Update the UI
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location '$location' added successfully"))
    );
  }
  
  void _addConnection() {
    if (_fromLocation == null || _toLocation == null) {
      _showErrorDialog("Please select both locations");
      return;
    }
    
    if (_fromLocation == _toLocation) {
      _showErrorDialog("Cannot add connection to the same location");
      return;
    }
    
    String distanceStr = _distanceController.text.trim();
    double? distance = double.tryParse(distanceStr);
    
    if (distance == null || distance <= 0) {
      _showErrorDialog("Please enter a valid positive number for distance");
      return;
    }
    
    // Add the connection to the graph
    _graph.addEdge(_fromLocation!, _toLocation!, distance);
    
    // Clear the text field
    _distanceController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connection added: $_fromLocation to $_toLocation ($distance miles)"))
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    List<String> locations = _graph.getVertices();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Finder"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Find Route Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Find Route",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Start Location Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Start Location",
                        border: OutlineInputBorder(),
                      ),
                      value: _startLocation,
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _startLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // End Location Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "End Location",
                        border: OutlineInputBorder(),
                      ),
                      value: _endLocation,
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _endLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Find Route Button
                    ElevatedButton(
                      onPressed: _findRoute,
                      child: const Text("Find Shortest Route"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Result Section
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Route Information",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_result!.distance == double.infinity)
                        Text("No route found from $_startLocation to $_endLocation")
                      else if (_startLocation == _endLocation)
                        Text("Start and end locations are the same: $_startLocation")
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Shortest distance from $_startLocation to $_endLocation: ${_result!.distance} miles",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("Route: ${_result!.path.join(" -> ")}"),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Add Location Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // New Location TextField
                    TextField(
                      controller: _newLocationController,
                      decoration: const InputDecoration(
                        labelText: "Location Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Add Location Button
                    ElevatedButton(
                      onPressed: _addLocation,
                      child: const Text("Add Location"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Add Connection Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Connection Between Locations",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // From Location Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "From",
                        border: OutlineInputBorder(),
                      ),
                      value: _fromLocation,
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _fromLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // To Location Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "To",
                        border: OutlineInputBorder(),
                      ),
                      value: _toLocation,
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _toLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Distance TextField
                    TextField(
                      controller: _distanceController,
                      decoration: const InputDecoration(
                        labelText: "Distance (miles)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Add Connection Button
                    ElevatedButton(
                      onPressed: _addConnection,
                      child: const Text("Add Connection"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _newLocationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}