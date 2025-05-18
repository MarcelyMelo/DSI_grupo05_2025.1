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
  List<LatLng> nearbyPlaces = [];
  String selectedPlaceType = 'cafe';
  double searchRadius = 1000; // Raio inicial de 1km

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
        errorMessage = '';
      });

      // Definindo os tipos de amenidades para cada categoria
      final amenities = {
        'cafe': ['cafe', 'coffee_shop'],
        'bookstore': ['library', 'bookstore']
      };

      // Construindo a query para a API Overpass
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
      
      print('Enviando requisição para: $url'); // Debug

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'DSIApp/1.0'},
      );

      print('Resposta recebida: ${response.statusCode}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>;
        
        print('Elementos encontrados: ${elements.length}'); // Debug

        if (elements.isEmpty) {
          setState(() {
            errorMessage = 'Nenhum local encontrado neste raio';
            isLoading = false;
          });
          return;
        }

        final places = elements.map((element) {
          // Para nodes, usamos diretamente lat e lon
          if (element['type'] == 'node') {
            return LatLng(
              element['lat'],
              element['lon'],
            );
          } 
          // Para ways e relations, usamos o centro
          else if (element['center'] != null) {
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
          errorMessage = 'Erro na API: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao buscar locais: $e';
        isLoading = false;
      });
      print('Erro completo: $e'); // Debug
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1C22),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
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
                  inactiveColor: Colors.grey,
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : FlutterMap(
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
          Container(
            color: const Color(0xFF0C1C22),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPlaceType == 'cafe' 
                      ? Colors.brown 
                      : const Color(0xFF0C1C22),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedPlaceType = 'cafe';
                    });
                    _findNearbyPlaces(
                      currentPosition!.latitude, 
                      currentPosition!.longitude
                    );
                  },
                  child: const Text('Cafeterias', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPlaceType == 'bookstore' 
                      ? Colors.indigo 
                      : const Color(0xFF0C1C22),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedPlaceType = 'bookstore';
                    });
                    _findNearbyPlaces(
                      currentPosition!.latitude, 
                      currentPosition!.longitude
                    );
                  },
                  child: const Text('Livrarias', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0C1C22),
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}