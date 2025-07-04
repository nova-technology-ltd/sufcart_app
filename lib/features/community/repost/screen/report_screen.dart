import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  String? _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();
  bool _isOtherSelected = false;
  bool _isSubmitted = false;
  late AnimationController _animationController;

  final List<String> _reportReasons = [
    'Inappropriate Content',
    'Spam or Misleading',
    'Harassment or Bullying',
    'Hate Speech',
    'Violence or Threats',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason or provide a custom reason')),
      );
      return;
    }
    if (_selectedReason == 'Others' && _customReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide details for your report')),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    _animationController.reset();
    _animationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Content'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isSubmitted
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets.lottiefiles.com/packages/lf20_jbrw3hsa.json',
              controller: _animationController,
              onLoaded: (composition) {
                _animationController.duration = composition.duration;
              },
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Report Submitted Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why are you reporting this content?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ..._reportReasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                      _isOtherSelected = value == 'Others';
                      if (!_isOtherSelected) {
                        _customReasonController.clear();
                      }
                    });
                  },
                );
              }),
              if (_isOtherSelected)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: TextField(
                    controller: _customReasonController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Describe your reason',
                      hintText: 'Please provide details for your report...',
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}