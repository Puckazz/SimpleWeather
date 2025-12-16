import 'package:flutter/material.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/core/utils/logger.dart';

class CityAutocomplete extends StatefulWidget {
  final Function(String) onCitySelected;
  final TextEditingController controller;

  const CityAutocomplete({
    super.key,
    required this.onCitySelected,
    required this.controller,
  });

  @override
  State<CityAutocomplete> createState() => _CityAutocompleteState();
}

class _CityAutocompleteState extends State<CityAutocomplete> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    if (query.length < 2) return;

    _searchCities(query);
  }

  Future<void> _searchCities(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _apiService.searchCities(query, limit: 10);
      if (results.isNotEmpty) {
        logger.i('Found ${results.length} city suggestions for: $query');
      }
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _selectCity(Map<String, dynamic> cityData) {
    final cityName = cityData['name'] as String? ?? '';
    final country = cityData['country'] as String? ?? '';

    logger.i('Selected city: $cityName, $country');
    widget.controller.text = '$cityName, $country';
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });

    widget.onCitySelected(cityName);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: 'Nhập tên thành phố...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.location_on_outlined),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {
                          _showSuggestions = false;
                          _suggestions = [];
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        if (_isSearching)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
        if (!_isSearching && _showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final cityData = _suggestions[index];
                final name = cityData['name'] as String? ?? '';
                final country = cityData['country'] as String? ?? '';
                final state = cityData['state'] as String? ?? '';

                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(name),
                  subtitle: Text(
                    state.isNotEmpty ? '$state, $country' : country,
                  ),
                  onTap: () => _selectCity(cityData),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
      ],
    );
  }
}
