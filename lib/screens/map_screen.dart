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
        errorMessage = '';
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
      backgroundColor: const Color(0xFF2C3E50),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Mapa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Encontre locais de estudo perto de você',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB0BEC5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Search radius card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF34495E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.radar,
                        color: Color(0xFF3498DB),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Raio de busca: ${(searchRadius/1000).toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF3498DB),
                      inactiveTrackColor: const Color(0xFF2C3E50),
                      thumbColor: const Color(0xFF3498DB),
                      overlayColor: const Color(0xFF3498DB).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: searchRadius,
                      min: 500,
                      max: 5000,
                      divisions: 9,
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
                  ),
                ],
              ),
            ),

            // Map container
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: errorMessage.isNotEmpty
                      ? Container(
                          color: const Color(0xFF34495E),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C3E50),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.location_off,
                                    color: Color(0xFFE74C3C),
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _getCurrentLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3498DB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : currentPosition == null
                          ? Container(
                              color: const Color(0xFF34495E),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Obtendo localização...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                FlutterMap(
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
                                          width: 50.0,
                                          height: 50.0,
                                          point: currentPosition!,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3498DB),
                                              borderRadius: BorderRadius.circular(25),
                                              border: Border.all(color: Colors.white, width: 3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    MarkerLayer(
                                      markers: nearbyPlaces.map((place) => Marker(
                                        width: 40.0,
                                        height: 40.0,
                                        point: place,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: selectedPlaceType == 'cafe'
                                                ? const Color(0xFF8B4513)
                                                : const Color(0xFF6A1B9A),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            selectedPlaceType == 'cafe'
                                                ? Icons.local_cafe
                                                : Icons.menu_book,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                                // Loading overlay
                                if (isLoading)
                                  Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                                            strokeWidth: 3,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Buscando locais...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // No results message
                                if (noResultsMessage.isNotEmpty && !isLoading)
                                  Positioned(
                                    top: 20,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34495E),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFF39C12), width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Color(0xFFF39C12),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              noResultsMessage,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                noResultsMessage = '';
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                ),
              ),
            ),

            // Filter options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF34495E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleFilterOptions,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.filter_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedPlaceType == 'cafe' ? 'Cafeterias' : 'Livrarias',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          showFilterOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  if (showFilterOptions) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterOption('cafe', 'Cafeterias', const Color(0xFF8B4513), Icons.local_cafe),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFilterOption('bookstore', 'Livrarias', const Color(0xFF6A1B9A), Icons.menu_book),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _getCurrentLocation,
          backgroundColor: const Color(0xFF3498DB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String type, String label, Color color, IconData icon) {
    final isSelected = selectedPlaceType == type;
    return GestureDetector(
      onTap: () => _selectPlaceType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF4A5568),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}