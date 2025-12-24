import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'dart:async';

class CityAutocomplete extends StatefulWidget {
  final Function(String cityName, double lat, double lon) onCitySelected;
  final TextEditingController controller;
  final ApiService? apiService;

  const CityAutocomplete({
    super.key,
    required this.onCitySelected,
    required this.controller,
    this.apiService,
  });

  @override
  State<CityAutocomplete> createState() => _CityAutocompleteState();
}

class _CityAutocompleteState extends State<CityAutocomplete> {
  late final ApiService _apiService;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim();

    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
        _isSearching = false;
      });
      _removeOverlay();
      return;
    }

    if (query.length < 2) return;

    // Debounce search requests
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchCities(query);
    });
  }

  Future<void> _searchCities(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _apiService.searchCities(query, limit: 10);

      if (results.isNotEmpty) {
        logger.i('Found ${results.length} location suggestions for: $query');
      }
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isSearching = false;
        });
        if (_showSuggestions) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40, // Same as page padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 16,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.3),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final cityData = _suggestions[index];
                    final name = cityData['name'] as String? ?? '';
                    final country = cityData['country'] as String? ?? '';
                    final state = cityData['state'] as String? ?? '';

                    return ListTile(
                      leading: Icon(
                        CupertinoIcons.location_fill,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        size: 20,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).textTheme.headlineSmall!.color,
                        ),
                      ),
                      subtitle: Text(
                        state.isNotEmpty ? '$state, $country' : country,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () => _selectCity(cityData),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectCity(Map<String, dynamic> cityData) {
    final cityName = cityData['name'] as String? ?? '';
    final country = cityData['country'] as String? ?? '';
    final lat = (cityData['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (cityData['lon'] as num?)?.toDouble() ?? 0.0;

    logger.i('Selected location: $cityName, $country (lat: $lat, lon: $lon)');
    widget.controller.text = '$cityName, $country';
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _removeOverlay();

    widget.onCitySelected(cityName, lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
        child: TextField(
          controller: widget.controller,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          decoration: InputDecoration(
            hintText: 'Search for a city...',
            hintStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: Theme.of(context).textTheme.bodyMedium!.color,
              size: 20,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showSuggestions = false;
                        _suggestions = [];
                      });
                      _removeOverlay();
                    },
                  )
                : _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ),
    );
  }
}
