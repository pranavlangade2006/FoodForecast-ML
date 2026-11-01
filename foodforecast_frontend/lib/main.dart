import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'services/api_service.dart';

void main() {
  runApp(const FoodForecastApp());
}

class FoodForecastApp extends StatelessWidget {
  const FoodForecastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodForecast ML',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF365AE8)),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E6EF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E6EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF365AE8), width: 1.5),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _customersController = TextEditingController(text: '300');
  final _reservationsController = TextEditingController(text: '250');
  final _previousDayController = TextEditingController(text: '280');

  int _weekend = 1;
  int _holiday = 0;
  int _specialEvent = 0;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _predictionResponse;

  static const List<_MaterialInfo> _materials = [
    _MaterialInfo('rice', 'Rice', 'kg', Icons.rice_bowl_outlined),
    _MaterialInfo('potato', 'Potato', 'kg', Icons.spa_outlined),
    _MaterialInfo('onion', 'Onion', 'kg', Icons.eco_outlined),
    _MaterialInfo('tomato', 'Tomato', 'kg', Icons.local_florist_outlined),
    _MaterialInfo('oil', 'Cooking oil', 'litre', Icons.water_drop_outlined),
    _MaterialInfo('flour', 'Flour', 'kg', Icons.grain_rounded),
  ];

  @override
  void dispose() {
    _customersController.dispose();
    _reservationsController.dispose();
    _previousDayController.dispose();
    super.dispose();
  }

  // Call the FastAPI backend.
  Future<void> _runPrediction() async {
    final customers = int.tryParse(_customersController.text.trim());
    final reservations = int.tryParse(_reservationsController.text.trim());
    final previousCustomers = int.tryParse(_previousDayController.text.trim());

    if (customers == null ||
        reservations == null ||
        previousCustomers == null ||
        customers < 0 ||
        reservations < 0 ||
        previousCustomers < 0) {
      setState(() {
        _errorMessage = 'Enter valid non-negative numbers in all fields.';
        _predictionResponse = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.predictAll(
        expectedCustomers: customers,
        reservations: reservations,
        previousDayCustomers: previousCustomers,
        isWeekend: _weekend,
        isHoliday: _holiday,
        specialEvent: _specialEvent,
      );

      final rawResults = response['results'];

      if (response['status'] != 'success' || rawResults is! Map) {
        throw Exception('The API returned an unexpected response.');
      }

      if (!mounted) return;

      setState(() {
        _predictionResponse = response;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _predictionResponse = null;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;

        return Scaffold(
          body: Row(
            children: [
              if (isDesktop) const _Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(isDesktop: isDesktop),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isDesktop ? 30 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF172B4D),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Forecast food demand and plan your hotel inventory.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildStatistics(),
                            const SizedBox(height: 28),
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                if (innerConstraints.maxWidth >= 850) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: _buildPredictionForm(),
                                      ),
                                      const SizedBox(width: 22),
                                      Expanded(flex: 6, child: _buildResults()),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    _buildPredictionForm(),
                                    const SizedBox(height: 22),
                                    _buildResults(),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            const Center(
                              child: Text(
                                'FoodForecast ML • Intelligent Food Demand Forecasting',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF98A2B3),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 750
            ? 3
            : constraints.maxWidth >= 440
            ? 2
            : 1;

        final cards = [
          _StatData(
            title: 'Materials tracked',
            value: '06',
            subtitle: 'Raw materials',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF365AE8),
          ),
          _StatData(
            title: 'ML models',
            value: '06',
            subtitle: 'Random Forest models',
            icon: Icons.auto_graph_rounded,
            color: const Color(0xFF129879),
          ),
          _StatData(
            title: 'API connection',
            value: _predictionResponse != null ? 'Connected' : 'Ready',
            subtitle: _predictionResponse != null
                ? 'Prediction received'
                : 'Awaiting first prediction',
            icon: Icons.cable_rounded,
            color: const Color(0xFFE49A24),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            mainAxisExtent: 180,
          ),
          itemBuilder: (context, index) {
            return _StatCard(data: cards[index]);
          },
        );
      },
    );
  }

  Widget _buildPredictionForm() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeading(
            title: 'Demand prediction',
            subtitle: 'Enter the expected customer demand.',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 22),
          _numberField(
            label: 'Expected customers',
            controller: _customersController,
            icon: Icons.groups_outlined,
          ),
          const SizedBox(height: 16),
          _numberField(
            label: 'Reservations',
            controller: _reservationsController,
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(height: 16),
          _numberField(
            label: 'Previous-day customers',
            controller: _previousDayController,
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 20),
          _dropdownField(
            label: 'Is it a weekend?',
            value: _weekend,
            onChanged: (value) => setState(() => _weekend = value),
          ),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Public holiday?',
            value: _holiday,
            onChanged: (value) => setState(() => _holiday = value),
          ),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Special event?',
            value: _specialEvent,
            onChanged: (value) => setState(() => _specialEvent = value),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _runPrediction,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 19),
              label: Text(
                _isLoading ? 'Predicting...' : 'Run demand prediction',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF365AE8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('Yes')),
            DropdownMenuItem(value: 0, child: Text('No')),
          ],
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildResults() {
    final rawResults = _predictionResponse?['results'];

    final Map<String, dynamic> results = rawResults is Map
        ? Map<String, dynamic>.from(rawResults)
        : <String, dynamic>{};

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeading(
            title: 'Material requirements',
            subtitle: 'Predicted demand compared with your current inventory.',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            _MessageBox(message: _errorMessage!, isError: true),
            const SizedBox(height: 12),
          ],

          if (results.isEmpty && _errorMessage == null)
            const _MessageBox(
              message: 'Enter the customer details and select Run demand prediction to retrieve real results from the ML backend.',
              isError: false,
            ),

          ..._materials.map((material) {
            final rawItem = results[material.key];

            final Map<String, dynamic>? item = rawItem is Map
                ? Map<String, dynamic>.from(rawItem)
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MaterialResult(material: material, data: item),
            );
          }),

          if (_predictionResponse != null) ...[
            const SizedBox(height: 8),
            Text(
              'Expected customers: ${_predictionResponse!['expected_customers'] ?? '-'}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ],
        ],
      ),
    );
  }
}

