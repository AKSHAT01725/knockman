// lib/booking_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'order_manager.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  final String price;
  const BookingPage({Key? key, required this.serviceName, required this.price})
      : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with TickerProviderStateMixin {
  // ── Step tracking ──
  int _currentStep = 0; // 0 = Details, 1 = Summary, 2 = Payment, 3 = Confirmed

  // ── Form data ──
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _orderId;

  // ── Animation ──
  late AnimationController _checkAnimController;
  late Animation<double> _checkScaleAnim;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScaleAnim = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    _checkAnimController.dispose();
    super.dispose();
  }

  // ── Colours / theme ──
  static const Color _navy = Color(0xFF0D2137);
  static const Color _blue = Color(0xFF1565C0);
  static const Color _accent = Color(0xFF00B4D8);
  static const Color _surface = Color(0xFFF5F7FA);
  static const Color _cardBg = Colors.white;

  // ────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildAppBar(),
          if (_currentStep < 3) _buildStepIndicator(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _currentStep == 0
                  ? _buildDetailsStep()
                  : _currentStep == 1
                  ? _buildSummaryStep()
                  : _currentStep == 2
                  ? _buildPaymentStep()
                  : _buildConfirmedStep(),
            ),
          ),
          if (_currentStep < 3) _buildBottomBar(),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // APP BAR
  // ────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () {
                  if (_currentStep == 0) {
                    Navigator.pop(context);
                  } else if (_currentStep < 3) {
                    setState(() => _currentStep--);
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 13,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.payments_outlined,
                        color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text('COD',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // STEP INDICATOR
  // ────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final steps = ['Details', 'Review', 'Payment'];
    return Container(
      color: _navy,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = _currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: done
                      ? const LinearGradient(colors: [_accent, _blue])
                      : null,
                  color: done ? null : Colors.white24,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = _currentStep == stepIndex;
          final isDone = _currentStep > stepIndex;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? _accent
                      : isActive
                      ? Colors.white
                      : Colors.white24,
                  border: isActive
                      ? Border.all(color: _accent, width: 2)
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                      color: _navy, size: 18)
                      : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? _navy : Colors.white54,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  color:
                  isActive || isDone ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // STEP 0 – DETAILS
  // ────────────────────────────────────────────────
  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _sectionLabel('📅  Schedule'),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Expanded(
                    child: _pickerCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'Date',
                      value: selectedDate == null
                          ? 'Pick a date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: _blue, onPrimary: Colors.white),
                            ),
                            child: child!,
                          ),
                        );
                        if (d != null) setState(() => selectedDate = d);
                      },
                      filled: selectedDate != null,
                    )),
                const SizedBox(width: 12),
                Expanded(
                    child: _pickerCard(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: selectedTime == null
                          ? 'Pick a time'
                          : selectedTime!.format(context),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: _blue, onPrimary: Colors.white),
                            ),
                            child: child!,
                          ),
                        );
                        if (t != null) setState(() => selectedTime = t);
                      },
                      filled: selectedTime != null,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeInDown(
            duration: const Duration(milliseconds: 450),
            child: _sectionLabel('📞  Contact Details'),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 450),
            child: _inputField(
              controller: phoneController,
              label: 'Mobile Number',
              hint: '10-digit number',
              icon: Icons.phone_outlined,
              prefixText: '+91  ',
              keyboard: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _inputField(
              controller: addressController,
              label: 'Service Address',
              hint: 'Full address where service is required',
              icon: Icons.location_on_outlined,
              keyboard: TextInputType.streetAddress,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 24),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: _sectionLabel('📝  Additional Notes'),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _inputField(
              controller: descriptionController,
              label: 'Describe your requirement',
              hint:
              'e.g., 2BHK, specific issue, preferred brand, etc.',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // STEP 1 – SUMMARY / REVIEW
  // ────────────────────────────────────────────────
  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _summaryCard(),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 450),
            child: _priceBreakdownCard(),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Payment will be collected in cash after the service is completed.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final rows = [
      ['Service', widget.serviceName],
      ['Date', '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'],
      ['Time', selectedTime!.format(context)],
      ['Mobile', '+91 ${phoneController.text}'],
      ['Address', addressController.text],
      if (descriptionController.text.isNotEmpty)
        ['Notes', descriptionController.text],
    ];
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_navy, _blue]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Booking Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: rows.map((r) => _summaryRow(r[0], r[1])).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Estimate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _navy,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 14),
          _priceRow('Service Fee', widget.price),
          const Divider(height: 20),
          _priceRow('Platform Fee', '₹0', color: Colors.green),
          _priceRow('Taxes & Charges', 'Included', color: Colors.grey),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                  color: _navy,
                ),
              ),
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: 'Outfit')),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF1A1A2E),
                  fontFamily: 'Outfit')),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // STEP 2 – PAYMENT
  // ────────────────────────────────────────────────
  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _codPaymentCard(),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 450),
            child: _howItWorksCard(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _codPaymentCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_navy, _blue]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.payments_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),

          // COD Option (selected by default)
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border:
                    Border.all(color: Colors.green.shade400, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.money_rounded,
                            color: Colors.green.shade700, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cash on Delivery (COD)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pay in cash after service is done',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green.shade600, size: 26),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Amount due
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amount Due at Service',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          Text(
                            widget.price,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '₹0 Now',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _howItWorksCard() {
    final steps = [
      [
        Icons.check_circle_outline_rounded,
        'Booking Confirmed',
        'Your request is sent to a nearby vendor'
      ],
      [
        Icons.person_pin_circle_outlined,
        'Vendor Assigned',
        'A professional visits you at the scheduled time'
      ],
      [
        Icons.home_repair_service_outlined,
        'Service Completed',
        'Work is done to your satisfaction'
      ],
      [
        Icons.payments_outlined,
        'Pay in Cash',
        'Hand over cash to the vendor after completion'
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _navy,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(s[0] as IconData,
                            color: _blue, size: 20),
                      ),
                      if (i < steps.length - 1)
                        Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey.shade200),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s[1] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _navy,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          Text(
                            s[2] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // STEP 3 – CONFIRMED
  // ────────────────────────────────────────────────
  Widget _buildConfirmedStep() {
    return Center(
      key: const ValueKey(3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _checkScaleAnim,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Color(0xFF00C853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 28),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 400),
              child: const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Your ${widget.serviceName} booking is submitted.\nA vendor will confirm it shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _confirmedRow(
                        Icons.calendar_today_rounded,
                        'Date & Time',
                        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} • ${selectedTime!.format(context)}'),
                    const Divider(height: 20),
                    _confirmedRow(Icons.payments_outlined, 'Payment',
                        'Cash on Delivery'),
                    const Divider(height: 20),
                    _confirmedRow(Icons.location_on_outlined, 'Address',
                        addressController.text),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/orders', (r) => r.isFirst),
                      icon: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 20),
                      label: const Text('View My Orders',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (r) => false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _blue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Back to Home',
                          style: TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmedRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Outfit')),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                      fontFamily: 'Outfit')),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────
  // BOTTOM BAR
  // ────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final labels = ['Continue to Review', 'Proceed to Payment', 'Confirm Booking'];
    final label = labels[_currentStep];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
            : ElevatedButton(
          onPressed: _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // NAVIGATION LOGIC
  // ────────────────────────────────────────────────
  void _handleNext() {
    if (_currentStep == 0) {
      if (!_validateDetails()) return;
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      _confirmBooking();
    }
  }

  bool _validateDetails() {
    if (selectedDate == null || selectedTime == null) {
      _snack('Please select a date and time');
      return false;
    }
    if (phoneController.text.isEmpty ||
        !RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      _snack('Enter a valid 10-digit mobile number');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      _snack('Please enter the service address');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      _snack('Please describe your requirement');
      return false;
    }
    return true;
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      _orderId = await OrderManager.addOrder(
        userId: user.uid,
        service: widget.serviceName,
        price: widget.price,
        date: '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        time: selectedTime!.format(context),
        address: addressController.text,
        description: descriptionController.text,
        phone: phoneController.text,
      );
      setState(() {
        _isLoading = false;
        _currentStep = 3;
      });
      _checkAnimController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Outfit')),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // REUSABLE WIDGETS
  // ────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _navy,
        fontFamily: 'Outfit',
      ),
    );
  }

  Widget _pickerCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFE3F2FD) : _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: filled ? _blue : Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: filled
                  ? _blue.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: filled ? _blue : Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: filled ? _blue : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
                color: filled ? _navy : Colors.grey.shade500,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? prefixText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 15,
          color: _navy,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: _blue, size: 20),
          ),
          prefixIconConstraints:
          const BoxConstraints(minWidth: 52, minHeight: 52),
          labelStyle: TextStyle(
              color: Colors.grey.shade500,
              fontFamily: 'Outfit',
              fontSize: 14),
          hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'Outfit',
              fontSize: 14),
          filled: true,
          fillColor: _cardBg,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
      ),
    );
  }
}