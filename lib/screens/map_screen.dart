import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  bool isLoading = true;
  String errorMessage = '';
  String noResultsMessage = '';
  List<LatLng> nearbyPlaces = [];
  String selectedPlaceType = 'cafe';
  double searchRadius = 1000;
  bool showFilterOptions = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          errorMessage = 'Permissão de localização negada';
          isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        errorMessage = ''; // Limpa erro ao obter localização
      });
      
      await _findNearbyPlaces(position.latitude, position.longitude);
      
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao obter localização: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _findNearbyPlaces(double lat, double lng) async {
    try {
      if (currentPosition == null) return;

      setState(() {
        isLoading = true;
        nearbyPlaces = [];
        noResultsMessage = '';
      });

      final amenities = {
        'cafe': ['cafe', 'coffee_shop'],
        'bookstore': ['library', 'bookstore']
      };

      final overpassQuery = '''
        [out:json];
        (
          node["amenity"~"${amenities[selectedPlaceType]!.join('|')}"](around:$searchRadius,$lat,$lng);
          way["amenity"~"${amenities[selectedPlaceType]!.join('|')}"](around:$searchRadius,$lat,$lng);
          relation["amenity"~"${amenities[selectedPlaceType]!.join('|')}"](around:$searchRadius,$lat,$lng);
        );
        out center;
      ''';

      final url = 'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(overpassQuery)}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'DSIApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>;
        
        if (elements.isEmpty) {
          setState(() {
            noResultsMessage = 'Nenhuma ${selectedPlaceType == 'cafe' ? 'cafeteria' : 'livraria'} encontrada neste raio';
            isLoading = false;
          });
          return;
        }

        final places = elements.map((element) {
          if (element['type'] == 'node') {
            return LatLng(
              element['lat'],
              element['lon'],
            );
          } else if (element['center'] != null) {
            return LatLng(
              element['center']['lat'],
              element['center']['lon'],
            );
          }
          return null;
        }).whereType<LatLng>().toList();

        setState(() {
          nearbyPlaces = places;
          isLoading = false;
        });
      } else {
        setState(() {
          noResultsMessage = 'Erro na API: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        noResultsMessage = 'Erro ao buscar locais: $e';
        isLoading = false;
      });
    }
  }

  void _toggleFilterOptions() {
    setState(() {
      showFilterOptions = !showFilterOptions;
    });
  }

  void _selectPlaceType(String type) {
    setState(() {
      selectedPlaceType = type;
      showFilterOptions = false;
    });
    _findNearbyPlaces(
      currentPosition!.latitude, 
      currentPosition!.longitude
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1C22),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        color: const Color(0xFF0C1C22),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              color: const Color(0xFF0C1C22),
              child: const Text(
                'Encontre locais de estudo perto de você',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              color: const Color(0xFF0C1C22),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Text(
                    'Raio de busca: ${(searchRadius/1000).toStringAsFixed(1)} km',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: searchRadius,
                    min: 500,
                    max: 5000,
                    divisions: 9,
                    label: '${(searchRadius/1000).toStringAsFixed(1)} km',
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey[600],
                    onChanged: (value) {
                      setState(() {
                        searchRadius = value;
                      });
                    },
                    onChangeEnd: (value) {
                      if (currentPosition != null) {
                        _findNearbyPlaces(
                          currentPosition!.latitude, 
                          currentPosition!.longitude
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0C1C22),
                ),
                child: errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0C1C22),
                              ),
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : currentPosition == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: currentPosition!,
                                    initialZoom: 15.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          width: 40.0,
                                          height: 40.0,
                                          point: currentPosition!,
                                          child: const Icon(
                                            Icons.person_pin_circle,
                                            color: Colors.blue,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MarkerLayer(
                                      markers: nearbyPlaces.map((place) => Marker(
                                        width: 30.0,
                                        height: 30.0,
                                        point: place,
                                        child: Icon(
                                          selectedPlaceType == 'cafe'
                                            ? Icons.local_cafe
                                            : Icons.menu_book,
                                          color: selectedPlaceType == 'cafe'
                                            ? Colors.brown
                                            : Colors.indigo,
                                          size: 30,
                                        ),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              // Overlay para loading
                              if (isLoading)
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              // Overlay para mensagem de nenhum resultado
                              if (noResultsMessage.isNotEmpty && !isLoading)
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            noResultsMessage,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              noResultsMessage = '';
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
              ),
            ),
            Container(
              color: const Color(0xFF0C1C22),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _toggleFilterOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C1C22),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0x4DFFFFFF)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          selectedPlaceType == 'cafe' ? 'Cafeterias' : 'Livrarias',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          showFilterOptions ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  if (showFilterOptions) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFilterOption('cafe', 'Cafeterias', Colors.brown),
                        const SizedBox(width: 20),
                        _buildFilterOption('bookstore', 'Livrarias', Colors.indigo),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: const Color(0xFF0C1C22),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterOption(String type, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: selectedPlaceType == type ? color : const Color(0xFF0C1C22),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          top: BorderSide(color: Color(0x4DFFFFFF)),
          bottom: BorderSide(color: Color(0x4DFFFFFF)),
          left: BorderSide(color: Color(0x4DFFFFFF)),
          right: BorderSide(color: Color(0x4DFFFFFF)),
        ),
      ),
      child: TextButton(
        onPressed: () => _selectPlaceType(type),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}