class _MaterialInfo {
  const _MaterialInfo(this.key, this.name, this.unit, this.icon);

  final String key;
  final String name;
  final String unit;
  final IconData icon;
}

class _MaterialResult extends StatelessWidget {
  const _MaterialResult({required this.material, required this.data});

  final _MaterialInfo material;
  final Map<String, dynamic>? data;

  String _formatNumber(dynamic value) {
    if (value is! num) return '-';

    final formatted = value.toStringAsFixed(2);

    return formatted
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Stock Sufficient':
        return const Color(0xFF18794E);
      case 'Purchase Required':
        return const Color(0xFF9A6700);
      case 'Urgent Purchase':
        return const Color(0xFFB42318);
      default:
        return const Color(0xFF667085);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Stock Sufficient':
        return const Color(0xFFE0F6EB);
      case 'Purchase Required':
        return const Color(0xFFFFF3D6);
      case 'Urgent Purchase':
        return const Color(0xFFFEE4E2);
      default:
        return const Color(0xFFF2F4F7);
    }
  }

  Widget _metric(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$title: $value',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF344054),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = data?['recommendation']?.toString() ?? 'Pending';
    final unit = data?['unit']?.toString() ?? material.unit;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FB),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  material.icon,
                  color: const Color(0xFF365AE8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  material.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF344054),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBackground(status),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _metric(
                'Predicted',
                '${_formatNumber(data?['predicted_requirement'])} $unit',
              ),
              _metric(
                'In stock',
                '${_formatNumber(data?['current_stock'])} $unit',
              ),
              _metric(
                'To purchase',
                '${_formatNumber(data?['purchase_required'])} $unit',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      color: const Color(0xFF172B4D),
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Color(0xFF79D7B0), size: 29),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'FoodForecast ML',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'SMART HOTEL INVENTORY',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              color: Color(0xFFB8C7DA),
            ),
          ),
          const SizedBox(height: 43),
          const _NavItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            selected: true,
          ),
          const _NavItem(
            icon: Icons.auto_graph_rounded,
            title: 'Demand prediction',
          ),
          const _NavItem(
            icon: Icons.inventory_2_outlined,
            title: 'Inventory management',
          ),
          const _NavItem(
            icon: Icons.shopping_cart_outlined,
            title: 'Purchase planning',
          ),
          const SizedBox(height: 27),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              'ANALYTICS',
              style: TextStyle(
                letterSpacing: 1,
                color: Color(0xFF9AACC5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const _NavItem(
            icon: Icons.query_stats_rounded,
            title: 'Model insights',
          ),
          const _NavItem(icon: Icons.description_outlined, title: 'Reports'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF223A5D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: Color(0xFF79D7B0),
                  size: 25,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI-powered food demand forecasting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.title,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF29466E) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: selected ? Colors.white : const Color(0xFFD0D9E6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : const Color(0xFFE1E8F2),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE9EDF3))),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            const Icon(
              Icons.insights_rounded,
              color: Color(0xFF365AE8),
              size: 26,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              isDesktop ? 'Hotel operations overview' : 'FoodForecast ML',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Color(0xFFE49A24), size: 8),
                SizedBox(width: 7),
                Text(
                  'ML forecasting',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8C5A12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(data.icon, color: data.color, size: 21),
            ],
          ),
          Text(
            data.value,
            style: const TextStyle(
              color: Color(0xFF172B4D),
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          Text(
            data.subtitle,
            style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: child,
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF365AE8), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final background = isError
        ? const Color(0xFFFEE4E2)
        : const Color(0xFFF2F6FF);
    final foreground = isError
        ? const Color(0xFFB42318)
        : const Color(0xFF344F8B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 19,
            color: foreground,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, height: 1.5, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
